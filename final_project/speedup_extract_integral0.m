function massive_extract_integral()
    if 1
        global sched
        sched= findResource('scheduler', 'type', 'mpiexec')
        set(sched, 'MpiexecFileName', '/home/software/rhel6/mpiexec/bin/mpiexec')
        set(sched, 'EnvironmentSetMethod', 'setenv') %the syntax for matlabpool must use the (sched, N) format
        matlabpool(sched,16);
    end
    addpath '/scratch/jiadeng_fluxg/shared/hico_20150920/'
    load anno_iccv.mat
    for i=1:50
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

        % load input .mat file
        data = load(savefile_fg);
        % Compile fg LLC histograms into a single mat file for use with algorithm
        fprintf('Extract integral image fg for %s %s, working on %d/%d\n', action.vname, action.nname, i, length(list_action));
        extract_integral_image(data, config_fg);
        fprintf('Integral image extraction finishes for %s %s: \n', action.vname, action.nname);
    end
    if(matlabpool('size')>0)
       matlabpool close;
    end

end
