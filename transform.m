function moved_image = transform(image,x, roiY,roiX)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
moved_image = image_transform(image,x);
moved_image = moved_image(roiY,roiX);
end

