function gen_input_file_general()

        trainingpath = 'train_files/train_action_general.txt'; % need to be generated from prepareGeneral.m, not written yet for this part
        testpath = 'test_files/test_action_general.txt'; % need to be generated from prepareGeneral.m, not written yet for this part
        savefile = sprintf('/scratch/jiadeng_fluxg/jiaxuan/datasets/action_general_dataset.mat');
        hi = '/scratch/jiadeng_fluxg/shared/hico_20150920/images/';
        name = 'general';
        % generate input .mat file
        generate_matinputfile(trainingpath, savefile, hi, name, testpath);

end
