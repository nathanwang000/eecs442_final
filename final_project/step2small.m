function step2FinalProject(action)
clear all;
addpath '/scratch/jiadeng_fluxg/shared/hico_20150920/'
load anno_iccv.mat

[config, config_fg, ...
 trainingpath, savefile, hi, name, testpath, ...
 trainingpath_fg, savefile_fg, hi_fg, name_fg, testpath_fg, ...
 trainingfilepath, trainingfileflippedpath, ...
 trainingfilepath_fg, trainingfileflippedpath_fg, ...
 trainingfilegt, ...
 testfilepath, testfileflippedpath, ...
 testfilepath_fg, testfileflippedpath_fg, ...
 testfilegt] = smallConfig_dev(action); % development version, use smallConfig(action) for production

% generate .txt binary feature file
generate_idsfile_test(config, name, testpath);
generate_idsfile_fg_test(config_fg, name_fg, testpath_fg);

%runto here!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
outputBinaryFeature_dev(config, config_fg, name, name_fg, action, 0, 'test', 'notflipped', testfilepath, testfileflippedpath, testfilepath_fg, testfileflippedpath_fg, testfilegt); % dev is deliberate here, do not delete it
%outputBinaryFeature_dev(0, 'test', 'flipped', testfilepath, testfileflippedpath, testfilepath_fg, testfileflippedpath_fg, testfilegt);


%train random forest
evaluation
end