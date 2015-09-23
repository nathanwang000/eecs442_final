function generate_idsfile_test(config, name, testpath)

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


ids_bg_test = cell(count,1);
savefile = [config.outputFolder '/' name '/ids_bg_test.mat'];
[fid,msg] = fopen(testpath);
tline = fgetl(fid);
count = 0;
while ischar(tline)
    count = count + 1;
    c = tline;
    %disp(c);
    ids_bg_test{count,1}=c;
    tline = fgetl(fid);
end

fprintf('number of test data is %d\n', count);


fclose(fid);

save(savefile, 'ids_bg_test');
end
