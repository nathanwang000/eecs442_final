function [] = extractLLC(data, config)

if(config.parallel.enable && matlabpool('size')==0)
  global sched
  matlabpool(sched, config.parallel.cores);
end

totalIter = 1;
if(config.includeFlippedImages)
    totalIter = 2;
end

flipSuffix = config.flipSuffix;
inputFolder = [config.outputFolder '/' data.name '/caffe/']; 
outputFolder = [config.outputFolder '/' data.name '/llc_' num2str(config.dictionary.size) '_caffe/'];
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
                siftData = load(inputFile);
                llcHist = cellfun(@(x) sparse(LLC_coding_appr(dictionary, x, config.knn)), siftData.data, 'UniformOutput', false);
                parsave(outputFile, llcHist, siftData.x, siftData.y, siftData.patchSizes, siftData.hgt, siftData.wid);
                %saveFileFunc(outputFile, llcHist, siftData.x, siftData.y, siftData.patchSizes, siftData.hgt, siftData.wid);
            end
        end
    end
end

if(matlabpool('size')>0)
    matlabpool close;
end
