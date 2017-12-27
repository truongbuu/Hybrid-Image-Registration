% IMAGE_NORMALIZE normalizes an image to be 0 255 and double
%
% NORM_IM = IMAGE_NORMALIZE(IM)
%
function norm_im = image_normalize(im)

mn = min(im(:));

norm_im = double(im) - double(mn);
norm_im = round(255*norm_im/max(norm_im(:)));

