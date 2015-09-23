function output_action_classes()
addpath '/scratch/jiadeng_fluxg/shared/hico_20150920/'
load anno_iccv.mat
fid = fopen('action_names.txt','w');
for i=1:length(list_action)
    action = list_action(i);
    fprintf(fid,'%s_%s\n', action.vname, action.nname);
end
fclose(fid);
end