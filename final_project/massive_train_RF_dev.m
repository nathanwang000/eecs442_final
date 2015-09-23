function massive_train_RF_dev(num)
  tic

    addpath '/scratch/jiadeng_fluxg/shared/hico_20150920/'
    load anno_iccv.mat
    for i=num%1:length(list_action)
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
    
        Datafilename = sprintf('/scratch/jiadeng_fluxg/jiaxuan/RF_related/trainval_0_%s_%s.txt', action.vname, action.nname);
        DatafilenameFlipped = sprintf('/scratch/jiadeng_fluxg/jiaxuan/RF_related/trainval_0_%s_%s_flipped.txt', action.vname, action.nname);
        
            dttrain(eachTree, Datafilename, DatafilenameFlipped, [action.vname, '_' ,action.nname]);

        % dttrain(remain, Datafilename, DatafilenameFlipped); % just omit a few files for efficiency
    end
    

toc
end