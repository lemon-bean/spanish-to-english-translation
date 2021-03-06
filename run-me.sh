#!/bin/bash -v

MARIAN=../../build
EXAMPLE_TOOLS=../tools # added - by Frank W

# if we are in WSL, we need to add '.exe' to the tool names
# WSL - Windows Subsystem for Linux - by Frank W
if [ -e "/bin/wslpath" ]
then
    EXT=.exe
fi

MARIAN_TRAIN=$MARIAN/marian$EXT
MARIAN_DECODER=$MARIAN/marian-decoder$EXT
MARIAN_VOCAB=$MARIAN/marian-vocab$EXT
MARIAN_SCORER=$MARIAN/marian-scorer$EXT

# set chosen gpus
# the default GPU number is 0 - added by Frank W
GPUS=0
# command start - by Frank W
# if the number of positional parameters is greater than 0
# $# is the number of positional paramters
# $@ is the whole positional parameter(s)
# command end - by Frank W
if [ $# -ne 0 ]
then
    GPUS=$@
fi
echo Using GPUs: $GPUS

if [ ! -e $MARIAN_TRAIN ]
then
    echo "marian is not installed in $MARIAN, you need to compile the toolkit first"
    exit 1
fi

# checking for preprocessing tools - commented by Frank W
# modify start - by Frank W
# original: if [ ! -e ../tools/moses-scripts ] || [ ! -e ../tools/subword-nmt ]
if [ ! -e $EXAMPLE_TOOLS/moses-scripts ] || [ ! -e $EXAMPLE_TOOLS/subword-nmt ]
# modify end - by Frank W
then
    echo "missing tools in ../tools, you need to download them first"
    exit 1
fi

if [ ! -d "data/source_files" ]; then
    ./scripts/download-files-spanish.sh
fi

if [ ! -e "data/corpus.en" ]; then
	./scripts/prepare_files.sh
fi

mkdir -p model

# preprocess data
if [ ! -e "data/corpus.bpe.en" ]
then
    ./scripts/preprocess-data.sh
fi

# train model
if [ ! -e "model/model.npz.best-translation.npz" ]
then
    $MARIAN_TRAIN \
        --devices $GPUS \
		--fp16 \
        --type amun \
        --model model/model.npz \
        --train-sets data/corpus.bpe.es data/corpus.bpe.en \
        --vocabs model/vocab.es.yml model/vocab.en.yml \
        --dim-vocabs 100000 100000 \
        --mini-batch-fit -w 3500 \
        --layer-normalization --dropout-rnn 0.2 --dropout-src 0.1 --dropout-trg 0.1 \
        --early-stopping 5 \
        --valid-freq 10000 --save-freq 10000 --disp-freq 1000 \
        --valid-metrics cross-entropy translation \
        --valid-sets data/corpus-dev.bpe.es data/corpus-dev.bpe.en \
        --valid-script-path "bash ./scripts/validate.sh" \
        --log model/train.log --valid-log model/valid.log \
        --overwrite --keep-best \
        --seed 1111 --exponential-smoothing \
        --normalize=1 --beam-size=12 --quiet-translation
fi

# translate dev set
cat data/corpus-dev.bpe.es \
    | $MARIAN_DECODER -c model/model.npz.best-translation.npz.decoder.yml -d $GPUS -b 12 -n1 \
      --mini-batch 64 --maxi-batch 10 --maxi-batch-sort src \
    | sed 's/\@\@ //g' \
    | ../tools/moses-scripts/scripts/recaser/detruecase.perl \
    | ../tools/moses-scripts/scripts/tokenizer/detokenizer.perl -l en \
    > data/corpus-dev.es.output

# translate test set
cat data/corpus-test.bpe.es \
    | $MARIAN_DECODER -c model/model.npz.best-translation.npz.decoder.yml -d $GPUS -b 12 -n1 \
      --mini-batch 64 --maxi-batch 10 --maxi-batch-sort src \
    | sed 's/\@\@ //g' \
    | ../tools/moses-scripts/scripts/recaser/detruecase.perl \
    | ../tools/moses-scripts/scripts/tokenizer/detokenizer.perl -l en \
    > data/corpus-test.es.output

# calculate bleu scores on dev and test set
../tools/moses-scripts/scripts/generic/multi-bleu-detok.perl data/corpus-dev.en < data/corpus-dev.es.output
../tools/moses-scripts/scripts/generic/multi-bleu-detok.perl data/corpus-test.en < data/corpus-test.es.output
