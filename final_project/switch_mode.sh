#!/bin/bash
if [ $1 = "val" ]; then
    echo "switch to validation mode (using train.txt, val.txt)"
    # copy from backup/val.txt to VOCdevkit/VOC2010/ImageSets/Action/test.txt
    # copy from backup/train.txt to VOCdevkit/VOC2010/ImageSets/Action/trainval.txt    
    cp backup/val.txt VOCdevkit/VOC2010/ImageSets/Action/test.txt
    cp backup/train.txt VOCdevkit/VOC2010/ImageSets/Action/trainval.txt
    # use backup/trainval_action/*_val.txt for ../test/VOCdevkit/VOC2010/ImageSets/Action/
    cp backup/trainval_action/*_val.txt backup/playground/ # copy to play ground
    ./renamer.sh backup/playground/ val test # rename
    mv backup/playground/*_test.txt ../test/VOCdevkit/VOC2010/ImageSets/Action/  # mv to dest
    # copy from backup/val.txt to ../test/VOCdevkit/VOC2010/ImageSets/Action/test.txt
    # copy from backup/train.txt to ../trainval/VOCdevkit/VOC2010/ImageSets/Action/trainval.txt    
    cp backup/val.txt ../test/VOCdevkit/VOC2010/ImageSets/Action/test.txt
    cp backup/train.txt ../trainval/VOCdevkit/VOC2010/ImageSets/Action/trainval.txt
elif [ $1 = "test" ]; then
    echo "switch to test mode (using trainval.txt, test.txt)"    
    # copy from backup/test.txt to VOCdevkit/VOC2010/ImageSets/Action/test.txt
    # copy from backup/trainval.txt to VOCdevkit/VOC2010/ImageSets/Action/trainval.txt
    cp backup/test.txt VOCdevkit/VOC2010/ImageSets/Action/test.txt
    cp backup/trainval.txt VOCdevkit/VOC2010/ImageSets/Action/trainval.txt
    # use backup/test_action/*_test.txt for ../test/VOCdevkit/VOC2010/ImageSets/Action/
    cp backup/test_action/*_test.txt ../test/VOCdevkit/VOC2010/ImageSets/Action/
    # copy from backup/test.txt to ../test/VOCdevkit/VOC2010/ImageSets/Action/test.txt
    # copy from backup/trainval.txt to ../trainval/VOCdevkit/VOC2010/ImageSets/Action/trainval.txt
    cp backup/test.txt ../test/VOCdevkit/VOC2010/ImageSets/Action/test.txt
    cp backup/trainval.txt ../trainval/VOCdevkit/VOC2010/ImageSets/Action/trainval.txt
else
    echo "$1 is not a valid mode, try [val|test]"
    exit 0
fi

echo "generate necessary files: eg. small_trainval.txt, small_test.txt"
cp VOCdevkit/VOC2010/ImageSets/Action/trainval.txt small_trainval.txt
cp VOCdevkit/VOC2010/ImageSets/Action/test.txt small_test.txt

echo "successful done"
