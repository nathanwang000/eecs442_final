function llc26()
    if 1
        global sched
        sched= findResource('scheduler', 'type', 'mpiexec')
        set(sched, 'MpiexecFileName', '/home/software/rhel6/mpiexec/bin/mpiexec')
        set(sched, 'EnvironmentSetMethod', 'setenv') %the syntax for matlabpool must use the (sched, N) format
        matlabpool(sched, 10);
    end

    addpath '/scratch/jiadeng_fluxg/shared/hico_20150920/'
    load anno_iccv.mat
    for i=501:520
        action = list_action(i);
        
        [config, config_fg, ...
        trainingpath, savefile, hi, name, testpath, ...
        trainingpath_fg, savefile_fg, hi_fg, name_fg, testpath_fg, ...
        trainingfilepath, trainingfileflippedpath, ...
        trainingfilepath_fg, trainingfileflippedpath_fg, ...
        trainingfilegt, ...
        testfilepath, testfileflippedpath, ...
        testfilepath_fg, testfileflippedpath_fg, ...
        testfilegt] = smallConfig(action);

        % get dictionary, assumption: 
        % 1. dicitonary already learned, if not run gen_dict.m and change the data.name appropriately
        dictionarySize = config.dictionary.size;
        config.dictionary.data = load([config.outputFolder '/dictionary_action_general_Classification' num2str(dictionarySize) '.mat']); 
        % generate input .mat file
        generate_matinputfile(trainingpath, savefile, hi, name, testpath);
        data = load(savefile);
        tic

        % Generate LLC histograms for all SIFT descriptors
        fprintf('Extract LLC for %s %s, working on %d/%d\n', action.vname, action.nname, i, length(list_action));
        extractLLC(data, config);
        fprintf('LLC extraction finishes for %s %s: \n', action.vname, action.nname);
        toc
    end

    if(matlabpool('size')>0)
        matlabpool close;
    end

end
