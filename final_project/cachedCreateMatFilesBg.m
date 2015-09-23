function [] = cachedCreateMatFilesBg(data, config)
% not implemented
totalIter = 1;
if(config.includeFlippedImages)
    totalIter = 2;
end

gridSpacing = config.matFiles.gridSpacing;
patchSize = config.matFiles.patchSize;
dictionarySize = config.dictionary.size;
flipSuffix = config.flipSuffix;
imageSets = config.imageSets;
inputFolder = [config.outputFolder '/fullIntegral_fg/'];

for iter=1:totalIter
    flip_str = flipSuffix{iter};
    for iset = 1:length(imageSets)
        imageSet = imageSets{iset};
        currentData = data.(imageSet);
        imageInfo = cell(length(currentData), 1);
        integralData = cell(length(currentData), 1);
        outputFile = fullfile(config.outputFolder, [data.name '_fg/' imageSet flip_str '_fg.mat']);
        
        % check for existence
        %if(~exist(outputFile, 'file'))
        
            parfor i=1:length(currentData)
                disp(['createMatFiles: ' num2str(i) ' of ' num2str(length(currentData)) ', set: ' imageSet ', flip: ' num2str(iter-1)]);
                inputFile = fullfile(inputFolder, currentData(i).annotation.folder, [currentData(i).annotation.filename(1:end-4) flip_str '.mat']);
                
                tempData = load(inputFile);
                imageInfo{i} = tempData.imageInfo;
                integralData{i} = tmpData.integralData
    
            end
            dataset = currentData;
            make_dir(outputFile);
            save(outputFile, 'dataset',  'integralData', 'imageInfo', '-v7.3');
        %end
    end
end

end
