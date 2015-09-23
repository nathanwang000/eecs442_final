function [x, y, Xrange, Yrange] = generateSIFTGrid(hgt, wid, patchSize, gridSpacing)

remX = mod(wid-patchSize,gridSpacing);
offsetX = floor(remX/2)+1;
remY = mod(hgt-patchSize,gridSpacing);
offsetY = floor(remY/2)+1;

Xrange = offsetX:gridSpacing:wid-patchSize+1;
Yrange = offsetY:gridSpacing:hgt-patchSize+1;
[gridX,gridY] = meshgrid(Xrange, Yrange);

x = gridX(:)+patchSize/2-0.5;
y = gridY(:)+patchSize/2-0.5;

% note that Xrange, Yrange are in matlab format (1 index), I need to make it 0 index for python
Xrange = Xrange - 1;
Yrange = Yrange - 1;
