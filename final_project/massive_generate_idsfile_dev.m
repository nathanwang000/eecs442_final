function massive_generate_idsfile_dev()
    % no parallel b/c there is no parallel code, could write one using
    % parfor here, dev for only action(1)
    addpath '/scratch/jiadeng_fluxg/shared/hico_20150920/'
    load anno_iccv.mat
    for i=[489]
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
    
        % generate .txt binary feature file
        %tic
        %generate_idsfile(config, name, trainingpath);
        %generate_idsfile_fg(config_fg, name_fg, trainingpath_fg);
        %fprintf('Time stats for ids generation is');
        %toc
        
        % output binary features
        tic % debuged to here
        super_outputBinaryFeature(config, config_fg, name, name_fg, action, 0, 'train', 'notflipped', trainingfilepath, trainingfileflippedpath, trainingfilepath_fg, trainingfileflippedpath_fg, trainingfilegt);
        if config.includeFlippedImages
            super_outputBinaryFeature_dev(config, config_fg, name, name_fg, action, 0, 'train', 'flipped', trainingfilepath, trainingfileflippedpath, trainingfilepath_fg, trainingfileflippedpath_fg, trainingfilegt);
        end
        fprintf('Time stats for outputBinary feature is');
        toc        

    end

end