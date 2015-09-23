% background feature extraction
% This file contains the configuration for SIFT feature extraction, LLC
% coding, dictionary size etc. The defaults are those used in our 
% CVPR2011 work. These can be modified as necessary.

createConfiguration;

% generate input .mat file

generate_matinputfile(trainingpath, savefile, hi, name, testpath);
data = load(savefile);


%Extract Grayscale SIFT descriptors
extractSIFT(data, config); % change this to caffe output

% Generate dictionary for LLC using randomly sampled training images%%
config.dictionary.data = generateDictionary(data, config);


% Generate LLC histograms for all SIFT descriptors
extractLLC(data, config);

% Compile LLC histograms into a single mat file for use with algorithm
createMatFilesBg(data, config);

clear all;

% foreground feature extraction
createConfiguration;
config = config_fg;

% input .mat file
generate_matinputfile_fg(trainingpath_fg, savefile_fg, hi_fg, name_fg, testpath_fg);
data = load(savefile_fg);

% Extract Grayscale SIFT descriptors
extractSIFT(data, config); % change this to caffe output

% dictionary for LLC using randomly sampled training images
config.dictionary.data = generateDictionary(data, config);
% Generate LLC histograms for all SIFT descriptors
extractLLC(data, config);

% Compile LLC histograms into a single mat file for use with algorithm
createMatFilesFg(data, config);

% generate .txt binary feature file
generate_idsfile(trainingpath);
generate_idsfile_fg(trainingpath_fg);

% the arguments here do not make sense at all, haha :(
outputBinaryFeature(0, 'train', 'notflipped', trainingfilepath, trainingfileflippedpath, trainingfilepath_fg, trainingfileflippedpath_fg, trainingfilegt);
outputBinaryFeature(0, 'train', 'flipped', trainingfilepath, trainingfileflippedpath, trainingfilepath_fg, trainingfileflippedpath_fg, trainingfilegt);

%train random forest
dttrain();

