function RFte295()    
    addpath '/scratch/jiadeng_fluxg/shared/hico_20150920/'
    load anno_iccv.mat
    for i=589:590
        action = list_action(i);
        fprintf('test_RF on %s %s, working on %d/%d\n', action.vname, action.nname, i, length(list_action));
        % renaming and deleting empty trees
        % system(sprintf('bash /scratch/jiadeng_fluxg/jiaxuan/trees/del_empty_trees_%s_%s.sh', action.vname, action.nname));
        evaluation(action);
    end
end
