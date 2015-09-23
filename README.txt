Author: Jiaxuan Wang
Date: 9/21/2015

This is a reminder for myself and other parties of concern using this code

The steps in using Bangpeng's methods are: (assumption: see pythonUtils for the specific setting)
--- Day 1
1. prepareTrainTest.m (15 min)
2. prepareGroundTruth.m (15 min)
3. prepareGeneral (< 1 min)
4. sift extraction (11 hours) 
5. generate input file for all classes and general action class
6. dictionary learning (2 hours) 
7. llc extraction (< 11 hours?) 
--- Day 2
8. createMatFilesBg (< 1 hours?) (* run to here)
9. integral extraction (< 2 hours?) (* finished) 
10. outputBinaryFeature for both train and test (< 10 hours?) (* cleaned to here) (clean this to not use parfor!)
--- Day 3
11. trainRF (9 hours ?)
12. testRF (< 1 hour?)

==== general information about the dataset  /scratch/jiadeng_fluxg/shared/hico_20150920
numTest:   9658
numTrain:  38116
total:	   47774
====

hardcoded in : smallSift.m (file used to extract sift individually)
TOFIND corrputed files: use pbsFiles/findCorrupted.py

From previous readme.txt:
(done) prepareTrainTest; % prepare images to be used in the algorithm
(done) prepareGeneral; % prepare images used for dictionary learning
(done) prepareGroundTruth; % prepare ground truth
(in the process) massive_extract_sift; % extract sift for each class, use speedup_sift*.m for faster extraction by manually splitting classes
gen_dict; % generate dictionary, qsub ../pbsfiles/gen_dict.m for efficiency
massive_extract_LLC; % extract LLC for each class, use speedup_*.m for faster extraction by manully splitting classes
massive_createMatFilesBg; % create matfiles for background images
massive_extract_integral; % save integral images, use corresponding files in pbs files instead for efficiency
(in terminal) cd ../pbsfiles;
(in terminal) python super_gen.py; % output Binary feature (this file doesn't exist, see output binary feature train and test)
(in terminal) python gen_RF_train.py; % train RF
(in terminal) python /scratch/jiadeng_fluxg/jiaxuan/python_helper_bin/gen_del_trees.py; # delete empty trees
(in terminal) python gen_RF_test.py; % test RF
(in terminal) cd /scratch/jiadeng_fluxg/jiaxuan/python_helper_bin;
(in terminal) python report_result.py; # report result


* The final result is stored in final_result.txt, which I included in /scratch/jiadeng_fluxg/jiaxuan/final_result.txt
* Each line in the file is of the following form
* action_class_name:action_class_index:num_train:positive_proportion_train:num_test:positive_proportion_test:averge_precision
* The result for third experiments documented in my report is in /scratch/jiadeng_fluxg/jiaxuan/final_result_neg_two.txt
* which is in the exact same format as final_result.txt
* For details of using the code, please see the comment on the top portion of each file


