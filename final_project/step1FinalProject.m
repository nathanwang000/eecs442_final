function step1FinalProject(action)
% assumptions: 
% 1. sift is already extracted, if not run massive_extract_sift first
% 2. input file already generated and saved in savefile, if not run massive_extract_sift first
% 3. dictionary is already learned, if not run gen_dict.m
[config, config_fg, ...
 trainingpath, savefile, hi, name, testpath, ...
 trainingpath_fg, savefile_fg, hi_fg, name_fg, testpath_fg, ...
 trainingfilepath, trainingfileflippedpath, ...
 trainingfilepath_fg, trainingfileflippedpath_fg, ...
 trainingfilegt, ...
 testfilepath, testfileflippedpath, ...
 testfilepath_fg, testfileflippedpath_fg, ...
 testfilegt] = smallConfig_dev(action); % development version, use smallConfig(action) for production

if config.parallel.enable
    global sched
    sched= findResource('scheduler', 'type', 'mpiexec')
    set(sched, 'MpiexecFileName', '/home/software/rhel6/mpiexec/bin/mpiexec')
    set(sched, 'EnvironmentSetMethod', 'setenv') %the syntax for matlabpool must use the (sched, N) format
end

% load input .mat file
data = load(savefile); % has fields hi, name, tr, te

tic
% Generate LLC histograms for all SIFT descriptors
extractLLC(data, config);
fprintf('Time stats for LLC pooling is');
toc

% Compile LLC histograms into a single mat file for use with algorithm
tic
createMatFilesBg(data, config);
fprintf('Time stats for combining LLC is');
toc

clear all;

global sched
sched= findResource('scheduler', 'type', 'mpiexec')
set(sched, 'MpiexecFileName', '/home/software/rhel6/mpiexec/bin/mpiexec')
set(sched, 'EnvironmentSetMethod', 'setenv') %the syntax for matlabpool must use the (sched, N) format

% foreground feature extraction
smallConfig;
config = config_fg;

tic
% input .mat file
generate_matinputfile_fg(trainingpath_fg, savefile_fg, hi_fg, name_fg, testpath_fg);
data = load(savefile_fg);
fprintf('Time stats for generate input file for foreground is');
toc

tic
% dictionary for LLC using randomly sampled training images
config.dictionary.data = generateDictionary(data, config);
fprintf('Time stats for dictionary learning foreground is');
toc

tic
% Generate LLC histograms for all SIFT descriptors
extractLLC(data, config)
fprintf('Time stats for LLC foreground is');
toc

tic
% Compile LLC histograms into a single mat file for use with algorithm
createMatFilesFg(data, config);
fprintf('Time stats for combining LLC is');
toc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tic
% generate .txt binary feature file
generate_idsfile(trainingpath);
generate_idsfile_fg(trainingpath_fg);
fprintf('Time stats for ids generation is');
toc

tic
outputBinaryFeature(0, 'train', 'notflipped', trainingfilepath, trainingfileflippedpath, trainingfilepath_fg, trainingfileflippedpath_fg, trainingfilegt);
if config.includeFlippedImages
  outputBinaryFeature(0, 'train', 'flipped', trainingfilepath, trainingfileflippedpath, trainingfilepath_fg, trainingfileflippedpath_fg, trainingfilegt);
end
fprintf('Time stats for outputBinary feature is');
toc

% run to here!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
tic
%train random forest
if(config.parallel.enable && matlabpool('size')==0)
  global sched
  matlabpool(sched, config.parallel.cores);
end
parfor i=1:config.parallel.cores % 16 core
  dttrain(7);
end
fprintf('Time stats for training a random forest is');
toc

end
