function play_ground_dttrain()

addpath '/scratch/jiadeng_fluxg/shared/hico_20150920/'
load anno_iccv.mat
action = list_action(489);

 [config, config_fg, ...
  trainingpath, savefile, hi, name, testpath, ...
  trainingpath_fg, savefile_fg, hi_fg, name_fg, testpath_fg, ...
  trainingfilepath, trainingfileflippedpath, ...
  trainingfilepath_fg, trainingfileflippedpath_fg, ...
  trainingfilegt, ...
  testfilepath, testfileflippedpath, ...
  testfilepath_fg, testfileflippedpath_fg, ...
  testfilegt] = smallConfig(action);
    
  Datafilename = sprintf('/scratch/jiadeng_fluxg/jiaxuan/RF_related/trainval_0_%s_%s.txt', action.vname, action.nname);
  DatafilenameFlipped = sprintf('/scratch/jiadeng_fluxg/jiaxuan/RF_related/trainval_0_%s_%s_flipped.txt', action.vname, action.nname);

  % deleting existing trees
  system(sprintf('rm /scratch/jiadeng_fluxg/jiaxuan/trees/%s_%s/*', action.vname, action.nname));
  
  dttrain(1,Datafilename, DatafilenameFlipped, [action.vname '_' action.nname]);

end