function prepareTrainTest()
    % prepares training and testing files by loading from anno_iccv.mat for each
    % class seperately, details see step0small.m
    addpath(['/scratch/jiadeng_fluxg/shared/hico_20150920']);
    load anno_iccv.mat;
    for i=1:length(list_action)
        action = list_action(i);
        fprintf('preparing training and test files for %s %s\n', action.vname, action.nname);
        step0small(action);
        fprintf('%d/%d completed\n',i,length(list_action));
    end

end