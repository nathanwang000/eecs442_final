function []=smallLLC(outputName) 
action = struct('nname','general','vname', 'action'); 
[config, config_fg, ...
 trainingpath, savefile, hi, name, testpath, ...
 trainingpath_fg, savefile_fg, hi_fg, name_fg, testpath_fg, ...
 trainingfilepath, trainingfileflippedpath, ...
 trainingfilepath_fg, trainingfileflippedpath_fg, ...
 trainingfilegt, ...
 testfilepath, testfileflippedpath, ...
 testfilepath_fg, testfileflippedpath_fg, ...
 testfilegt] = smallConfig(action);

inputFolder = [config.outputFolder '/fullSift']; 
[path,name,ext] = fileparts(outputName);
outputFolder = [config.outputFolder 'fullLlc_' num2str(config.dictionary.size) '/'];

outputFile = [outputFolder name '.mat'];
inputFile = ['/scratch/jiadeng_fluxg/jiaxuan/savefeature/fullSift/' name '.mat'];

fprintf('generate llc with input: %s\noutput: %s\n', inputFile, outputFile);
% 1. dicitonary already learned, if not run gen_dict.m and change the data.name appropriately
dictionarySize = config.dictionary.size;
config.dictionary.data = load([config.outputFolder '/dictionary_action_general_Classification' num2str(dictionarySize) '.mat']); 

try
    dictionary = config.dictionary.data.dictionary;
catch
    dictionary = config.dictionary.data;
end

%if(~exist(outputFile, 'file'))
    make_dir(outputFile);
    try
        siftData = load(inputFile); % use try catch here!
        siftData.data;
    catch
        smallSift(inputFile);
        siftData = load(inputFile); % use try catch here!
    end
    llcHist = cellfun(@(x) sparse(LLC_coding_appr(dictionary, x, config.LLC.knn)), siftData.data, 'UniformOutput', false);
    saveFileFunc(outputFile, llcHist, siftData.x, siftData.y, siftData.patchSizes, siftData.hgt, siftData.wid);
    %end

end