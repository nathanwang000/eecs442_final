function outputBinaryFeature(divide2, traintest, flipped, filepath, fileflippedpath, filepath_fg, fileflippedpath_fg, filegt)

if strcmp(traintest, 'train')
    load 'ids_fg.mat';
    load  'ids_bg.mat';
    imageset = 'trainval'; 
elseif strcmp(traintest, 'test')
    load 'ids_fg_test.mat';
    load  'ids_bg_test.mat';
    imageset = 'test';
end

divide2 = 0; % what's point in putting this variable here???

disp('loading bg data');

if strcmp(traintest, 'train')
    if strcmp(flipped, 'notflipped')
        bg = load([filepath]);
    elseif strcmp(flipped, 'flipped')
        bg = load([fileflippedpath]);
    end
elseif strcmp(traintest, 'test') 
    
    if strcmp(flipped, 'notflipped')
        bg = load([filepath]);
    elseif strcmp(flipped, 'flipped')
        bg = load([fileflippedpath]);
    end
end
disp('loading fg data');

if strcmp(traintest, 'train')
    if strcmp(flipped, 'notflipped')
        fg = load([filepath_fg]);
    elseif strcmp(flipped, 'flipped')
        fg = load([fileflippedpath_fg]);
    end
elseif strcmp(traintest, 'test') 
    
    if strcmp(flipped, 'notflipped')
        fg = load([filepath_fg]);
    elseif strcmp(flipped, 'flipped')
        fg = load([fileflippedpath_fg]);
    end
end


if strcmp(traintest, 'train')
    bg.ids = ids_bg;
    fg.ids = ids_fg;
elseif strcmp(traintest, 'test') 
    
   bg.ids = ids_bg_test;
   fg.ids = ids_fg_test;

end


image_num = numel(fg.ids); % get number of elements in fg.ids
%action_name = {'jumping', 'phoning', 'playinginstrument', 'reading', 'ridingbike', ...
%    'ridinghorse', 'running', 'takingphoto', 'usingcomputer', 'walking'};
action_name = {'phoning', 'playinginstrument', 'reading', 'ridingbike', 'ridinghorse', ...
    'running', 'takingphoto', 'usingcomputer', 'walking'};

image_num
% set up the ground truth labels for foreground
for i = 1 : image_num
    gt{i} = [];
end


for i = 1 : length(action_name)
        
    disp(action_name{i})
  
    if strcmp(traintest, 'train')
        [currids currobjId currgt] = textread([filegt ...
        action_name{i} '_' imageset '.txt'], '%s %d %d'); % file of the form 2010_006181  1 (obj class name) -1 (not phoning)
   
    elseif strcmp(traintest, 'test') 
         [currids currobjId currgt] = textread([filegt ...
        action_name{i} '_' imageset '.txt'], '%s %d %d');
    end
    
    for j = 1 : length(currids)
        
        % do this for only for trainval , not for test, ok for test file
        % there's no lablel, so that's why the following is omitted!
     
        if currgt(j) ~= 1
            continue;
        end
       
        
        count = 0;
        for k = 1 : image_num
            
            % don't understand??? now understand, it is just labeling for each object in the image
            if (strmatch(currids{j},fg.ids{k}) == 1)
                % same image
                count = count + 1;
                if count == currobjId(j)
                    gt{k} = [gt{k}, i]; % the ground truth of the kth image has the current action class (i)
                end
            end
        end
    end
end

class_num = length(action_name) + 1;
for i = 1 : length(gt)
    if isempty(gt{i})
        gt{i} = class_num;
    end
end

disp(['The total number of images is ' num2str(length(gt))]);
gt_num = 0;
for i = 1 : length(gt)
    gt_num = gt_num + length(gt{i});
end
disp(['The total number of gt is ' num2str(gt_num)]);

%save gt
if strcmp(flipped, 'notflipped')
    fid = fopen([imageset '_' num2str(divide2) '.txt'], 'w');
  
elseif strcmp(flipped, 'flipped') 
    fid = fopen([imageset '_' num2str(divide2) '_flipped.txt'], 'wb');
end

fwrite(fid, int32(image_num), 'int');  % output image number

