function I = sp_load_image(image_fname, config)
%disp(image_fname);
I = imread(image_fname);
if ndims(I) == 3
    I = im2double(rgb2gray(I));
else
    I = im2double(I);
end

if(config.imageSize~=0)
  % Resize image to appropriate size
  I = imresize(I, min(config.imageSize/size(I, 1), config.imageSize/size(I, 2)));
end

% Flip image if necessary
if(config.flipImage)
    I = fliplr(I);
end
