#!/bin/bash

if [[ $# -eq 0 ]]; then
  echo "$0 <query>"
  exit 1
fi

query="$@"

maxPages=50
queryEncoded=$(node -p "encodeURIComponent('$query')")

search() {
  local i=1
  while [[ $i -le $maxPages ]]
  do
    echo -ne " -> Downloading page $i\033[0K\r" 1>&2

    result=$(curl -s https://browser.geekbench.com/v4/cpu/search\?utf8=%E2%9C%93\&page\=${i}\&q\=$queryEncoded)
    echo "$result"

    if echo "$result" | grep -q "did not match any Geekbench 4 results"; then
      echo 1>&2
      break
    fi
    i=$((i + 1))
  done
}

printf "Average Geekbench 4 scores for \`${query}\`:\n\n"

search | grep -A 1 "<td class='score'>" | grep '^\d\d\d\+$' | paste -sd " " - | awk '\
BEGIN {count = 0; single = 0; multi = 0; debug=0}\
{for (i = 1; i <= NF; i=i+2) { single += $i; count++; } }\
{for (i = 2; i <= NF; i=i+2) { multi += $i; } }\
debug==1 {for (i=1; i <= NF; i=i+2) print $i}\
debug==1 {print "==================="}\
debug==1 {for (i=2; i <= NF; i=i+2) print $i}\
END {\
    print "Single-Core Score:\t" single/count;\
    print "Multi-Core Score:\t" multi/count;\
    print "\nScores are based on " count " results."\
}'
