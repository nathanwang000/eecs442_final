function genDatasetName()
addpath '/scratch/jiadeng_fluxg/shared/hico_20150920'
load anno_iccv

fid = fopen('/home/jiaxuan/eecs442final_project/DatasetName.txt','w');
for i=1:length(list_action)
    action = list_action(i);
    fwrite(fid,sprintf('%s_%s\n',action.vname,action.nname));
end
fclose(fid);

end