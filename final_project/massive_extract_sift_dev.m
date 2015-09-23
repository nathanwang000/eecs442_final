function massive_extract_sift()
    addpath '/scratch/jiadeng_fluxg/shared/hico_20150920/'
    load anno_iccv.mat
    for i=489%1:length(list_action)
        action = list_action(i);
        
        [config, config_fg, ...
        trainingpath, savefile, hi, name, testpath, ...
        trainingpath_fg, savefile_fg, hi_fg, name_fg, testpath_fg, ...
        trainingfilepath, trainingfileflippedpath, ...
        trainingfilepath_fg, trainingfileflippedpath_fg, ...
        trainingfilegt, ...
        testfilepath, testfileflippedpath, ...
        testfilepath_fg, testfileflippedpath_fg, ...
        testfilegt] = smallConfig_dev(action);

        % generate input .mat file
        % generate_matinputfile(trainingpath, savefile, hi, name, testpath);
        data = load(savefile);
        tic
        %Extract Grayscale SIFT descriptors
        fprintf('Extract sift for %s %s, working on %d/%d\n', action.vname, action.nname, i, length(list_action));
        extractSIFT_dev(data, config);
        fprintf('SIFT extraction finishes for %s %s: \n', action.vname, action.nname);
        toc
    end

end