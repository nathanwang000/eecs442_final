#!/bin/bash
# remove empty trees
find final_project/trees/ -size  0 -print0 |xargs -0 rm
# rename those trees
FILES=final_project/trees/*
i=0
for f in $FILES
do
    echo "rename $f file...$[i/100]$[i%100/10]$[i%10]"
    mv $f "final_project/trees/tree_$[i/100]$[i%100/10]$[i%10].txt"
    i=$[$i+1]
done