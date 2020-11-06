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

cd ..
