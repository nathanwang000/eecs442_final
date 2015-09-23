function super_outputBinaryFeature(config, config_fg, name, name_fg, action, divide2, traintest, flipped, filepath, fileflippedpath, filepath_fg, fileflippedpath_fg, filegt)

% use the cached information
if strcmp(traintest, 'train')
  load([config.outputFolder '/' name_fg '/ids_fg.mat']);
  load([config.outputFolder '/' name '/ids_bg.mat']);
  imageset = 'trainval'; 
elseif strcmp(traintest, 'test')
  load([config.outputFolder '/' name_fg '/ids_fg_test.mat']);
  load([config.outputFolder '/' name '/ids_bg_test.mat']);
  imageset = 'test';
end

divide2 = 0; % what's point in putting this variable here???

% have bg so this is ok
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

% debugged here!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! no fg data need
disp('loading fg data');
% if strcmp(traintest, 'train')
%     if strcmp(flipped, 'notflipped')
%         fg = load([filepath_fg]);
%     elseif strcmp(flipped, 'flipped')
%         fg = load([fileflippedpath_fg]);
%     end
% elseif strcmp(traintest, 'test') 
%     
%     if strcmp(flipped, 'notflipped')
%         fg = load([filepath_fg]);
%     elseif strcmp(flipped, 'flipped')
%         fg = load([fileflippedpath_fg]);
%     end
% end
% fixme!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

if strcmp(traintest, 'train')
    bg.ids = ids_bg;
    fg.ids = ids_fg;
elseif strcmp(traintest, 'test') 
    
   bg.ids = ids_bg_test;
   fg.ids = ids_fg_test;
end

image_num = numel(fg.ids); % get number of elements in fg.ids
action_name = {[action.vname '_' action.nname]};
assert(length(action_name) == 1); % make sure this is binary

image_num
% set up the ground truth labels for foreground
for i = 1 : image_num
    gt{i} = [];
end

for i = 1 : length(action_name)
    disp(action_name{i})
  
    if strcmp(traintest, 'train')
        [currids] = textread([filegt action_name{i} '.txt'], '%s'); % file of the form filename.jpg and only contain the positive example b/c its binary :)
        
    elseif strcmp(traintest, 'test') 
         %[currids currobjId currgt] = textread([filegt ...
         %action_name{i} '_' imageset '.txt'], '%s %d %d');
         [currids] = textread([filegt action_name{i} '.txt'], '%s'); % file of the form filename.jpg
    end
    
    for j = 1 : length(currids)
        % do this for only for trainval , not for test, ok for test file
        % there's no lablel, so that's why the following is omitted!
        % the following commented out code is always true as I only include
        % positive images in the gt file
        %if currgt(j) ~= 1
        %    continue;
        %end
        
        count = 0;
        for k = 1 : image_num
            if (strmatch(currids{j},fg.ids{k}) == 1)
                % same image
                gt{k} = [gt{k}, i];
            end
        end
    end
end

class_num = length(action_name) + 1; % so 1 for true, 2 for not true b/c this is binary
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

% should not hard code this, for time sake, I do this, sorry for anyone
% using this code, I apologize
% save gt
if strcmp(flipped, 'notflipped')
    %fid = fopen([imageset '_' num2str(divide2) '.txt'], 'wb');  
    fid = fopen(['/scratch/jiadeng_fluxg/jiaxuan/RF_related/' imageset '_' num2str(divide2) '_' action.vname '_' action.nname '.txt'], 'wb');  
elseif strcmp(flipped, 'flipped') 
    fid = fopen(['/scratch/jiadeng_fluxg/jiaxuan/RF_related/' imageset '_' num2str(divide2) '_' action.vname '_' action.nname '_flipped.txt'], 'wb');
end

fwrite(fid, int32(image_num), 'int');  % output image number

