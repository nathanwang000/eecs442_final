function createForegroundImages(istrain)

if nargin < 1
   istrain = true; 
end

% change this path if you install the VOC code elsewhere
%addpath([cd '/VOCcode']);
%addpath([cd '/vision/u/kakooyang/randomforest/llc_extraction/VOCdevkit/VOCcode']);
%%% addpath(['/vision/u/kakooyang/randomforest/llc_extraction/VOCdevkit/VOCcode']);

addpath(['VOCdevkit/VOCcode']);

% initialize VOC options
VOCinit;

%input_folder = 'VOC2011/JPEGImages/';
%%input_folder = '/vision/u/kakooyang/randomforest/llc_extraction/VOC2011ori/TrainVal/VOCdevkit/VOC2011/JPEGImages/';
if (istrain)
    input_folder = '../trainval/VOCdevkit/VOC2010/JPEGImages/';
    imgset = 'trainval';
    fileID = fopen('train_fg.txt','w');
else
    input_folder = '../test/VOCdevkit/VOC2010/JPEGImages/';
    imgset = 'test';
    fileID = fopen('test_fg.txt','w');
end

%output_folder = 'dataset/';
output_folder = 'dataset_fg/';
input_folder

expansionFactor = 1.5;
maxDimension = 300;
sprintf('test2')
sprintf(VOCopts.action.imgsetpath, imgset)
%%%sprintf('../trainval/VOCdevkit/VOC2010/ImageSets/Action/%s.txt', imgset)
ids = textread(sprintf(VOCopts.action.imgsetpath, imgset), '%s');
sprintf('test')
startIdx = 1;
length(ids)
%sprintf(VOCopts.action.imgsetpath, 'trainval')
%ids = textread(sprintf(VOCopts.action.imgsetpath, '/trainval.txt'), '%s');
if(~exist('startIdx', 'var'))
    error('Please define startIdx');
end

if(~exist('endIdx', 'var'))
    endIdx = length(ids);
end

numIdx = endIdx-startIdx+1;

for i=startIdx:endIdx
    imageFName = [input_folder ids{i} '.jpg'];
    disp(['Image ' num2str(i) ' of ' num2str(numIdx)])
    
    
    sprintf(VOCopts.annopath,ids{i})
    
    rec=PASreadrecord(sprintf(VOCopts.annopath,ids{i}));
    
    %%%disp(sprintf(VOCopts.annopath,ids{i}));
    img_wid = rec.imgsize(1);
    img_hgt = rec.imgsize(2);
    img = imread(imageFName);
    

    for j=1:length(rec.objects)
        outFName = [output_folder ids{i} '_' num2str(j) '.jpg'];
        bndbox = rec.objects(j).bndbox;
        
        bndbox_wid = bndbox.xmax-bndbox.xmin+1;
        bndbox_hgt = bndbox.ymax-bndbox.ymin+1;
        
        temp = min([(expansionFactor-1)/2, (bndbox.xmin-1)/bndbox_wid, (img_wid-bndbox.xmax)/bndbox_wid, (bndbox.ymin-1)/bndbox_hgt, (img_hgt-bndbox.ymax)/bndbox_hgt]);
        
        xmin = ceil(bndbox.xmin-temp*bndbox_wid); xmax = floor(bndbox.xmax+temp*bndbox_wid);
        ymin = ceil(bndbox.ymin-temp*bndbox_hgt); ymax = floor(bndbox.ymax+temp*bndbox_hgt);
        scale = min(maxDimension/(xmax-xmin+1), maxDimension/(ymax-ymin+1));
        newImage = imresize(img(ymin:ymax, xmin:xmax, :), scale);
        imwrite(newImage, outFName, 'jpg');
        fprintf(fileID,'%s\n',outFName);
    end
end
