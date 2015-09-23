#!/bin/bash
# author: Jiaxuan Wang
# description: clean up file for bang peng code

# clean up for step0: createForegroundImages.m
rm train_fg.txt
rm test_fg.txt
rm -r dataset_fg

# clean up for step1: train_RF
rm datasets/*
#rm VOCActionDataset.mat
#rm VOCActionDatasetfg.mat
rm -r savefeature_bg # remove caffe + sift
rm -r savefeature_fg # remove caffe + sift
rm trainval_{0,1}.txt
rm trainval_{0,1}_flipped.txt
rm trees/*

# clean up for step2: test_RF
rm test_0.txt
rm ../test_result/*
