function [beta, xindex, yindex] = LLC_pooling(integralData, imageInfo, x, y, patchSizeX, patchSizeY,pyramidLevels)

pyramid = 2.^(0:pyramidLevels);
stepSizeX = patchSizeX/(pyramid(end));
stepSizeY = patchSizeY/(pyramid(end));

pyramidIdx = cell(pyramid(end));
tBins = sum(pyramid.^2);
featureSize = size(integralData{1}, 2);
featureSize
numImages = length(integralData);
%numImages = 1;
beta = zeros(numImages, featureSize*tBins);
currentBin = 1;

size(integralData)
disp(num2str(numImages))
disp(num2str(featureSize))
 xindex = [];
 yindex = [];
for i=1:pyramid(end)
    %start_x = cell(5,1);
    %end_x = cell(5,1);
   %for tempi = 1:5
    %start_x{tempi, 1} = x{tempi, 1}+(i-1)*stepSizeX;
    %end_x{tempi, 1} = x{tempi, 1}+i*stepSizeX;
    start_x = x+(i-1)*stepSizeX;
    end_x = x+i*stepSizeX;
   %end
    %xindex = [xindex; start_x*imageInfo{1}.wid];
    %imageInfo{1}.x
    %imageInfo{1}.wid
    x_idx = cellfun(@(x) getIdxXNewAction(x, start_x, end_x), imageInfo, 'UniformOutput', false);
    
    for j=1:pyramid(end)
        start_y = y + (j-1)*stepSizeY;
        end_y = y + j*stepSizeY;
        xindex = [xindex; start_x*imageInfo{1}.wid];
        yindex = [yindex; start_y*imageInfo{1}.hgt];
        
        idx = cellfun(@(x, y) getIdxYNewAction(x, y,start_y, end_y), imageInfo, x_idx, 'UniformOutput', false);
        emptyIdx = find(cellfun(@(x) sum(x)==0, idx));
        binIdx = (currentBin-1)*featureSize+1:currentBin*featureSize; 
        pyramidIdx{i, j} = binIdx;
        idx(emptyIdx) = [];
        tempIntegralData = integralData;
        tempIntegralData(emptyIdx) = [];
        tempbeta = cell2mat(cellfun(@maxIdxPascal, tempIntegralData, idx, 'UniformOutput', false));
        for k=1:length(emptyIdx), tempbeta = insertrows(tempbeta, 0, emptyIdx(k)-1); disp('hi!'); end;
        size(tempbeta)
        beta(:, binIdx) = tempbeta;
        disp('size beta')
        size(beta)
        currentBin = currentBin + 1;
    end
end

%any(beta(:)<0)

pyramidCell = cell(length(pyramid));
pyramidCell{1} = pyramidIdx;
for i=1:length(pyramid)-1
    pyramidSize = pyramid(end-i);
    pyramidCell{i+1} = cell(pyramidSize);
    for j=1:pyramidSize
        for k=1:pyramidSize
            binIdx = (currentBin-1)*featureSize+1:currentBin*featureSize;
            pyramidCell{i+1}{j, k} = binIdx;
            %beta(:, binIdx) = max(reshape(beta(:, cell2mat(reshape(pyramidCell{i}(2*(j-1)+1:2*j, 2*(k-1)+1:2*k), [4 1]))), [numImages featureSize 4]), [], 3);
            beta(:, binIdx) = max(beta(:, pyramidCell{i}{2*(j-1)+1, 2*(k-1)+1}), beta(:, pyramidCell{i}{2*(j-1)+1, 2*k}));
            beta(:, binIdx) = max(beta(:, pyramidCell{i}{2*j, 2*(k-1)+1}), beta(:, binIdx));
            beta(:, binIdx) = max(beta(:, pyramidCell{i}{2*j, 2*k}), beta(:, binIdx));
            %size(reshape(beta(:, cell2mat(reshape(pyramidCell{i}(2*(j-1)+1:2*j, 2*(k-1)+1:2*k), [4 1]))), [numImages featureSize 4]))
            currentBin = currentBin + 1;
        end
    end
end

norm_beta = sqrt(sum(beta.^2, 2));
beta = beta./repmat(norm_beta, [1 size(beta, 2)]);
