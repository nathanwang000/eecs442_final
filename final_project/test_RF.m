clear all;
createConfiguration;

tic
% generate .txt binary feature file
generate_idsfile_test(testpath);
generate_idsfile_fg_test(testpath_fg);
fprintf('Time stats for generate ids for testing is');
toc

tic
outputBinaryFeature(0, 'test', 'notflipped', testfilepath, testfileflippedpath, testfilepath_fg, testfileflippedpath_fg, testfilegt);
%outputBinaryFeature(0, 'test', 'flipped', testfilepath, testfileflippedpath, testfilepath_fg, testfileflippedpath_fg, testfilegt);
fprintf('Time stats for outputBinary feature for testing is');
toc

tic
%evaluate random forest
evaluation
fprintf('Time stats for evaluation is');
toc
