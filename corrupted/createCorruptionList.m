function createCorruptionList()
    % create corruption list form txt file, save in list_corruption.mat
    corrupted = {};
    fid = fopen('corrupted_list.txt');
    tline = fgetl(fid);
    while ischar(tline)
       corrupted = [corrupted tline];
       tline = fgetl(fid);
    end
    fclose(fid);
    save('list_corruption.mat', 'corrupted');
end