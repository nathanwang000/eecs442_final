function genDir()
    addpath '/scratch/jiadeng_fluxg/shared/hico_20150920/'
    load anno_iccv.mat
    basefolder = '/scratch/jiadeng_fluxg/jiaxuan/trees/';
    for i=1:length(list_action)
        action = list_action(i);
        fprintf([basefolder, action.vname, '_', action.nname '/\n']);
        mkdir([basefolder, action.vname, '_', action.nname '/']);
	delete([basefolder, action.vname, '_', action.nname '/*'])
    end
end