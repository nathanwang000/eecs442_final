function [dic] = gen_dict()
    load /scratch/jiadeng_fluxg/shared/hico_20150920/anno_iccv.mat; 
    action = struct('nname','general','vname', 'action'); 
    
    [config, config_fg, ...
    trainingpath, savefile, hi, name, testpath, ...
    trainingpath_fg, savefile_fg, hi_fg, name_fg, testpath_fg, ...
    trainingfilepath, trainingfileflippedpath, ...
    trainingfilepath_fg, trainingfileflippedpath_fg, ...
    trainingfilegt, ...
    testfilepath, testfileflippedpath, ...
    testfilepath_fg, testfileflippedpath_fg, ...
    testfilegt] = smallConfig_dev(action); %intentional use of dev as parrallel not needed

    % generate input .mat file for general
    fprintf('generateInputfile for %s %s, working on %d/%d\n', action.vname, action.nname, i, length(list_action));
    generate_matinputfile(trainingpath, savefile, hi, name, testpath);
    fprintf('generateInputfile finishes for %s %s: \n', action.vname, action.nname);

    data = load(savefile); % has fields hi, name, tr, te

    % Generate dictionary for LLC using randomly sampled training images%%
    tic
    config.dictionary.data = generateDictionary(data, config);
    fprintf('Time stats for gen_dict is');
    toc
end
