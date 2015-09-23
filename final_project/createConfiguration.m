%background
config.includeFlippedImages = 1;

% Grayscale SIFT
config.SIFT.imageSize = 0;
config.SIFT.gridSpacing = 4;

config.SIFT.patchSize = [8 12 16 24 30];
config.SIFT.sigmaEdge = 0.8;

% Dictionary learning
config.dictionary.size = 1024;
config.dictionary.numImages = 4000; % Number of images to sample;
config.dictionary.numDescriptors = 4e6; % Maximum number of descriptors to 
                                        % use for dictionary learning
% LLC coding
config.LLC.knn = 5;

% Mat file variables
config.matFiles.gridSpacing = 4;
config.matFiles.patchSize = 8;

% Enable matlabpool? If so, enter how many cores.
config.parallel.enable = 1;
config.parallel.cores = 16;

% Auxillary variables
config.flipSuffix = {'', '_f'};
config.imageSets = {'tr', 'te'};

%%%trainingpath = 'randomforest/llc_extraction/VOC2011ori/TrainVal/VOCdevkit/VOC2011/ImageSets/Action/trainval.txt'; % the list of training data(background)
trainingpath = '../trainval/VOCdevkit/VOC2010/ImageSets/Action/trainval.txt';

savefile = 'VOCActionDataset.mat'; % file name of the dataset
%%%hi = 'randomforest/images/JPEGImages'; % path where training and test images exist
hi = '../trainval/VOCdevkit/VOC2010/JPEGImages';
name = 'VOC Action Classification'; % name of dataset
%%%testpath = 'randomforest/llc_extraction/VOC2011ori/Test/VOCdevkit/VOC2011/ImageSets/Action/test.txt';% the list of test data(background)
testpath = '../test/VOCdevkit/VOC2010/ImageSets/Action/test.txt';

config.outputFolder = 'savefeature_bg';% the output path to save the feature extracton result for background feature


%foreground 

% Folder where SIFT descriptors/LLC histograms/final files are output
config_fg.outputFolder = 'savefeature_fg'; % the output path to save the feature extracton result for foreground feature

% generate input .mat file
%%%trainingpath_fg = 'randomforest/llc_extraction/train_fg.txt';% the list of training data(foreground)
trainingpath_fg = 'train_fg.txt';
savefile_fg = 'VOCActionDatasetfg.mat';% file name of the dataset
%%%hi_fg ='randomforest/llc_extraction/dataset_fg';% path where training and test images exist
hi_fg = ''; % relative to  dataset_fg
name_fg ='VOC Action Classification fg';% name of dataset 
%%%testpath_fg ='randomforest/llc_extraction/test_fg.txt';% the list of test data(foreground)
testpath_fg = 'test_fg.txt';


%foreground parameter configuration

config_fg.includeFlippedImages = 1;

% Grayscale SIFT
config_fg.SIFT.imageSize = 300; 
config_fg.SIFT.gridSpacing = 4;
config_fg.SIFT.patchSize = [8 12 16 24 30];
config_fg.SIFT.sigmaEdge = 0.8;

% Dictionary learning
config_fg.dictionary.size = 1024; % was 1024
config_fg.dictionary.numImages = 4000; % Number of images to sample; was 4000
config_fg.dictionary.numDescriptors = 4e6; % Maximum number of descriptors to was 4e6
                                        % use for dictionary learning
% LLC coding
config_fg.LLC.knn = 5;

% Mat file variables
config_fg.matFiles.gridSpacing = 4;
config_fg.matFiles.patchSize = 8;

% Enable matlabpool? If so, enter how many cores.
config_fg.parallel.enable = 1;
config_fg.parallel.cores = 16;

% Auxillary variables
config_fg.flipSuffix = {'', '_f'};
config_fg.imageSets = {'tr', 'te'};

trainingfilepath = [config.outputFolder '/' name '/tr.mat' ];
trainingfileflippedpath = [config.outputFolder '/' name '/tr_f.mat' ];
trainingfilepath_fg =[config_fg.outputFolder '/' name_fg '/tr.mat' ];
trainingfileflippedpath_fg = [config_fg.outputFolder '/' name_fg '/tr_f.mat' ];
%%%trainingfilegt='randomforest/llc_extraction/VOC2011ori/TrainVal/VOCdevkit/VOC2011/ImageSets/Action/'; % the path where the list of each action training data exists
trainingfilegt = '../trainval/VOCdevkit/VOC2010/ImageSets/Action/'; % ground truth

testfilepath = [config.outputFolder '/' name '/te.mat' ];
testfileflippedpath = [config.outputFolder '/' name '/te_f.mat' ];
testfilepath_fg =[config_fg.outputFolder '/' name_fg '/te.mat' ];
testfileflippedpath_fg = [config_fg.outputFolder '/' name_fg '/te_f.mat' ];
%%%testfilegt='randomforest/llc_extraction/testlabels/Action/'; % the path where the list of each action test data exists
testfilegt='../test/VOCdevkit/VOC2010/ImageSets/Action/'; % the path where the list of each action test data exists
