function [idx] = getDistIdx(mat1, mat2, maxPerIteration)

if(~exist('maxPerIteration', 'var'))
    maxPerIteration = 100;
end

numIterations = ceil(size(mat1, 1)/maxPerIteration);
idx = zeros(size(mat1, 1),1);

for i=1:numIterations
    startIdx = (i-1)*maxPerIteration + 1;
    endIdx = min(i*maxPerIteration, size(mat1, 1));
    [~, idx(startIdx:endIdx)] = min(sp_dist2(mat1(startIdx:endIdx, :), mat2), [], 2);
end
