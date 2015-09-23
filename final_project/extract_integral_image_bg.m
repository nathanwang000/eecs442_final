function [] = extractIntegral(data, config)

totalIter = 1;
if(config.includeFlippedImages)
    totalIter = 2;
end

gridSpacing = config.matFiles.gridSpacing;
patchSize = config.matFiles.patchSize;
dictionarySize = config.dictionary.size;
flipSuffix = config.flipSuffix;
imageSets = config.imageSets;
inputFolder = [config.outputFolder '/fullLlc_' num2str(config.dictionary.size) '/'];
outputFolder = [config.outputFolder '/fullIntegral_bg'];

for iter=1:totalIter
    flip_str = flipSuffix{iter};
    for iset = 1:length(imageSets)
        imageSet = imageSets{iset};
        currentData = data.(imageSet);
        %imageInfo = cell(length(currentData), 1);
        %integralData = cell(length(currentData), 1);
        parfor i=1:length(currentData)
            disp(['extract integral image bg: ' num2str(i) ' of ' num2str(length(currentData)) ', set: ' imageSet ', flip: ' num2str(iter-1)]);
            imageInfo = []; integralData = [];
            outputFile = fullfile(outputFolder, currentData(i).annotation.folder, [currentData(i).annotation.filename(1:end-4) flip_str '.mat']);
            % check for existence
            if(~exist(outputFile, 'file'))
                make_dir(outputFile);

                inputFile = fullfile(inputFolder, currentData(i).annotation.folder, [currentData(i).annotation.filename(1:end-4) flip_str '.mat']);
                tempData = load(inputFile);
                % imageInfo{i}.hgt = tempData.hgt;
                % imageInfo{i}.wid = tempData.wid;
                imageInfo.hgt = tempData.hgt;
                imageInfo.wid = tempData.wid;
                tempData.data = cell2mat(tempData.data);

                [x, y, ~, ~] = generateSIFTGrid(imageInfo.hgt, imageInfo.wid, patchSize, gridSpacing);
                % sample x and y to be at most 3000
                if length(x) > 3000
                    step = floor(length(x) / 3000); % actually this allows 5999
                    x = x(1:step:end); 
                    y = y(1:step:end);
                end
            
                idx = getDistIdx([cell2mat(tempData.x) cell2mat(tempData.y)], [x y]);
            
                overallIdx = cell(length(x), 1);
                for j=1:length(x)
                    overallIdx{j} = find(idx==j);
                end
                nonzero_idx = cellfun(@(x) ~isempty(x),overallIdx);
    
                % integralData{i} = sparse(length(x), dictionarySize);
                % integralData{i}(nonzero_idx, :) = cell2mat(cellfun(@(x) max(tempData.data(x, :), [], 1) , overallIdx(nonzero_idx), 'UniformOutput', false));
                integralData = sparse(length(x), dictionarySize);
                integralData(nonzero_idx, :) = cell2mat(cellfun(@(x) max(tempData.data(x, :), [], 1) , overallIdx(nonzero_idx), 'UniformOutput', false));

                %imageInfo{i}.x = x; imageInfo{i}.y = y;
                imageInfo.x = x; imageInfo.y = y;
                
                parsave2(outputFile, imageInfo, integralData);    
            end
            % dataset = currentData;
            %save(outputFile, 'dataset',  'integralData', 'imageInfo', '-v7.3');
        end
    end
end

end
