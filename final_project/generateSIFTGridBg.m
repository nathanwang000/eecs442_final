function [x, y, gridX, gridY] = generateSIFTGridBg(hgt, wid, patchSizeX, gridSpacingX, patchSizeY, gridSpacingY)

remX = mod(wid-patchSizeX,gridSpacingX);
offsetX = floor(remX/2)+1;
remY = mod(hgt-patchSizeY,gridSpacingY);
offsetY = floor(remY/2)+1;

[gridX,gridY] = meshgrid(offsetX:gridSpacingX:wid-patchSizeX+1, offsetY:gridSpacingY:hgt-patchSizeY+1);

%if mod(patchSize, 2) == 0
x = gridX(:)+patchSizeX/2-0.5;
y = gridY(:)+patchSizeY/2-0.5;
%else