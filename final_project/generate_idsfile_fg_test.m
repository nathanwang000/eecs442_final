function generate_idsfile_fg_test(config, name, testpath)

[fid,msg] = fopen(testpath);

tline = fgetl(fid);
str = 'randomstring';
count = 0;
result = [];

while ischar(tline)

count = count + 1;

tline = fgetl(fid);

end
fclose(fid);


ids_fg_test = cell(count,1);
savefile = [config.outputFolder '/' name '/ids_fg_test.mat'];

[fid,msg] = fopen(testpath);

tline = fgetl(fid);
count = 0;

while ischar(tline)
    count = count + 1;
    c = tline; % was 1:end-6
    
    ids_fg_test{count,1}=c;
    tline = fgetl(fid);
end

fprintf('number of test fg data is %d\n', count);


fclose(fid);


save(savefile, 'ids_fg_test');
end
