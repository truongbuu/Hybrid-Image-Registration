close all
clear;
clc;

%Read image
f = 'data/P03_1.jpg';
g = 'data/P03_2.jpg';
refer = double(rgb2gray(imread(f)));
moving = double(rgb2gray(imread(g)));

%%Read ROI
id1 = 'ROI/P03_1.txt';
id2 = 'ROI/P03_2.txt';

fileID1 = fopen(id1,'r');
formatSpec = '%f';
A = fscanf(fileID1,formatSpec);
roi1 = A';

fileID2 = fopen(id2,'r');
formatSpec = '%f';
A = fscanf(fileID2, formatSpec);
roi2 = A';
%%%%%%%%%%%%

%Get central points:
%refer:
cen1_x = 0.5*(roi1(1) + roi1(2));
cen1_y = 0.5*(roi1(3) + roi1(4));

%moving:
cen2_x = 0.5*(roi2(1) + roi2(2));
cen2_y = 0.5*(roi2(3) + roi2(4));


transformed1 = image_transform(moving,-[cen2_x-cen1_x, cen2_y-cen1_y, 0] );

%%Adjust the ROI
roi1(1) = roi1(1) - 50;
roi1(2) = roi1(2) + 50;
roi1(3) = roi1(3) - 50;
roi1(4) = roi1(4) + 50;
roiX = roi1(1):roi1(2);
roiY = roi1(3):roi1(4);

roi2(1) = roi2(1) - 200;
roi2(2) = roi2(2) + 200;
roi2(3) = roi2(3) - 200;
roi2(4) = roi2(4) + 200;

sol = fminsearch6555(@(x) sav(refer(roiY,roiX), transform(transformed1,x,roiY,roiX)), [10,10,0.01], [10 10 0.01], 'PlotFcns')


