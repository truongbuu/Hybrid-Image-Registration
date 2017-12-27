close all
clear;
clc;

%Read image
f = 'data/P04_1.jpg';
g = 'data/P04_2.jpg';
refer = double(rgb2gray(imread(f)));
moving = double(rgb2gray(imread(g)));
%%Read Ground truth:
gtruth_file = 'Ground_Truth/control_points_P04_1_2.txt';

ground_truth = dlmread(gtruth_file);
refer_pts = ground_truth(:,1:2);
moving_pts = ground_truth(:,3:4);
%%Read ROI
id1 = 'ROI/P04_1.txt';
id2 = 'ROI/P04_2.txt';

fileID1 = fopen(id1,'r');
formatSpec = '%f';
A = fscanf(fileID1,formatSpec);
roi1 = A';

fileID2 = fopen(id2,'r');
formatSpec = '%f';
A = fscanf(fileID2, formatSpec);
roi2 = A';
%%%%%%%%%%%
%adjust ROI to even number: we dont want (7-2)/2 = 2.5, Ugly code sorry

%%--roi1--%%
if rem(roi1(1), 2) == 1
    roi1(1) = roi1(1) - 1;
end

if rem(roi1(2), 2) == 1
    roi1(2) = roi1(2) + 1;
end

if rem(roi1(3), 2) == 1
   roi1(3) = roi1(3) -1; 
end

if rem(roi1(4), 2) == 1
    roi1(4) = roi1(4) +1;
end

%%--roi2--%

if rem(roi2(1), 2) == 1
    roi2(1) = roi2(1) - 1;
end

if rem(roi2(2), 2) == 1
    roi2(2) = roi2(2) + 1;
end

if rem(roi2(3), 2) == 1
   roi2(3) = roi2(3) -1; 
end

if rem(roi2(4), 2) == 1
    roi2(4) = roi2(4) +1;
end

%%Adjust ROI to be square%%
%roi1
if abs(roi1(2) - roi1(1)) < abs(roi1(3) - roi1(4))
    dif = abs(roi1(3) - roi1(4)) - abs(roi1(2) - roi1(1));
    roi1(1) = roi1(1) - dif/2;
    roi1(2) = roi1(2) + dif/2;
else
    dif = -abs(roi1(3) - roi1(4)) + abs(roi1(2) - roi1(1));
    roi1(3) = roi1(3) - dif/2;
    roi1(4) = roi1(4) + dif/2;
end
%roi2
if abs(roi2(2) - roi2(1)) < abs(roi2(3) - roi2(4))
    dif = abs(roi2(3) - roi2(4)) - abs(roi2(2) - roi2(1));
    roi2(1) = roi2(1) - dif/2;
    roi2(2) = roi2(2) + dif/2;
else
    dif = -abs(roi2(3) - roi2(4)) + abs(roi2(2) - roi2(1));
    roi2(3) = roi2(3) - dif/2;
    roi2(4) = roi2(4) + dif/2;
end


%Get central points:
%refer:
cen1_x = 0.5*(roi1(1) + roi1(2));
cen1_y = 0.5*(roi1(3) + roi1(4));
%moving:
cen2_x = 0.5*(roi2(1) + roi2(2));
cen2_y = 0.5*(roi2(3) + roi2(4));

%Adjust the ROI
if abs(roi1(1) - roi1(2)) > abs(roi2(1) - roi2(2))
    t = abs(roi1(1) - roi1(2)) - abs(roi2(1) - roi2(2));
    roi2(1) = roi2(1) - t/2;
    roi2(2) = roi2(2) + t/2;
else
    t = -abs(roi1(1) - roi1(2)) + abs(roi2(1) - roi2(2));
    roi1(1) = roi1(1) - t/2;
    roi1(2) = roi1(2) + t/2;
end

if abs(roi1(3) - roi1(4)) > abs(roi2(3) - roi2(4))
    t = abs(roi1(3) - roi1(4)) - abs(roi2(3) - roi2(4));
    roi2(3) = roi2(3) - t/2;
    roi2(4) = roi2(4) + t/2;
else
    t = -abs(roi1(3) - roi1(4)) + abs(roi2(3) - roi2(4));
    roi1(3) = roi1(3) - t/2;
    roi1(4) = roi1(4) + t/2;
end

roi1(1) = roi1(1) - 15;
roi1(2) = roi1(2) + 15;
roi1(3) = roi1(3) - 15;
roi1(4) = roi1(4) + 15;


roi2(1) = roi2(1) - 25;
roi2(2) = roi2(2) + 25;
roi2(3) = roi2(3) - 25;
roi2(4) = roi2(4) + 25;

roi1X = roi1(1) : roi1(2);
roi1Y = roi1(3) : roi1(4);
roi2X = roi2(1) : roi2(2);
roi2Y = roi2(3) : roi2(4);

referc = refer(roi1Y, roi1X);
movingc = moving(roi2Y, roi2X);

size_refer = size(referc);
regionX = 1 : size_refer(2);
regionY = 1 : size_refer(1);

%%%%

%%sav, sse, xcorr_coeff, MI2
%%%
sol1 = fminsearch6555(@(x) sav(referc(regionY,regionX), transform(movingc,x,regionY,regionX)), [10,10,0.01], [10 10 0.01], 'PlotFcns');

transform0 = image_transform(moving, [0 0 sol1(3)]);
%transform0 = image_transform(moving, [0 0 0]); %%Testing
%cen2 = point_transform([cen2_x cen2_y], [0 0 0]); %Testing
cen2 = point_transform(moving, [cen2_x cen2_y], [0 0 -sol1(3)]);

old_cenx = cen2_x;
old_ceny = cen2_y;

cen2_x = cen2(1);
cen2_y = cen2(2);

disp('1st point transform: ')
moving_pts = point_transform(moving, moving_pts, [0 0 -sol1(3)]);
%moving_pts = point_transform(moving_pts, [0 0 0]); %testing
disp('Finished 1st point transform: ')

%roi2(1) = roi2(1) + cen2_x - old_cenx;
%roi2(2) = roi2(2) + cen2_x - old_ceny;

%roi2(3) = roi2(3) + cen2_y - cen2(2);
%roi2(4) = roi2(4) + cen2_y - cen2(2);

transformed1 = image_transform(transform0,[(cen1_x-cen2_x), cen1_y-cen2_y, 0] );
moving_pts
disp('2nd point transform: ')
moving_pts = point_transform(transform0,moving_pts, [-(cen2_y-cen1_y), -(cen2_x-cen1_x), 0]);
%roi2 = point_transform(transform0,roi2, [-(cen2_y-cen1_y), -(cen2_x-cen1_x), 0]);
disp('Finished 2nd point transform: ')
moving_pts

roiX = roi1(1):roi1(2);
roiY = roi1(3):roi1(4);

%roiX_big = min(roi1(1), roi2(1)) : max(roi2(2),roi1(2));
%roiY_big = min(roi1(3), roi2(3)) : max(roi2(4),roi1(4));

sol = fminsearch6555(@(x) -xcorr_coeff(refer(roiY,roiX), transform(transformed1,x,roiY,roiX)), [10,10,0.01], [1 1 0.01], 'PlotFcns')
final = moving_pts; 
ax = vpa(point_transform(transformed1, moving_pts, [0 0 -sol(3)]));

ax(:,1) = ax(:,1) + sol(1);
ax(:,2) = ax(:,2) + sol(2);
moving_pts = ax;


%%Caluculating the error:
dis = 0;
for i = 1:10
    dis = dis + norm(moving_pts(i) - refer_pts(i));
end
error = dis/10
    