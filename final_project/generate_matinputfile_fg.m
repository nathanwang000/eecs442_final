function generate_matinputfile_fg(trainingpath, savefile, hi, name, testpath)


[fid,msg] = fopen(trainingpath);

tline = fgetl(fid);
str = 'randomstring';
count = 0;
result = [];

while ischar(tline)

%disp(tline);
count = count + 1;


c = {strcat(tline), str(1:0)};
f = {'filename', 'folder'};
anno_sub = cell2struct(c,f,2);
c_annotation_sub = {anno_sub};
f_annotation_sub = {'annotation'};
annotation = cell2struct(c_annotation_sub,f_annotation_sub,2);


result = [result annotation];

tline = fgetl(fid);

end

fprintf('number of training/val data is %d\n', count);
tr = struct(result);


fclose(fid);

[fid,msg] = fopen(testpath);

tline = fgetl(fid);
str = 'randomstring';
count = 0;
result = [];

while ischar(tline)

%disp(tline);
count = count + 1;



c = {strcat(tline), str(1:0)};
f = {'filename', 'folder'};
anno_sub = cell2struct(c,f,2);
c_annotation_sub = {anno_sub};
f_annotation_sub = {'annotation'};
annotation = cell2struct(c_annotation_sub,f_annotation_sub,2);


result = [result annotation];

tline = fgetl(fid);

end

fprintf('number of test data is %d\n', count);
te = struct(result);


fclose(fid);


save(savefile, 'hi', 'name', 'tr', 'te');

end
