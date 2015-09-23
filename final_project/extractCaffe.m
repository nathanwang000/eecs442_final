function [] = extractSIFT(data, config)

fid = fopen('CaffeExtractionInput.txt', 'w');

totalIter = 1;
if(config.includeFlippedImages)
    totalIter = 2;
end

flipSuffix = config.flipSuffix;
outputFolder = [config.outputFolder '/' data.name '/caffe/' ];
inputFolder = data.hi;
imageSets = config.imageSets; % {tr, te}

config = config.SIFT;
patchSizes = config.patchSize;

% Extract Caffe features fc7
for iter=1:totalIter
    config.flipImage = iter-1;
    flip_str = flipSuffix{iter};
    for iset = 1:length(imageSets) % imageSets is {'tr', 'te'}
        imageSet = imageSets{iset};
        currentData = data.(imageSet); % recall data contains hi, name, tr (training images), te (testing images)

	 for i=1:length(currentData)
            disp(['extractCaffe: ' num2str(i) ' of ' num2str(length(currentData)) ', set: ' imageSet ', flip: ' num2str(iter-1)]);

            x = cell(length(patchSizes), 1); 
            y = cell(length(patchSizes), 1);
            Xrange = cell(length(patchSizes), 1);
            Yrange = cell(length(patchSizes), 1);

            inputFile = fullfile(inputFolder, currentData(i).annotation.folder, currentData(i).annotation.filename);
            outputFile = fullfile(outputFolder, currentData(i).annotation.folder, [currentData(i).annotation.filename(1:end-4) flip_str]);

	    % pseudo code
	    % create file for input to caffe for tr and te
	    % call caffe extraction on this file
	    fprintf(fid, '%s %s\n', inputFile, outputFile);
	  
            if(~exist([outputFile '.mat'], 'file'))
                make_dir(outputFile);
                
                % should densely extract in python
                I = sp_load_image(inputFile, config);
                [hgt wid] = size(I);

                for j=1:length(patchSizes)
                   patchSize = config.patchSize(j);
                   [x{j}, y{j}, Xrange{j}, Yrange{j}] = generateCaffeGrid(hgt, wid, patchSize, config.gridSpacing);
                end
		ofname = [outputFile '_raw.mat'];
                parsave_caffe(ofname, Xrange, Yrange, x, y, patchSizes, hgt, wid); % save raw output
	    end
        end
    end
end


fclose(fid);
