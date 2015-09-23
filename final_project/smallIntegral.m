function [tmpData]=smallIntegral(outputName)  % actually outpuName can be the same as inputName
action = struct('nname','general','vname', 'action'); 

[config, config_fg, ...
 trainingpath, savefile, hi, name, testpath, ...
 trainingpath_fg, savefile_fg, hi_fg, name_fg, testpath_fg, ...
 trainingfilepath, trainingfileflippedpath, ...
 trainingfilepath_fg, trainingfileflippedpath_fg, ...
 trainingfilegt, ...
 testfilepath, testfileflippedpath, ...
 testfilepath_fg, testfileflippedpath_fg, ...
 testfilegt] = smallConfig(action);

inputFolder = [config.outputFolder '/fullLlc_' num2str(config.dictionary.size) '/'];
outputFolder = [config.outputFolder 'fullIntegral_fg/'];
[path,name,ext] = fileparts(outputName);

outputFile = [outputFolder name '.mat'];
inputFile = ['/scratch/jiadeng_fluxg/jiaxuan/savefeature/fullLlc_1024/' name '.mat'];

fprintf('generate integral image with input: %s\noutput: %s\n', inputFile, outputFile);

gridSpacing = config.matFiles.gridSpacing;
patchSize = config.matFiles.patchSize;
dictionarySize = config.dictionary.size;

haveError = true;
if(~exist(outputFile, 'file'))
    
    make_dir(outputFile);
    
    while (haveError)
        try
            tempData = load(inputFile);

            % imageInfo{i}.hgt = tempData.hgt;
            % imageInfo{i}.wid = tempData.wid;
            imageInfo.hgt = tempData.hgt;
            imageInfo.wid = tempData.wid;
            disp(inputFile);
            try
                tempData.data = cell2mat(tempData.data);
            catch
                fprintf('reshaping the input\n');
                tempData.data = reshape(tempData.data, size(tempData.data,2), size(tempData.data,1));
                tempData.data = cell2mat(tempData.data)

                tempData.x = reshape(tempData.x, size(tempData.x,2), size(tempData.x,1));
                tempData.y = reshape(tempData.y, size(tempData.y,2), size(tempData.y,1));

            end
            [x, y, ~, ~] = generateSIFTGrid(imageInfo.hgt, imageInfo.wid, patchSize, gridSpacing);
            % sample x and y to be at most 3000
            %                 if length(x) > 3000
            %                     step = floor(length(x) / 3000); % actually this allows 5999
            %                     x = x(1:step:end); 
            %                     y = y(1:step:end);
            %                 end
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
            haveError = false;
            

        catch
            fprintf('Error occured rerunning\n');
           % rerun smallLLC
           disp([name '.mat']);
           smallLLC([name '.mat']);
           tempData = load(inputFile);
       end
    end
end

end