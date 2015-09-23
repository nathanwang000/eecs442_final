function output_proportion()
% output name total_train train_proportion total_test test_proportion
addpath '/scratch/jiadeng_fluxg/shared/hico_20150920/'
load anno_iccv.mat
fid = fopen('action_proportion.txt','w');
for i=1:length(list_action)
    action = list_action(i);
    total_train = sum(anno_train(i,:) ~= 0);
    train_proportion = sum(anno_train(i,:) == 1) / total_train;
    total_test = sum(anno_test(i,:) ~= 0);
    test_proportion = sum(anno_test(i,:) == 1) / total_test;
    fprintf(fid, '%s_%s %d %f %d %f\n', action.vname, action.nname, total_train, train_proportion, total_test, test_proportion);
    fprintf('done for %d/600\n', i);
end
fclose(fid);
end