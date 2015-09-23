function massive_createMatFilesBg_dev()
    % this is development version where I only use action(1)
%    if 1
%        global sched
%        sched= findResource('scheduler', 'type', 'mpiexec')
%        set(sched, 'MpiexecFileName', '/home/software/rhel6/mpiexec/bin/mpiexec')
%        set(sched, 'EnvironmentSetMethod', 'setenv') %the syntax for matlabpool must use the (sched, N) format
%    end
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

        % load input .mat file
        data = load(savefile);
        % Compile LLC histograms into a single mat file for use with algorithm
        tic
        createMatFilesBg(data, config);
        fprintf('combining LLC: ');
        toc
    end
end