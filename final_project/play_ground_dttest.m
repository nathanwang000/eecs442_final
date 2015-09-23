function play_ground_dttest()

addpath '/scratch/jiadeng_fluxg/shared/hico_20150920/'
load anno_iccv.mat
global anno_test; global anno_train; global list_action; global list_test; global list_train;

%action = list_action(target);

% renaming and deleting empty trees
% system(sprintf('bash /scratch/jiadeng_fluxg/jiaxuan/trees/del_empty_trees_%s_%s.sh', action.vname, action.nname));
% evaluation(action);
for target=301:600
    save_result(target);
end
end