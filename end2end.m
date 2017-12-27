close all;
load_reg_data
fixed_image = double(im1);
moving_image = double(im2);
imshow(scan1)
display_image(mri);
%roi = ROI_MRI;
%roiX = roi(1):roi(2);
%roiY = roi(3):roi(4);
roiX = 1:2912; roiY = 1:2912;
%sol = fminsearch6555(@(x) joint_entropy(fixed_image(roiY,roiX), transform(moving_image,x,roiY,roiX)), [40,40,pi/4], [10 10 0.01], 'PlotFcns')
sol = fminsearch6555(@(x) sse(fixed_image(roiY,roiX), transform(moving_image,x,roiY,roiX)), [40,40,pi/4], [10 10 0.01], 'PlotFcns')

moved_image = image_transform(moving_image, sol);
imshow(uint8(fixed_image - moved_image));
figure();
imshow(uint8(moving_image));
figure();
imshow(uint8(moved_image));