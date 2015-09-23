function [] = createMatFilesBg(data, config)

totalIter = 1;
if(config.includeFlippedImages)
    totalIter = 2;
end

gridSpacing = config.matFiles.gridSpacing;
patchSize = config.matFiles.patchSize;
dictionarySize = config.dictionary.size;
flipSuffix = config.flipSuffix;
imageSets = config.imageSets;

%inputFolder = [config.outputFolder '/' data.name '/llc_' num2str(config.dictionary.size) '/'];
inputFolder = [config.outputFolder '/fullLlc_' num2str(config.dictionary.size) '/'];

for iter=1:totalIter
    flip_str = flipSuffix{iter};
    for iset = 1:length(imageSets)
        imageSet = imageSets{iset};
        currentData = data.(imageSet);
        imageInfo = cell(length(currentData), 1);
        integralData = cell(length(currentData), 1);
        outputFile = fullfile(config.outputFolder, [data.name '/' imageSet flip_str '.mat']);
        
        parfor i=1:length(currentData)
            disp(['createMatFiles: ' num2str(i) ' of ' num2str(length(currentData)) ', set: ' imageSet ', flip: ' num2str(iter-1)]);
            inputFile = fullfile(inputFolder, currentData(i).annotation.folder, [currentData(i).annotation.filename(1:end-4) flip_str '.mat']);
            tempData = load(inputFile);
            imageInfo{i}.hgt = tempData.hgt;
            imageInfo{i}.wid = tempData.wid;

            try
                tempData.data = cell2mat(tempData.data);
                tempData.x = cell2mat(tempData.x);
                tempData.y = cell2mat(tempData.y);
            catch
                fprintf('reshaping the input\n');
                tempData.data = reshape(tempData.data, size(tempData.data,2), size(tempData.data,1));
                tempData.x = reshape(tempData.x, size(tempData.x,2), size(tempData.x,1));
                tempData.y = reshape(tempData.y, size(tempData.y,2), size(tempData.y,1));

                tempData.data = cell2mat(tempData.data);
                tempData.x = cell2mat(tempData.x);
                tempData.y = cell2mat(tempData.y);
            end
            
            % 2 by 2
            x = [floor(tempData.wid/3)-0.5; floor(tempData.wid/3)-0.5; floor(tempData.wid*2/3)-0.5; floor(tempData.wid*2/3)-0.5];
            y = [floor(tempData.hgt/3)-0.5; floor(tempData.hgt*2/3)-0.5; floor(tempData.hgt/3)-0.5; floor(tempData.hgt*2/3)-0.5];
          
            idx = getDistIdx([tempData.x tempData.y], [x y]);
           
            overallIdx = cell(length(x), 1);
            for j=1:length(x)
                overallIdx{j} = find(idx==j);
            end

            nonzero_idx = cellfun(@(x) ~isempty(x),overallIdx);

            nonzero_idxnew = [];
            tempnonzero = zeros(length(nonzero_idx),1);
            for tempindexk = 1:length(nonzero_idx)
                if nonzero_idx(tempindexk) == 1
                    tempnonzero(tempindexk,1) = tempindexk;
                    nonzero_idxnew = [nonzero_idxnew; tempindexk];
                end
            end
           
            nonzero_idx = tempnonzero;

            integralData{i} = sparse(length(x), dictionarySize);
            integralData{i}(nonzero_idxnew, :) = cell2mat(cellfun(@(x) max(tempData.data(x, :), [], 1) , overallIdx(nonzero_idxnew), 'UniformOutput', false));
            
            imageInfo{i}.x = x; imageInfo{i}.y = y;
        end
        dataset = currentData;
        make_dir(outputFile);
        save(outputFile, 'dataset',  'integralData', 'imageInfo', '-v7.3');
    end
end

