function generate_idsfile(config, name, trainingpath)

[fid,msg] = fopen(trainingpath);
tline = fgetl(fid);
str = 'randomstring';
count = 0;
result = [];

while ischar(tline)
    count = count + 1;
    tline = fgetl(fid);
end

ids_bg = cell(count,1);
fclose(fid);
count = 0;
[fid,msg] = fopen(trainingpath);
tline = fgetl(fid);
savefile = [config.outputFolder '/' name '/ids_bg.mat'];
while ischar(tline)
    count = count + 1;
    c = tline;
    %fprintf('the generated ids line is %d\n', c);
    disp(c);
    ids_bg{count,1}=c; % c is of the form 2010_006088
    tline = fgetl(fid);
end

fprintf('number of training/val data is %d\n', count);


fclose(fid);

make_dir(savefile);
save(savefile, 'ids_bg');
end
