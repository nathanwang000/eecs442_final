#!/bin/bash
touch fullDataset.txt
cat final_project/train_files/train_action_general.txt >> fullDataset.txt
cat final_project/test_files/test_action_general.txt >> fullDataset.txt