tmp_class = -1;
for i = 1:image_num
    tic;
    % class label of the i-th image
    if length(gt{i}) == 1
        fwrite(fid, int32(gt{i}(1)), 'int');
        fwrite(fid, int32(tmp_class), 'int');
    %elseif length(gt{i}) == 2
     %   fwrite(fid, int32(gt{i}(1)), 'int');
      %  fwrite(fid, int32(gt{i}(2)), 'int');
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

	% fg data
    if strcmp(flipped, 'flipped')
        currentData = load(sprintf('/scratch/jiadeng_fluxg/jiaxuan/savefeature/fullIntegral_fg/%s_f.mat', fg.ids{i}(1:end-4))); % the ith fg imageInfo
    else
        currentData = load(sprintf('/scratch/jiadeng_fluxg/jiaxuan/savefeature/fullIntegral_fg/%s.mat', fg.ids{i}(1:end-4))); % the ith fg imageInfo        
    end
    fg_imageInfo = currentData.imageInfo;
    fg_integralData = currentData.integralData;
    
    if divide2 == 0
	    % width = numel(unique(fg.imageInfo{i}.y));
        % height = numel(unique(fg.imageInfo{i}.x));
        width = numel(unique(fg_imageInfo.y));
	    height = numel(unique(fg_imageInfo.x));
        
	    % note that the width and height are inversed
	    fwrite(fid, int32(width), 'int');  % output width of the image
    	fwrite(fid, int32(height), 'int'); % output height of the image
    
	    % starting locations of the LLC results
	    % fg.integralData{i} = full(fg.integralData{i});
        fg_integralData = full(fg_integralData);
        
	    start_id = 0;
	    fwrite(fid, int32(start_id), 'int');
	    % for j = 1 : size(fg.integralData{i}, 1)
        for j = 1:size(fg_integralData, 1)
	        % start_id = start_id + numel(find(fg.integralData{i}(j, :) ~= 0));
            start_id = start_id + numel(find(fg_integralData(j, :) ~= 0));
	        fwrite(fid, int32(start_id), 'int');
	    end
    
	    % index of the codewords and their LLC pooling value
        % [codeIndex, LLCValue] = GetSparseDataFunc(fg.integralData{i});
        [codeIndex, LLCValue] = GetSparseDataFunc(fg_integralData);
	    fwrite(fid, int32(codeIndex), 'int');
	    fwrite(fid, single(LLCValue), 'single'); % 4 bytes for single
	    % fg.integralData{i} = sparse(fg.integralData{i});
        fg_integralData = sparse(fg_integralData);
    else
        % oriWidth = numel(unique(fg.imageInfo{i}.y));
        oriWidth = numel(unique(fg_imageInfo.y));
        width = ceil(oriWidth / 2);
        % oriHeight = numel(unique(fg.imageInfo{i}.x));
        oriHeight = numel(unique(fg_imageInfo.x));
        
        height = ceil(oriHeight / 2);
        % note that the width and height are inversed
        fwrite(fid, int32(width), 'int');  % output width of the image
        fwrite(fid, int32(height), 'int'); % output height of the image
    
        % starting locations of the LLC results
        % fg.integralData{i} = full(fg.integralData{i});
        fg_integralData = full(fg_integralData);
        
        % poolData = MaxPoolingData(fg.integralData{i}, oriWidth, oriHeight);
        poolData = MaxPoolingData(fg_integralData, oriWidth, oriHeight);
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
        % fg.integralData{i} = sparse(fg.integralData{i});
        fg_integralData = sparse(fg_integralData);
	end
    
    % bg data
    % don't need this as fg=bg so currentData is reused
%     if strcmp(flipped, 'flipped')
%         currentData = load(sprintf('/scratch/jiadeng_fluxg/jiaxuan/savefeature/fullIntegral_fg/%s_f.mat', bg.ids{i}(1:end-4))); % the ith fg imageInfo
%     else
%         currentData = load(sprintf('/scratch/jiadeng_fluxg/jiaxuan/savefeature/fullIntegral_fg/%s.mat', bg.ids{i}(1:end-4))); % the ith fg imageInfo        
%     end
    
    %bg_imageInfo = currentData.imageInfo;
    %bg_integralData = currentData.integralData;    
    
    % don't need this as fg is bg
%     bgID = 0;
%     for j = 1 : numel(bg.ids)
%         if (strmatch(bg.ids{j},fg.ids{i}) == 1)
%             bgID = j;
%         end
%     end

    bgID = i;
    % assert(bgID ~= 0); % make sure there is corresponding image
    %assert(bgID == i); % make sure there is corresponding image
    
    % note that we directly output bg histograms here
    % 2 by 2
    
    bg.integralData{bgID} = full(bg.integralData{bgID});
    for j = 1:4
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
