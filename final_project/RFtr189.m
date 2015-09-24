function RFtr189()
  tic
    addpath '/scratch/jiadeng_fluxg/shared/hico_20150920/'
    load anno_iccv.mat
    for i=377:378
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
        
        fprintf('train RF on %s %s, working on %d/%d\n', action.vname, action.nname, i, length(list_action));
        % deleting existing trees
        system(sprintf('rm /scratch/jiadeng_fluxg/jiaxuan/trees/%s_%s/*', action.vname, action.nname));
        % make the directory if not exist
        system(sprintf('mkdir -p /scratch/jiadeng_fluxg/jiaxuan/trees/%s_%s/', action.vname, action.nname));

                
        TreeNum = 30;
        dttrain(TreeNum, Datafilename, DatafilenameFlipped, [action.vname, '_' ,action.nname]);

    end

toc
end
