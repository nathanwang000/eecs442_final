function generate_matinputfile(trainingpath, savefile, hi, name, testpath)

[fid,msg] = fopen(trainingpath); % training data path

tline = fgetl(fid); % read line by line
str = 'randomstring';
count = 0; % count for total number of images
result = []; % struct of photo names

while ischar(tline)
    count = count + 1;
    % c = {strcat(tline,'.jpg'), str(1:0)};
    c = {tline, str(1:0)};
    f = {'filename', 'folder'};
    anno_sub = cell2struct(c,f,2); % create key value pair of the form {filename: '2010_00*.jpg', folder: 'randomstring'(1:0)}
    c_annotation_sub = {anno_sub};
    f_annotation_sub = {'annotation'};
    annotation = cell2struct(c_annotation_sub,f_annotation_sub,2);
    result = [result annotation];
    tline = fgetl(fid);
    fprintf('finishes %d of generating training files\n', count);
end

fprintf('number of training/val data is %d\n', count);
tr = struct(result);
fclose(fid);

disp(testpath);
[fid,msg] = fopen(testpath);  % test data path

tline = fgetl(fid);

str = 'randomstring';
count = 0;
result = [];
while ischar(tline)
    count = count + 1;
    c = {tline, str(1:0)};
    f = {'filename', 'folder'};
    anno_sub = cell2struct(c,f,2);
    c_annotation_sub = {anno_sub};
    f_annotation_sub = {'annotation'};
    annotation = cell2struct(c_annotation_sub,f_annotation_sub,2);

    result = [result annotation];

    tline = fgetl(fid);
    fprintf('finishes %d of generating test files\n', count);
end

fprintf('number of test data is %d\n', count);
te = struct(result);
fclose(fid);

save(savefile, 'hi', 'name', 'tr', 'te');

end

