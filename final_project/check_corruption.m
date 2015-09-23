function corrupted = check_corruption(folder)
    % this script checks corruption of files in folder
    contents = dir(folder);
    corrupted = [];
    for i=1:length(contents)
        file = contents(i);
        if ~file.isdir
            try
                a = load([folder '/' file.name]);
            catch
                fprintf('%s is corrupted\n', [folder '/' file.name]);
                corrupted = [corrupted [folder '/' file.name]];
            end
            fprintf('checked %d/%d\n', i, length(contents));
        end
    end
	fprintf('total %d/%d files corrupted\n', length(corrupted), length(contents));
    save('list_corruption.mat', 'corrupted');
end

function delCorruptedFiles()
    load('list_corruption.mat');
    for i=1:length(corrupted)
	delete(corrupted{i});
    end
end

function recheck()
    corrupted = [];
    prev_corrupted = load('list_corruption.mat');
    for i=1:length(prev_corrupted)
        file = prev_corrupted(i)
        try
             load(i);
        catch
      	     fprintf('%s is corrupted\n', file);
             corrupted = [corrupted file];
        end
             fprintf('checked %d/%d\n', i, length(prev_corrupted));
    end
    fprintf('total %d/%d files corrupted\n', length(corrupted), length(prev_corrupted));
    save('list_corruption.mat', 'corrupted');
end
