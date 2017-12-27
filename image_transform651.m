%IMAGE_TRANSFORM  Shift and/or rotate image according to transform parameters
%
% THIS IS AN OLD VERSION COMPATIBLE WITH MATLAB 6.5.1
%
% NEW_IMAGE = IMAGE_TRANSFORM(MOVING_IMAGE, T_PARAMS) produces a new image by
%  applying a rigid-body motion to the input image matrix MOVING_IMAGE. The
%  T_PARAMS input is a three-input vector containing the X and Y displacements
%  and the angle of the in-plane rotation (in radians). The rotation is applied
%  about the center of the image. The parameters can be arbitrary floating point
%  values.
%
% NEW_IMAGE = IMAGE_TRANSFORM(MOVING_IMAGE, T_PARAMS,EXTRAPVAL) uses
% EXTRAPVAL to fill in any missing data.
%
% This only works on grayscale images. (i.e. 2D Matrices)
%
% T_PARAMS = [x_shift, y_shift, rotation]
%
%  Positive displacement is to the right, down, and counterclockwise,
%  respectively.
%
% Example:
%   im = imread('cameraman.tif');
%   imt = image_transform(im,[20 20 pi/8]);
%   clf; subplot(2,1,1); imagesc(im); title('Original');
%   subplot(2,1,2); imagesc(imt); title('Transformed');
%   colormap gray;
function new_image = image_transform(moving_image, t_params,extrapval)

if ~exist('extrapval','var'), extrapval = 0; end
if ~isa(moving_image,'double'), moving_image = double(moving_image); end;

[xsize, ysize] = size(moving_image);
[xcoords, ycoords] = meshgrid(1:xsize, 1:ysize);

x_center = xsize / 2;
y_center = ysize / 2;

x_shift = t_params(1);
y_shift = t_params(2);
angle   = t_params(3);

m11 = cos(angle);
m12 = -sin(angle);
m21 = -m12;
%m21 = sin(angle);
m22 = m11;

x_offset = x_center - x_shift;
y_offset = y_center - y_shift;

new_xcoords = m11 * (xcoords - x_center) + m12 * (ycoords - y_center) + x_offset;
new_ycoords = m21 * (xcoords - x_center) + m22 * (ycoords - y_center) + y_offset;

sz = size(moving_image); w = sz(2); h=sz(1);
new_image = interp2(1:w,1:h,moving_image, new_xcoords, new_ycoords,'linear');
new_image(isnan(new_image)) = 0;
