#!/bin/bash

printf "query: "
read query

maxPages=50
i=1
queryEncoded=$(node -p "encodeURIComponent('$query')")
filename=$(echo $query | sed 's/ /-/')

echo

while [ $i -le $maxPages ]
do
  echo -ne " -> Downloading page $i\033[0K\r"
  
  curl -s https://browser.geekbench.com/v4/cpu/search\?utf8=✓\&page\=${i}\&q\=$queryEncoded >> ${filename}

  if grep -q "did not match any Geekbench 4 results" ${filename}; then
    break
  fi
  i=$((i + 1))
done

echo -ne "\r\033[0K"

printf "Average Geekbench 4 scores for \`${query}\`:\n\n"

cat ${filename} | grep -A 1 "<td class='score'>" | grep '^\d\d\d\+$' | paste -sd " " - | awk '\
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

rm ${filename}
