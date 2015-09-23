function [config, config_fg, ...
          trainingpath, savefile, hi, name, testpath, ...
          trainingpath_fg, savefile_fg, hi_fg, name_fg, testpath_fg, ...
          trainingfilepath, trainingfileflippedpath, ...
          trainingfilepath_fg, trainingfileflippedpath_fg, ...
          trainingfilegt, ...
          testfilepath, testfileflippedpath, ...
          testfilepath_fg, testfileflippedpath_fg, ...
          testfilegt]=smallConfig_dev(action)
% given the action (one of the list_action), configure for each action 

% background
config.includeFlippedImages = 0;

% Grayscale SIFT
config.SIFT.imageSize = 0; % for not scaling
config.SIFT.gridSpacing = 4;

config.SIFT.patchSize = [8 12 16 24 30];
config.SIFT.sigmaEdge = 0.8;

% Dictionary learning
config.dictionary.size = 1024;
config.dictionary.numImages = 100; % Number of images to sample; was 4000
config.dictionary.numDescriptors = 4e6; % Maximum number of descriptors to 
                                        % use for dictionary learningX
% LLC coding
config.LLC.knn = 5;

% Mat file variables
config.matFiles.gridSpacing = 8; % was 4
config.matFiles.patchSize = 16; % was 8

% Enable matlabpool? If so, enter how many cores.
config.parallel.enable = 0;
config.parallel.cores = 16;

% Auxillary variables
config.flipSuffix = {'', '_f'};
config.imageSets = {'tr', 'te'};

% the list of training data(background)
trainingpath = sprintf('train_files/train_%s_%s.txt', action.vname, action.nname);

% file name of the dataset
savefile = sprintf('/scratch/jiadeng_fluxg/jiaxuan/datasets/%s_%s_dataset.mat', action.vname, action.nname);
% path where training and test images exist
hi = '/scratch/jiadeng_fluxg/shared/hico_20150920/images/';
name = sprintf('%s_%s_Classification', action.vname, action.nname); % name of dataset
% the list of test data(background)
testpath = sprintf('test_files/test_%s_%s.txt', action.vname, action.nname);

config.outputFolder = '/scratch/jiadeng_fluxg/jiaxuan/savefeature/';% the output path to save the feature extracton result for background feature, here fg is intended as no bg images

%foreground 

% Folder where SIFT descriptors/LLC histograms/final files are output
config_fg.outputFolder = config.outputFolder; % the output path to save the feature extracton result for foreground feature, save as bg as there is no bg anyway

% generate input .mat file
% the list of training data(foreground)
trainingpath_fg = trainingpath;
savefile_fg = savefile; %sprintf('/scratch/jiadeng_fluxg/jiaxuan/datasets/%s_%s_fg_dataset.mat', action.vname, action.nname);
% path where training and test images exist
hi_fg = hi;
name_fg =sprintf('%s_%s_Classification_fg', action.vname, action.nname);
% the list of test data(foreground)
testpath_fg = testpath; % generated in step 0


%foreground parameter configuration

config_fg.includeFlippedImages = 0;

% Grayscale SIFT
config_fg.SIFT.imageSize = 300; 
config_fg.SIFT.gridSpacing = 4;
config_fg.SIFT.patchSize = [8 12 16 24 30];
config_fg.SIFT.sigmaEdge = 0.8;

% Dictionary learning
config_fg.dictionary.size = 1024; % was 1024
config_fg.dictionary.numImages = 100; % Number of images to sample; was 4000
config_fg.dictionary.numDescriptors = 4e6; % Maximum number of descriptors to was 4e6
                                        % use for dictionary learning
% LLC coding
config_fg.LLC.knn = 5;

% Mat file variables
config_fg.matFiles.gridSpacing = 8; % was 4
config_fg.matFiles.patchSize = 16; % was 8

% Enable matlabpool? If so, enter how many cores.
config_fg.parallel.enable = config.parallel.enable;
config_fg.parallel.cores = config.parallel.cores;

% Auxillary variables
config_fg.flipSuffix = {'', '_f'};
config_fg.imageSets = {'tr', 'te'};

trainingfilepath = [config.outputFolder '/' name '/tr.mat' ];
trainingfileflippedpath = [config.outputFolder '/' name '/tr_f.mat' ];
trainingfilepath_fg =[config_fg.outputFolder '/' name_fg '/tr_fg.mat' ];
trainingfileflippedpath_fg = [config_fg.outputFolder '/' name_fg '/tr_f_fg.mat' ];
% the path where the list of each action training data exists
trainingfilegt = 'ground_truth/training/'; % ground truth

testfilepath = [config.outputFolder '/' name '/te.mat' ];
testfileflippedpath = [config.outputFolder '/' name '/te_f.mat' ];
testfilepath_fg =[config_fg.outputFolder '/' name_fg '/te_fg.mat' ];
testfileflippedpath_fg = [config_fg.outputFolder '/' name_fg '/te_f_fg.mat' ];
% the path where the list of each action test data exists
testfilegt='ground_truth/testing/'; % the path where the list of each action test data exists, fixme!!!!!!!!!
