#!/bin/bash

pull-layout () {
  mkdir -p ./layouts
  FILE=$1
  if [ ! -f ./layouts/$FILE ]; then
    echo "Pulling $FILE"
    curl -s https://raw.githubusercontent.com/UAlbertaALTLab/cree-intelligent-dictionary/master/CreeDictionary/res/layouts/$FILE > ./layouts/$FILE
  fi
}

parse-layout() {
  pull-layout $2

  FILE=./layouts/$2
  for token in $(cat $FILE); do 
    item=$(echo $token | grep "$1")
    if [ ! -z "$item" ]; then
      echo $item
    fi
  done
}


main() {
  # verbs
  echo "Pulling VAI..."
  parse-layout "V+AI" verb-ai-linguistic.layout.tsv > ./layouts/vai.paradigms
  echo "Pulling VTI..."
  parse-layout "V+TI" verb-ti-linguistic.layout.tsv > ./layouts/vti.paradigms
  echo "Pulling VTA..."
  parse-layout "V+TA" verb-ta-linguistic.layout.tsv > ./layouts/vta.paradigms
  echo "Pulling VII..."
  parse-layout "V+II" verb-ii-linguistic.layout.tsv > ./layouts/vii.paradigms

  # nouns
  echo "Pulling NA..."
  parse-layout "N+A" noun-na-linguistic.layout.tsv > ./layouts/na.paradigms
  echo "Pulling NAD..."
  parse-layout "N+A+D" noun-nad-linguistic.layout.tsv > ./layouts/nad.paradigms
  echo "Pulling NI..."
  parse-layout "N+I" noun-ni-linguistic.layout.tsv > ./layouts/ni.paradigms
  echo "Pulling NID..."
  parse-layout "N+I+D" noun-nid-linguistic.layout.tsv > ./layouts/nid.paradigms

  echo "Done."
}

main
