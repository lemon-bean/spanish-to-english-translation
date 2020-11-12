#!/bin/bash -v

cd data

# get En-Es training data
wget -nc http://www.statmt.org/europarl/v7/es-en.tgz -O europarl-es-en.tgz
wget -nc http://opus.nlpl.eu/download.php?f=EMEA/v3/moses/en-es.txt.zip -O emea-en-es.txt.zip
wget -nc http://opus.nlpl.eu/download.php?f=ECB/v1/moses/en-es.txt.zip -O ecb-en-es.txt.zip
wget -nc http://opus.nlpl.eu/download.php?f=DGT/v2019/moses/en-es.txt.zip -O dgt-en-es.txt.zip
wget -nc http://opus.nlpl.eu/download.php?f=Books/v1/moses/en-es.txt.zip -O books-en-es.txt.zip
wget -nc http://opus.nlpl.eu/download.php?f=MultiUN/v1/moses/en-es.txt.zip -O multiun-en-es.txt.zip
wget -nc http://opus.nlpl.eu/download.php?f=TED2013/v1.1/moses/en-es.txt.zip -O ted2013-en-es.txt.zip
wget -nc http://opus.nlpl.eu/download.php?f=Wikipedia/v1.0/moses/en-es.txt.zip -O wikipedia-en-es.txt.zip
wget -nc http://opus.nlpl.eu/download.php?f=OpenSubtitles/v2018/moses/en-es.txt.zip -O OST-en-es.txt.zip

# extract data
tar -xf europarl-es-en.tgz
unzip -o emea-en-es.txt.zip
unzip -o ecb-en-es.txt.zip
unzip -o dgt-en-es.txt.zip
unzip -o books-en-es.txt.zip
unzip -o multiun-en-es.txt.zip
unzip -o ted2013-en-es.txt.zip
unzip -o wikipedia-en-es.txt.zip
unzip -o OST-en-es.txt.zip

# checking data consistency
for i in *.en; do
  es_file_name="${i%.en}.es"
  en_line_number="$(wc -l < $i)"
  es_line_number="$(wc -l < $es_file_name)"
  if (( en_line_number != es_line_number )); then
    echo "$i contains $en_line_number lines and $es_file_name contains $es_line_number lines. They are not match!" >&2
    eixt 1
  else
    echo "${i%.en} contains $en_line_number lines of words. Ready to merge to the main corpus file."
  fi
done

# some clearing up, move the downloaded files into a new directory
# called source_files
mkdir source_files
mv *.zip *.tgz source_files

cd ..
