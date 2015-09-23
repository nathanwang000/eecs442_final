function checkfiles()
load ../dataset_20150331/anno_iccv.mat;
for i=1:length(list_action)
   a = list_action(i);
   if (~exist(sprintf('train_files/train_%s_%s.txt', a.vname, a.nname),'file'))
      error(sprintf('train_files/train_%s_%s.txt does not exist', a.vname, a.nname));
   end
   if (~exist(sprintf('test_files/test_%s_%s.txt', a.vname, a.nname),'file'))
      error(sprintf('test_files/test_%s_%s.txt does not exist', a.vname, a.nname));
   end
   fprintf('i=%d\n', i);
end
fprintf('success!\n');
end