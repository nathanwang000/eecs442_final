#!/bin/bash
cp VOCdevkit/VOC2010/ImageSets/Action/trainval.txt small_tr.txt
sed -n 1,5p small_tr.txt > small_trainval.txt
cp VOCdevkit/VOC2010/ImageSets/Action/test.txt small_te.txt
sed -n 1,5p small_te.txt > small_test.txt

# rm temp files
rm small_te.txt
rm small_tr.txt
