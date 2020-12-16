#!/bin/bash

TIMESTAMP=$(date +%s)
echo '' > uninflected.txt

# postWord() {
#   # esUrl = 'https://search-kiyanaw-dev-grohpnfdchux2gvdyytpdpqr5m.us-east-1.es.amazonaws.com'
#   # if the file exists ./inflected/$word

#   # curl -s -H "Content-Type: application/x-ndjson" -XPOST ${esUrl}/_bulk --data-binary "@${tempFile}";
# }

analyze() {
  local json=$1
  local word=$(echo "$json" | jq -r ".matched_cree")

  mkdir -p ./inflected
  OUT=./inflected/$word.inflected
  echo '' > $OUT
  # echo '' > uninflected.txt

  category=$(echo $json | jq -r '.lemma_wordform.inflectional_category' | cut -d '-' -f1 | awk '{print tolower($0)}')
  paradigms=$(cat ./layouts/$category.paradigms | sed -e 's/${lemma}/'$word'/')
  inflections=$(echo "$paradigms" | hfst-optimized-lookup --silent ./fsts/crk-normative-generator.hfstol 2>&1)
  clean=$(echo "$inflections" | grep -v -e '^$' | grep -v '!')
  # echo "$clean"

  OLDIFS=$IFS
  IFS=$'\n'
  for inflection in $clean; do
    # echo ".$inflection." 
    inflected=$(echo $inflection | cut -d $'\t' -f2)
    analysis=$(echo $inflection | cut -d $'\t' -f1)

    # start bulk ops for ES
    empty=$(echo $inflection | grep -v '+?')
    if [ -z "$empty" ]; then
      echo $inflected >> uninflected.txt
    else
      uuid=$(uuidgen)
      echo "{ create: { _index: 'inflected-$TIMESTAMP', _id: '$uuid' } }" >> $OUT
      echo $json | jq -c '. | .matched_cree = "'$inflected'" | . + {analysis: "'$analysis'"}' >> $OUT
    fi
  done;
  IFS=$OLDIFS

}

processWord() {
  local json=$1
  local length=$(echo $json | jq '. | length')
  if [ $length -gt 0 ]; then
    for i in $(seq 0 $(expr $length - 1)); do
      item=$(echo $json | jq -cM '.['$i']')
      analyze "$item"
    done
  fi
}


indexNouns () {
  dir=./sapir/nouns

  for file in $(ls $dir); do
    word=$(echo $file | sed -e 's/\.json//')
    echo "Processing $word"
    contents=$(cat $dir/$file | jq '[.[] | select(.is_lemma == true)]')
    processWord "$contents"

    # postWord
  done
}

indexNouns