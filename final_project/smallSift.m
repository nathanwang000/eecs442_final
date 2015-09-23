function []=smallSift(outputName)
    action = struct('nname','general','vname', 'action'); 
    [path,name,ext] = fileparts(outputName);
    outputFile = ['/scratch/jiadeng_fluxg/jiaxuan/savefeature/fullSift/' name '.mat'];
    if (findstr('train',outputFile))
        inputFile = ['/scratch/jiadeng_fluxg/shared/hico_20150920/images_500/train2015/' name '.jpg'];
    else
        inputFile = ['/scratch/jiadeng_fluxg/shared/hico_20150920/images_500/test2015/' name '.jpg'];
    end

    fprintf('generate sift with input: %s\noutput: %s\n', inputFile, outputFile);


    [config, config_fg, ...
     trainingpath, savefile, hi, name, testpath, ...
     trainingpath_fg, savefile_fg, hi_fg, name_fg, testpath_fg, ...
     trainingfilepath, trainingfileflippedpath, ...
     trainingfilepath_fg, trainingfileflippedpath_fg, ...
     trainingfilegt, ...
     testfilepath, testfileflippedpath, ...
     testfilepath_fg, testfileflippedpath_fg, ...
     testfilegt] = smallConfig(action);
    
    config.flipImage = 0;
    config.imageSize = 0; % for not scaling
    config.gridSpacing = 4;
    
    config.patchSize = [8 12 16 24 30];
    config.sigmaEdge = 0.8;
    
    patchSizes = config.patchSize;
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
