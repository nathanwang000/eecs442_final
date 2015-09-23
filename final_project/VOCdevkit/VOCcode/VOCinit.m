clear VOCopts

% dataset
%
% Note for experienced users: the VOC2008/9 test sets are subsets
% of the VOC2010 test set. You don't need to do anything special
% to submit results for VOC2008/9.

VOCopts.dataset='VOC2010';

% get devkit directory with forward slashes
devkitroot=strrep(fileparts(fileparts(mfilename('fullpath'))),'\','/');

% change this path to point to your copy of the PASCAL VOC data
VOCopts.datadir=[devkitroot '/'];

% change this path to a writable directory for your results
VOCopts.resdir=[devkitroot '/results/' VOCopts.dataset '/'];

% change this path to a writable local directory for the example code
VOCopts.localdir=[devkitroot '/local/' VOCopts.dataset '/'];

% initialize the training set

VOCopts.trainset='trainval'; % use train for development
% VOCopts.trainset='trainval'; % use train+val for final challenge

% initialize the test set

VOCopts.testset='test'; % use validation data for development test set
% VOCopts.testset='test'; % use test set for final challenge

% initialize main challenge paths

VOCopts.annopath=[VOCopts.datadir VOCopts.dataset '/Annotations/%s.xml'];
VOCopts.imgpath=[VOCopts.datadir VOCopts.dataset '/JPEGImages/%s.jpg'];
VOCopts.imgsetpath=[VOCopts.datadir VOCopts.dataset '/ImageSets/Main/%s.txt'];
VOCopts.clsimgsetpath=[VOCopts.datadir VOCopts.dataset '/ImageSets/Main/%s_%s.txt'];
VOCopts.clsrespath=[VOCopts.resdir 'Main/%s_cls_' VOCopts.testset '_%s.txt'];
VOCopts.detrespath=[VOCopts.resdir 'Main/%s_det_' VOCopts.testset '_%s.txt'];

% initialize segmentation task paths

VOCopts.seg.clsimgpath=[VOCopts.datadir VOCopts.dataset '/SegmentationClass/%s.png'];
VOCopts.seg.instimgpath=[VOCopts.datadir VOCopts.dataset '/SegmentationObject/%s.png'];

VOCopts.seg.imgsetpath=[VOCopts.datadir VOCopts.dataset '/ImageSets/Segmentation/%s.txt'];

VOCopts.seg.clsresdir=[VOCopts.resdir 'Segmentation/%s_%s_cls'];
VOCopts.seg.instresdir=[VOCopts.resdir 'Segmentation/%s_%s_inst'];
VOCopts.seg.clsrespath=[VOCopts.seg.clsresdir '/%s.png'];
VOCopts.seg.instrespath=[VOCopts.seg.instresdir '/%s.png'];

% initialize layout task paths

VOCopts.layout.imgsetpath=[VOCopts.datadir VOCopts.dataset '/ImageSets/Layout/%s.txt'];
VOCopts.layout.respath=[VOCopts.resdir 'Layout/%s_layout_' VOCopts.testset '.xml'];

% initialize action task paths

VOCopts.action.imgsetpath=[VOCopts.datadir VOCopts.dataset '/ImageSets/Action/%s.txt'];
VOCopts.action.clsimgsetpath=[VOCopts.datadir VOCopts.dataset '/ImageSets/Action/%s_%s.txt'];
VOCopts.action.respath=[VOCopts.resdir 'Action/%s_action_' VOCopts.testset '_%s.txt'];
VOCopts.action.dataPath = [VOCopts.datadir 'action_%s.mat'];
VOCopts.action.fgDataPath = [VOCopts.datadir 'action_fg_%s.mat'];
VOCopts.action.flippedDataPath = [VOCopts.datadir 'action_flipped_%s.mat'];
VOCopts.action.fgFlippedDataPath = [VOCopts.datadir 'action_fg_flipped_%s.mat'];

VOCopts.action.patchPath = [VOCopts.datadir VOCopts.dataset '/ImageDescriptors_%d/sift_%s.mat'];
VOCopts.action.patchPathFlipped = [VOCopts.datadir VOCopts.dataset '/ImageDescriptors_%d/sift_%sf.mat'];
VOCopts.action.patchSizes = [8 12 16 24 30];
VOCopts.action.foregroundScale = 1.5;

VOCopts.action.koenGridSpacing = zeros(10,1);
VOCopts.action.koenGridSpacing(1) = 12;
VOCopts.action.koenFgDataPath = [VOCopts.datadir 'integralHistograms/integral_%s_fg.mat'];
VOCopts.action.koenBgDataPath = [VOCopts.datadir 'integralHistogramsKoen/integral_%s.mat'];

for i=2:length(VOCopts.action.koenGridSpacing)
    VOCopts.action.koenGridSpacing(i) = VOCopts.action.koenGridSpacing(i-1)*1.2;
end
VOCopts.action.koenGridSpacing = [4; 8; floor(VOCopts.action.koenGridSpacing)];
VOCopts.action.koenPatchSizes = 0.2*VOCopts.action.koenGridSpacing;
VOCopts.action.koenPatchPath = [VOCopts.datadir VOCopts.dataset '/ColorDescriptors_%s/sift_%s.dat'];

% initialize the VOC challenge options

% classes

VOCopts.classes={...
    'aeroplane'
    'bicycle'
    'bird'
    'boat'
    'bottle'
    'bus'
    'car'
    'cat'
    'chair'
    'cow'
    'diningtable'
    'dog'
    'horse'
    'motorbike'
    'person'
    'pottedplant'
    'sheep'
    'sofa'
    'train'
    'tvmonitor'};

VOCopts.nclasses=length(VOCopts.classes);	

% poses

VOCopts.poses={...
    'Unspecified'
    'Left'
    'Right'
    'Frontal'
    'Rear'};

VOCopts.nposes=length(VOCopts.poses);

% layout parts

VOCopts.parts={...
    'head'
    'hand'
    'foot'};    

VOCopts.nparts=length(VOCopts.parts);

VOCopts.maxparts=[1 2 2];   % max of each of above parts

% actions

VOCopts.actions={...    
    'phoning'
    'playinginstrument'
    'reading'
    'ridingbike'
    'ridinghorse'
    'running'
    'takingphoto'
    'usingcomputer'
    'walking'};

VOCopts.nactions=length(VOCopts.actions);

% overlap threshold

VOCopts.minoverlap=0.5;

% annotation cache for evaluation

VOCopts.annocachepath=[VOCopts.localdir '%s_anno.mat'];

% options for example implementations

VOCopts.exfdpath=[VOCopts.localdir '%s_fd.mat'];
