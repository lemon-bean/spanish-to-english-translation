cd data

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

# append code start - by Frank W
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
# append code end - by Frank W

# append code start - by Frank W
# some clearing up, move the downloaded files into a new directory
# called source_files
mkdir source_files
mv *.zip *.tgz source_files
# append code end - by Frank W

# create corpus files
cat Books.en-es.en DGT.en-es.en ECB.en-es.en EMEA.en-es.en europarl-v7.es-en.en MultiUN.en-es.en TED2013.en-es.en OpenSubtitles.en-es.en Wikipedia.en-es.en > corpus-ordered.en
cat Books.en-es.es DGT.en-es.es ECB.en-es.es EMEA.en-es.es europarl-v7.es-en.es MultiUN.en-es.es TED2013.en-es.es OpenSubtitles.en-es.es Wikipedia.en-es.es > corpus-ordered.es

# append code start - by Frank W
# some clearing up, move the original files into a new directory
# called originals
mkdir originals
mv Books* DGT* ECB* EMEA* Multi* Open* TED* Wiki* europarl* LICENSE README originals
# append code end - by Frank W

cd ..
