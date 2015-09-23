function [] = extractSIFT(data, config)

totalIter = 1;
if(config.includeFlippedImages)
    totalIter = 2;
end

flipSuffix = config.flipSuffix;
% outputFolder = [config.outputFolder '/' data.name '/sift/' ];
outputFolder = [config.outputFolder '/fullSift'];
inputFolder = data.hi;
imageSets = config.imageSets;

config = config.SIFT;
patchSizes = config.patchSize;

% Extract SIFT features

for iter=1:totalIter
    config.flipImage = iter-1;
    flip_str = flipSuffix{iter};
    for iset = 1:length(imageSets) % imageSets is {'tr', 'te'}
        imageSet = imageSets{iset};
        currentData = data.(imageSet); % recall data contains hi, name, tr (training images), te (testing images)

	% only extract positive images
        for i=1:length(currentData)
            disp(['extractSIFT: ' num2str(i) ' of ' num2str(length(currentData)) ', set: ' imageSet ', flip: ' num2str(iter-1)]);
            
            x = cell(length(patchSizes), 1); 
            y = cell(length(patchSizes), 1);
            siftDesc = cell(length(patchSizes), 1);

            inputFile = fullfile(inputFolder, currentData(i).annotation.folder, currentData(i).annotation.filename);
            outputFile = fullfile(outputFolder, currentData(i).annotation.folder, [currentData(i).annotation.filename(1:end-4) flip_str '.mat']);
            if(~exist(outputFile, 'file'))
                make_dir(outputFile);
                I = sp_load_image(inputFile, config);
                [hgt wid] = size(I);

                for j=1:length(patchSizes)
                    patchSize = config.patchSize(j);
                    [x{j}, y{j}, gridX, gridY] = generateSIFTGrid(hgt, wid, patchSize, config.gridSpacing);
                    siftDesc{j} = sp_normalize_sift(sp_find_sift_grid(I, gridX, gridY, patchSize, config.sigmaEdge));
                end
                saveFileFunc(outputFile, siftDesc, x, y, patchSizes, hgt, wid);
            end
        end
    end
end
end