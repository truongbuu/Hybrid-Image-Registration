%DISPLAY_ALIGNMENT  Shows the alignment of two grayscale images.
%  DISPLAY_ALIGNMENT(IM1,IM2) displays the alignment of two grayscale
%  images in color by putting IM1 in the red channel and IM2 in the blue
%  channel. It calls imagesc() in the current figure to display the result.
%
%  IMA = DISPLAY_ALIGNMENT(IM1,IM2) returns the color alignment image
%  rather than plotting it.
%
% Example:
%   im = imread('cameraman.tif');
%   imt = image_transform(im,[20 20 pi/8]);
%   clf;
%   display_alignment(im,imt);
%
function ima = display_alignment(im1,im2)

im1 = image_normalize(im1);
im2 = image_normalize(im2);

ima = zeros([size(im1) 3]);
ima(:,:,1) = im1/max(im1(:));
ima(:,:,3) = im2/max(im2(:));
imagesc(ima);
axis off; axis image;

function norm_im = image_normalize(im)

mn = min(im(:));

norm_im = double(im) - double(mn);
norm_im = round(255*norm_im/max(norm_im(:)));
