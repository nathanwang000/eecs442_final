function searchAction(vname, nname)
% a helper function to find the index of the function
    load '/scratch/jiadeng_fluxg/shared/hico_20150920/anno_iccv.mat' % change this to dataset folder as needed
    for i=1:length(list_action)
        action = list_action(i);
        if strcmp(vname,action.vname) && strcmp(nname,action.nname)
            fprintf('action found, the index is %d\n', i);
            return;
        end
    end
    fprintf('action not found\n');
end