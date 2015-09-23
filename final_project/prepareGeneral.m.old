function prepareGeneral()
    % prepares training and testing files by loading from anno_iccv.mat for each
    % class seperately, details see step0small.m
    addpath(['/scratch/jiadeng_fluxg/shared/hico_20150920/']);
    load anno_iccv.mat;

    fprintf('preparing training and test files for action general\n');
    
    input_folder = '/scratch/jiadeng_fluxg/shared/hico_20150920/images';
    fid_train = fopen('train_files/train_action_general.txt','w');
    fid_test = fopen('test_files/test_action_general.txt','w');

    % output test and train, exclude 0 for training
    for i=1:length(list_train)
        fprintf(fid_train, '%s\n', list_train{i});
    end
    for i=1:length(list_test)
        fprintf(fid_test, '%s\n', list_test{i});
    end

    fclose(fid_train);
    fclose(fid_test);
    fprintf('completed\n');

end