tmp_class = -1;
for i = 1 : image_num
    tic;
    % class label of the i-th image
    if length(gt{i}) == 1
        fwrite(fid, int32(gt{i}(1)), 'int');
        fwrite(fid, int32(tmp_class), 'int');
    %elseif length(gt{i}) == 2
    %    fwrite(fid, int32(gt{i}(1)), 'int');
    %    fwrite(fid, int32(gt{i}(2)), 'int');
        %{
        disp(['two gt ']);
        disp([ num2str(int32(gt{i}(1)))  '    ']);
        disp([ num2str(int32(gt{i}(2)))]);
        %}
    else
        disp('error class ID!');
        %{
        for index_i = 1:length(gt{i})
            disp([ num2str(int32(gt{i}(index_i)))  '    ']);
        end
        %}
        finish;
    end
    
	if divide2 == 0
	    % fg data
	   	width = numel(unique(fg.imageInfo{i}.y));
	    height = numel(unique(fg.imageInfo{i}.x));
	    % note that the width and height are inversed
	    fwrite(fid, int32(width), 'int');  % output width of the image
    	fwrite(fid, int32(height), 'int'); % output height of the image
    
	    % starting locations of the LLC results
	    fg.integralData{i} = full(fg.integralData{i});
	    start_id = 0;
	    fwrite(fid, int32(start_id), 'int');
	    for j = 1 : size(fg.integralData{i}, 1)
	        start_id = start_id + numel(find(fg.integralData{i}(j, :) ~= 0));
	        fwrite(fid, int32(start_id), 'int');
	    end
    
	    % index of the codewords and their LLC pooling value
        [codeIndex, LLCValue] = GetSparseDataFunc(fg.integralData{i});
	    fwrite(fid, int32(codeIndex), 'int');
	    fwrite(fid, single(LLCValue), 'single');
	    fg.integralData{i} = sparse(fg.integralData{i});
    else
        % fg data
        oriWidth = numel(unique(fg.imageInfo{i}.y));
        width = ceil(oriWidth / 2);
        oriHeight = numel(unique(fg.imageInfo{i}.x));
        height = ceil(oriHeight / 2);
        % note that the width and height are inversed
        fwrite(fid, int32(width), 'int');  % output width of the image
        fwrite(fid, int32(height), 'int'); % output height of the image
    
        % starting locations of the LLC results
        fg.integralData{i} = full(fg.integralData{i});
        poolData = MaxPoolingData(fg.integralData{i}, oriWidth, oriHeight);
        start_id = 0;
        fwrite(fid, int32(start_id), 'int');
        for j = 1 : size(poolData, 1)
            start_id = start_id + numel(find(poolData(j, :) ~= 0));
            fwrite(fid, int32(start_id), 'int');
        end
    
        % index of the codewords and their LLC pooling value
        [codeIndex, LLCValue] = GetSparseDataFunc(poolData);
    
        fwrite(fid, int32(codeIndex), 'int');
        fwrite(fid, single(LLCValue), 'single');
        fg.integralData{i} = sparse(fg.integralData{i});
	end
    
    % bg data
    bgID = 0;
    for j = 1 : numel(bg.ids)
        
        if (strmatch(bg.ids{j},fg.ids{i}) == 1)
            bgID = j;
        end
    end
   
    assert(bgID ~= 0); % make sure there is corresponding image
    
    % note that we directly output bg histograms here
    % 2 by 2
    bg.integralData{bgID} = full(bg.integralData{bgID});
    for j = 1 : 4
        LLCValue = bg.integralData{bgID}(j, :);
        fwrite(fid, single(LLCValue), 'single');
    end
    bg.integralData{bgID} = sparse(bg.integralData{bgID});

    
%     oriWidth = numel(unique(bg.imageInfo{bgID}.y));
%     width = ceil(oriWidth / 2);
%     oriHeight = numel(unique(bg.imageInfo{bgID}.x));
%     height = ceil(oriHeight / 2);
%     fwrite(fid, int32(width), 'int');
%     fwrite(fid, int32(height), 'int');
%     
%     % starting locations of the LLC results
%     bg.integralData{bgID} = full(bg.integralData{bgID});
%     poolData = YBPMaxPoolData(bg.integralData{bgID}, oriWidth, oriHeight);
%     start_id = 0;
%     fwrite(fid, int32(start_id), 'int');
%     for j = 1 : size(poolData, 1)
%         start_id = start_id + numel(find(poolData(j, :) ~= 0));
%         fwrite(fid, int32(start_id), 'int');
%     end
%     
%     % index of the codewords and their LLC pooling value
%     [codeIndex, LLCValue] = YBPGetSparseData(poolData);
%     fwrite(fid, int32(codeIndex), 'int');
%     fwrite(fid, single(LLCValue), 'single');
%     bg.integralData{bgID} = sparse(bg.integralData{bgID});
    disp(['The time for processing the ' num2str(i) '-th image is ' num2str(toc)]);
end
%}
fclose(fid);
