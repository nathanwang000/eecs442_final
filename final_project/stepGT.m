function prepareGT(action)
% prepares ground truth for each action class
% action: one of the actions in list_action 
% helper function for prepareTrainTest.m
if nargin < 1
   synset = struct('id',1, 'wid','v02018049', 'name','board.v.01', ...
                   'count','6', 'syn','board get_on', ...
                   'def', 'get on board of (trains, buses, ships, aircraft, etc.)', ...
                   'ex', '');
   action = struct('nname', 'airplane', 'vname', 'board', 'vname_ing',...
                   'boarding', 'syn', 'board, get_on', 'def',...
                   'get on board of (trains, buses, ships, aircraft, etc.)',...
                   'synset', synset);
end

addpath(['/scratch/jiadeng_fluxg/shared/hico_20150920/']);
load anno_iccv.mat;

input_folder = '/scratch/jiadeng_fluxg/shared/hico_20150920/images';
fid_train = fopen(sprintf('ground_truth/training/%s_%s.txt', action.vname, action.nname),'w');
fid_test = fopen(sprintf('ground_truth/testing/%s_%s.txt', action.vname, action.nname),'w');

index = 0; 
for i=1:length(list_action)
    if isequal(list_action(i), action)
        index = i;
        break;
    end
end

if index
    % output test and train, use only example with label 1
    train_index = (anno_train(index,:) == 1);
    test_index = (anno_test(index,:) == 1);
    l_train = list_train(train_index);
    l_test = list_test(test_index);
    for i=1:length(l_train)
        fprintf(fid_train, '%s\n', l_train{i});
    end
    for i=1:length(l_test)
        fprintf(fid_test, '%s\n', l_test{i});
    end
else
    error('action class not found');
end

fclose(fid_train);
fclose(fid_test);
end