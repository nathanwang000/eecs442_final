function [] = extractLLC(data, config)

totalIter = 1;
if(config.includeFlippedImages)
    totalIter = 2;
end

flipSuffix = config.flipSuffix;
inputFolder = [config.outputFolder '/fullSift']; 
outputFolder = [config.outputFolder '/fullLlc_' num2str(config.dictionary.size) '/'];
imageSets = config.imageSets;

try
    dictionary = config.dictionary.data.dictionary;
catch
    dictionary = config.dictionary.data;
end

config = config.LLC;
% Extract LLC histograms
for iter=1:totalIter
    flip_str = flipSuffix{iter};
    for iset = 1:length(imageSets)
        imageSet = imageSets{iset};
        currentData = data.(imageSet);
        parfor i=1:length(currentData)
        %for i=1:length(currentData)
            disp(['extractLLC: ' num2str(i) ' of ' num2str(length(currentData)) ', set: ' imageSet ', flip: ' num2str(iter-1)]);

            outputFile = fullfile(outputFolder, currentData(i).annotation.folder, [currentData(i).annotation.filename(1:end-4) flip_str '.mat']);
            inputFile = fullfile(inputFolder, currentData(i).annotation.folder, [currentData(i).annotation.filename(1:end-4) flip_str '.mat']);
            if(~exist(outputFile, 'file'))
                make_dir(outputFile);
                try
                    siftData = load(inputFile); % use try catch here!
                catch
                    smallSift(inputFile)
                    siftData = load(inputFile); % use try catch here!
                end
                llcHist = cellfun(@(x) sparse(LLC_coding_appr(dictionary, x, config.knn)), siftData.data, 'UniformOutput', false);
                parsave(outputFile, llcHist, siftData.x, siftData.y, siftData.patchSizes, siftData.hgt, siftData.wid);
                %saveFileFunc(outputFile, llcHist, siftData.x, siftData.y, siftData.patchSizes, siftData.hgt, siftData.wid);
            end
        end
    end
end

end