function evaluation(action)
addpath('VOCdevkit/VOCcode');
% class vec 1, 2 are the label of of all test images, 2 is 0 if a given
% image has no 2 actions in the same image

% cache result
class1_path = ['/scratch/jiadeng_fluxg/jiaxuan/test_result/' action.vname '_' action.nname '/classVec1.mat']
class2_path = ['/scratch/jiadeng_fluxg/jiaxuan/test_result/' action.vname '_' action.nname '/classVec2.mat']
result_path = ['/scratch/jiadeng_fluxg/jiaxuan/test_result/' action.vname '_' action.nname '/result.mat']

if exist(class1_path, 'file') && exist(class2_path, 'file') && exist(result_path, 'file')
    fprintf('using cached file\n');
    load(class1_path); load(class2_path); load(result_path);
else
    [result, classVec1, classVec2] = dttest(['/scratch/jiadeng_fluxg/jiaxuan/RF_related/test_0_' action.vname '_' action.nname '.txt'], [action.vname '_' action.nname]);
end
numImages = size(result, 1);
numClasses = 2; %size(result, 2);
numTrees = size(result, 3);
numTrees
numClasses

fid = fopen(sprintf('/scratch/jiadeng_fluxg/jiaxuan/result_text/%s_%s.txt', action.vname, action.nname), 'w');

for i = 1 : numTrees
    for j = 1 : numClasses
        [rec, prec, ap(j)] = ProcessClass(result(:, :, i), classVec1, classVec2, j);
    end
    %disp(['The overall mAP until the ' num2str(i) '-th tree: ' num2str(mean(ap(1:10)))]);
    disp(['The overall mAP until the ' num2str(i) '-th tree: ' num2str(mean(ap(1:numClasses)))]);
    fprintf(fid, ['The overall mAP until the ' num2str(i) '-th tree: ' num2str(mean(ap(1:numClasses))) '\n']);
end

mkdir(['/scratch/jiadeng_fluxg/jiaxuan/test_result/' action.vname '_' action.nname]);
save(result_path, 'result');
save(class1_path, 'classVec1');
save(class2_path, 'classVec2');
for i = 1 : numClasses
    disp(['  The AP for the ' num2str(i) '-th class is: ' num2str(ap(i))]);
    fprintf(fid, ['  The AP for the ' num2str(i) '-th class is: ' num2str(ap(i)) '\n']);
end

function [rec, prec, ap] = ProcessClass(result, classVec1, classVec2, currClass)

numImages = size(result, 1);
gt = ones(numImages, 1) .* -1;
gt(find(classVec1 == currClass)) = 1;
gt(find(classVec2 == currClass)) = 1;
out = result(:, currClass);
% give out a mask to accomodate neg 2
% if currClass==1 out( anno_test(anno_test(1,:)~=0)==-2 ) = 0 end
% TODO:
% 1) write a new file called evaluation_wo_neg2.m
% 2) write a pythonUtils/speedupEval.py for it
% 3) run it

[so, si] = sort(-out);
tp = gt(si) > 0;
fp = gt(si) < 0;

fp = cumsum(fp);
tp = cumsum(tp);
rec = tp / sum(gt > 0);
prec = tp ./ (fp + tp);
ap = VOCap(rec, prec);
