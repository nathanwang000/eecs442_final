function [dictionary] = generateDictionary(data, config)

numImages = config.dictionary.numImages; % number of images to sample
numDescriptors = config.dictionary.numDescriptors;
dictionarySize = config.dictionary.size;

% deal with cached result
% if exist([config.outputFolder '/' data.name '/dictionary_' num2str(dictionarySize) '.mat'], 'file')
if exist([config.outputFolder '/dictionary_' data.name num2str(dictionarySize) '.mat'], 'file')
  fprintf('dictionary file found, using cached dictionary\n');
  % dictionary = load([config.outputFolder '/' data.name '/dictionary_' num2str(dictionarySize) '.mat']);
  dictionary = load([config.outputFolder '/dictionary_' data.name num2str(dictionarySize) '.mat']);
  return;
end


imageIdx = randi(length(data.tr), numImages, 1); % random numImages of images
patchIdx = zeros(numImages, 1);
siftCount = zeros(numImages, 1);
flipIdx = ones(numImages, 1);
if(config.includeFlippedImages)
    flipIdx = randi(2, numImages, 1);
end

for i=1:numImages
  disp(['generateDictionary: ' num2str(i) ' of ' num2str(numImages)]);
  currImage = data.tr(imageIdx(i)).annotation;
  % change since I need to learn sift for all classes
  inputFile = fullfile(config.outputFolder, 'fullSift', currImage.folder, [currImage.filename(1:end-4) config.flipSuffix{flipIdx(i)} '.mat']);
  tempData = load(inputFile);

  patchIdx(i) = randi(length(tempData.patchSizes), 1); % choose a patch size
  siftCount(i) = size(tempData.data{patchIdx(i)},1); % data is sift descriptor
end

siftDescriptors = zeros(sum(siftCount), size(tempData.data{1}, 2)); % basically is number of patches x descriptor dim
currentIdx = 1;

for i=1:numImages  
  fprintf('loading sift features of a given patch size for image %d into siftDescriptors\n', i);
  currImage = data.tr(imageIdx(i)).annotation;
  inputFile = fullfile(config.outputFolder, 'fullSift', currImage.folder, [currImage.filename(1:end-4) config.flipSuffix{flipIdx(i)} '.mat']);
  tempData = load(inputFile);

  siftDescriptors(currentIdx:(currentIdx+siftCount(i)-1), :) = tempData.data{patchIdx(i)};
  currentIdx = currentIdx + siftCount(i);
end

ndata = size(siftDescriptors, 1);
fprintf('total of %d vectors for kmeans clustering\n', ndata);
if(ndata > numDescriptors) % exceed maximum quota for configuration
  siftDescriptors = siftDescriptors(randsample(ndata, numDescriptors), :); % sample numDescriptors from ndata
end

[dictionary, ~] = litekmeans(siftDescriptors', dictionarySize);

dictionary = dictionary';
% save([config.outputFolder '/' data.name '/dictionary_' num2str(dictionarySize) '.mat'], 'dictionary');
save([config.outputFolder '/dictionary_' data.name num2str(dictionarySize) '.mat'], 'dictionary');
end
