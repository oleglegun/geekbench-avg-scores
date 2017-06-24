#!/bin/bash


printf "query: "
read query

pages=50

i=1

queryEncoded=$(node -p "encodeURIComponent('$query')")

filename=$(echo $query | sed 's/ /-/')

while [ $i -le $pages ]
do
  http https://browser.primatelabs.com/v4/cpu/search\?utf8=✓\&page\=${i}\&q\=$queryEncoded >> ${filename}
  
  echo page $i

  if grep -q "did not match any Geekbench 4 results" ${filename}; then
    i=100
  fi
  i=$((i + 1))
done





