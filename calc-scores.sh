#!/bin/bash

file=$1

cat ${file} | grep -A 1 "<td class='score'>" | grep '^\d\d\d\+$' | paste -sd " " - | awk '\
BEGIN {count = 0; single = 0; multi = 0; debug=0}\
{for (i = 1; i <= NF; i=i+2) { single += $i; singleCount++; } }\
{for (i = 2; i <= NF; i=i+2) { multi += $i; multiCount++; } }\
debug==1 {for (i=1; i <= NF; i=i+2) print $i}\
debug==1 {print "==================="}\
debug==1 {for (i=2; i <= NF; i=i+2) print $i}\
END {\
    print "Single: " single/singleCount;\
    print "Multi: " multi/multiCount;\
}'