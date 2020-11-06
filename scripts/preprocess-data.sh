#!/bin/bash -v

# Suffix of source language files
SRC=es

# Suffix of target language files
TRG=en

# Number of merge operations. Network vocabulary should be slightly larger (to
# include characters), or smaller if the operations are learned on the joint
# vocabulary
bpe_operations=85000

# path to moses decoder: https://github.com/moses-smt/mosesdecoder
mosesdecoder=../../tools/moses-scripts

# path to subword segmentation scripts: https://github.com/rsennrich/subword-nmt
subword_nmt=../../tools/subword-nmt

# append code start - by Frank W
cd data

# shuffle
shuf --random-source=corpus-ordered.en corpus-ordered.en > corpus-full.en
shuf --random-source=corpus-ordered.en corpus-ordered.es > corpus-full.es

# Make data splits
head -n -4000 corpus-full.en > corpus.en
head -n -4000 corpus-full.es > corpus.es
tail -n 4000 corpus-full.en > corpus-dev-test.en
tail -n 4000 corpus-full.es > corpus-dev-test.es
head -n 2000 corpus-dev-test.en > corpus-dev.en
head -n 2000 corpus-dev-test.es > corpus-dev.es
tail -n 2000 corpus-dev-test.en > corpus-test.en
tail -n 2000 corpus-dev-test.es > corpus-test.es
# append code end - by Frank W

# tokenize
# comment start - added be Frank W
# the original text is like this:
# 0. Markeverything endingin9through69.
# 1. Keep digging, Cornelius.
# 2. So we have what?
# the tokenized text is like this:
# 0. Markeverything endingin9through69 .
# 1. Keep digging , Cornelius .
# 2. So we have what ?
# comment end - added by Frank W
for prefix in corpus corpus-dev corpus-test
do
    cat $prefix.$SRC \
        | $mosesdecoder/scripts/tokenizer/normalize-punctuation.perl -l $SRC \
        | $mosesdecoder/scripts/tokenizer/tokenizer.perl -a -l $SRC > $prefix.tok.$SRC

    cat $prefix.$TRG \
        | $mosesdecoder/scripts/tokenizer/normalize-punctuation.perl -l $TRG \
        | $mosesdecoder/scripts/tokenizer/tokenizer.perl -a -l $TRG > $prefix.tok.$TRG

done

# clean empty and long sentences, and sentences with high source-target ratio (training corpus only)
$mosesdecoder/scripts/training/clean-corpus-n.perl corpus.tok $SRC $TRG corpus.tok.clean 1 80

# train truecaser
$mosesdecoder/scripts/recaser/train-truecaser.perl -corpus corpus.tok.clean.$SRC -model model/tc.$SRC
$mosesdecoder/scripts/recaser/train-truecaser.perl -corpus corpus.tok.clean.$TRG -model model/tc.$TRG

# apply truecaser (cleaned training corpus)
for prefix in corpus
do
    $mosesdecoder/scripts/recaser/truecase.perl -model model/tc.$SRC < $prefix.tok.clean.$SRC > $prefix.tc.$SRC
    $mosesdecoder/scripts/recaser/truecase.perl -model model/tc.$TRG < $prefix.tok.clean.$TRG > $prefix.tc.$TRG
done

# apply truecaser (dev/test files)
for prefix in corpus-dev corpus-test
do
    $mosesdecoder/scripts/recaser/truecase.perl -model model/tc.$SRC < $prefix.tok.$SRC > $prefix.tc.$SRC
    $mosesdecoder/scripts/recaser/truecase.perl -model model/tc.$TRG < $prefix.tok.$TRG > $prefix.tc.$TRG
done

# train BPE
cat corpus.tc.$SRC corpus.tc.$TRG | $subword_nmt/learn_bpe.py -s $bpe_operations > model/$SRC$TRG.bpe

# apply BPE
for prefix in corpus corpus-dev corpus-test
do
    $subword_nmt/bpe.py -c model/$SRC$TRG.bpe < $prefix.tc.$SRC > $prefix.bpe.$SRC
    $subword_nmt/bpe.py -c model/$SRC$TRG.bpe < $prefix.tc.$TRG > $prefix.bpe.$TRG
done

cd ..
