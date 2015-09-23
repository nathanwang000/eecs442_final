function massive_train_RF(num)
  tic
    if 1
        global sched
        sched= findResource('scheduler', 'type', 'mpiexec')
        set(sched, 'MpiexecFileName', '/home/software/rhel6/mpiexec/bin/mpiexec')
        set(sched, 'EnvironmentSetMethod', 'setenv') %the syntax for matlabpool must use the (sched, N) format
        matlabpool(sched, 16);
    end
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
        
        fprintf('train RF on %s %s, working on %d/%d\n', action.vname, action.nname, i, length(list_action));
        % deleting existing trees
        system(sprintf('rm /scratch/jiadeng_fluxg/jiaxuan/trees/%s_%s/*', action.vname, action.nname));
                
        TreeNum = 32;
        NumCores = 16;
        remain = mod(TreeNum, NumCores);
        eachTree = floor(TreeNum/NumCores);
        parfor i=1:NumCores
            dttrain(eachTree, Datafilename, DatafilenameFlipped, [action.vname, '_' ,action.nname]);
        end
        % dttrain(remain, Datafilename, DatafilenameFlipped); % just omit a few files for efficiency
    end
    
    if(matlabpool('size')>0)
       matlabpool close;
    end
toc
end