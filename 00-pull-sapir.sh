SAPIR='https://sapir.artsrn.ualberta.ca/cree-dictionary/click-in-text/?q='

pullVerbs() {

  INFILE='verb_stems'
  FILE="$INFILE.lexc"
  LEXC='https://raw.githubusercontent.com/giellalt/lang-crk/develop/src/fst/stems/'$INFILE'.lexc'

  mkdir -p ./sapir/verbs

  # pull the file if it doesn't exist
  if [ ! -f ./$FILE ]; then
    echo "Pulling $FILE"
    curl -s $LEXC > $FILE
  fi

  cat $FILE | grep -v '^!' | grep -v '^$' | grep ':' | while read line 
  do
    word=$(echo $line | cut -d ':' -f1 | cut -d '@' -f3)
    echo "Processing $word"
    URL="https://sapir.artsrn.ualberta.ca/cree-dictionary/click-in-text/?q=$word"
    JSON=$(curl -s $URL | jq  '[.results[] | select(.matched_cree == "'$word'") | del(.inflectional_category_plain_english) | del(.relevant_tags) | del(.linguistic_breakdown_tail) | del(.linguistic_breakdown_head) | del(.lemma_wordform.inflectional_category_plain_english) | del(.lemma_wordform.inflectional_category_linguistic) | del(.lemma_wordform.wordclass_emoji) | del(.definitions)]')
    echo $JSON > ./sapir/verbs/$word.json
  done

}


pullNouns() {

  INFILE='noun_stems'
  FILE="$INFILE.lexc"
  LEXC='https://raw.githubusercontent.com/giellalt/lang-crk/develop/src/fst/stems/'$INFILE'.lexc'

  mkdir -p ./sapir/nouns

  # pull the file if it doesn't exist
  if [ ! -f ./$FILE ]; then
    echo "Pulling $FILE"
    curl -s $LEXC > $FILE
  fi

  cat $FILE | grep -v '^!' | grep -v '^$' | grep ';' | while read line 
  do
    word=$(echo $line | cut -d ' ' -f1 | cut -d ':' -f1 | rev | cut -d '@' -f1 | rev)
    echo "Processing $word"

    if [[ -f "./sapir/nouns/$word.json" ]]; then
      echo "$word exists."
    else
      URL="https://sapir.artsrn.ualberta.ca/cree-dictionary/click-in-text/?q=$word"
      JSON=$(curl -s $URL | jq  '[.results[] | select(.matched_cree == "'$word'") | del(.inflectional_category_plain_english) | del(.relevant_tags) | del(.linguistic_breakdown_tail) | del(.linguistic_breakdown_head) | del(.lemma_wordform.inflectional_category_plain_english) | del(.lemma_wordform.inflectional_category_linguistic) | del(.lemma_wordform.wordclass_emoji) | del(.definitions)]')
      echo $JSON > ./sapir/nouns/$word.json
    fi

  done

}

# pullVerbs
pullNouns