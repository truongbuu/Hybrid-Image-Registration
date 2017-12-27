% apply for all p pairs (22) pairs
tic;
close all
clear;
clc;
pixelError = zeros(10,22); % to save the error between each point of the 10
error = zeros(22,1); % to save the error of each pair of the 22 (P type)
ROI22Pairs = [2,3,4,5,8,9,10,11,12,13,14,15,25,26,27,28,30,31,32,36,39,47];
%ROI22Pairs = [15];
rrr=1; % current pair order
for p = ROI22Pairs
    if (p<10)
        pp = ['0',+int2str(p)];
    else
        pp = int2str(p);
    end
%Read image
% f = 'data/P04_1.jpg';
% g = 'data/P04_2.jpg';
f = ['data/P',pp,'_1.jpg'];
g = ['data/P',pp,'_2.jpg'];
refer = double(rgb2gray(imread(f)));
moving = double(rgb2gray(imread(g)));

%%Read Ground truth:
gtruth_file = ['Ground_Truth/control_points_P',pp,'_1_2.txt'];

ground_truth = dlmread(gtruth_file);
refer_pts = ground_truth(:,1:2);
moving_pts = ground_truth(:,3:4);
%%Read ROI
id1 = ['ROI/P',pp,'_1.txt'];
id2 = ['ROI/P',pp,'_2.txt'];

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

%Get central points: %% suppose to be at the end of calculations ROI's
 %refer:
% cen1_x = 0.5*(roi1(1) + roi1(2));
% cen1_y = 0.5*(roi1(3) + roi1(4));
 %moving:
% cen2_x = 0.5*(roi2(1) + roi2(2));
% cen2_y = 0.5*(roi2(3) + roi2(4));

%Adjust the ROI
% This code made problems...
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

% to avoid negative numbers
% check before if any ROI index exceed smallest dim (i.e. 1)
% ROI1
if roi1(1)< 1 %check xmin
    dd = 1 - roi1(1);
    %dd = dd+15; % which will be subtracted later
    roi1(1) = roi1(1) + dd;
    roi1(2) = roi1(2) - dd;
    roi1(3) = roi1(3) + dd;
    roi1(4) = roi1(4) - dd;
end
if roi1(3)< 1 %check ymin
    dd = 1 - roi1(3);
    %dd = dd+15; % which will be subtracted later
    roi1(1) = roi1(1) + dd;
    roi1(2) = roi1(2) - dd;
    roi1(3) = roi1(3) + dd;
    roi1(4) = roi1(4) - dd;
end
% ROI2
if roi2(1)< 1 %check xmin
    dd = 1 - roi2(1);
    %dd = dd+25; % which will be subtracted later
    roi2(1) = roi2(1) + dd;
    roi2(2) = roi2(2) - dd;
    roi2(3) = roi2(3) + dd;
    roi2(4) = roi2(4) - dd;
end
if roi2(3)< 1 %check ymin
    dd = 1 - roi2(3);
    %dd = dd+25; % which will be added later
    roi2(1) = roi2(1) + dd;
    roi2(2) = roi2(2) - dd;
    roi2(3) = roi2(3) + dd;
    roi2(4) = roi2(4) - dd;
end
% roi1(1) = abs(roi1(1)); 
% roi1(2) = abs(roi1(2));
% roi1(3) = abs(roi1(3)); 
% roi1(4) = abs(roi1(4));
% roi2(1) = abs(roi2(1)) ;
% roi2(2) = abs(roi2(2));
% roi2(3) = abs(roi2(3)) ;
% roi2(4) = abs(roi2(4));

% check before if any ROI index exceed largest dim (i.e. 2912)
% ROI1
if roi1(2)> size(refer,1) %check xmax
    dd = roi1(2)-size(refer,1);
    %dd = dd+15; % which will be added later
    roi1(1) = roi1(1) + dd;
    roi1(2) = roi1(2) - dd;
    roi1(3) = roi1(3) + dd;
    roi1(4) = roi1(4) - dd;
end
if roi1(4)> size(refer,1) %check ymax
    dd = roi1(4)-size(refer,1);
    %dd = dd+15; % which will be added later
    roi1(1) = roi1(1) + dd;
    roi1(2) = roi1(2) - dd;
    roi1(3) = roi1(3) + dd;
    roi1(4) = roi1(4) - dd;
end
% ROI2
if roi2(2)> size(refer,1) %check xmax
    dd = roi2(2)-size(refer,1);
    %dd = dd+25; % which will be added later
    roi2(1) = roi2(1) + dd;
    roi2(2) = roi2(2) - dd;
    roi2(3) = roi2(3) + dd;
    roi2(4) = roi2(4) - dd;
end
if roi2(4)> size(refer,1) %check ymax
    dd = roi2(4)-size(refer,1);
    %dd = dd+25; % which will be added later
    roi2(1) = roi2(1) + dd;
    roi2(2) = roi2(2) - dd;
    roi2(3) = roi2(3) + dd;
    roi2(4) = roi2(4) - dd;
end
% check before if any ROI index exceed largest dim (i.e. 2912)
roi1X = roi1(1) : roi1(2);
roi1Y = roi1(3) : roi1(4);
roi2X = roi2(1) : roi2(2);
roi2Y = roi2(3) : roi2(4);
% gives error if there is a (-) number in roi's
referc = refer(roi1Y, roi1X);
movingc = moving(roi2Y, roi2X);

size_refer = size(referc);
% this gave the error when roi1 != roi2.
 regionX = 1 : size_refer(2);
 regionY = 1 : size_refer(1);

% modify
%size_moving = size(movingc);
%if (size(roi1X,2) <= size(roi2X,2)) && (size(roi1Y,2) <= size(roi2Y,2))
%    regionX = 1 : size_refer(2);
%    regionY = 1 : size_refer(1); 
%else
%    regionX = 1 : size_moving(2);
%    regionY = 1 : size_moving(1);
%end

%%%%
%Get central points:
%refer:
cen1_x = 0.5*(roi1(1) + roi1(2));
cen1_y = 0.5*(roi1(3) + roi1(4));
%moving:
cen2_x = 0.5*(roi2(1) + roi2(2));
cen2_y = 0.5*(roi2(3) + roi2(4));

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

roi2(1) = roi2(1) + cen2_x - old_cenx;
roi2(2) = roi2(2) + cen2_x - old_ceny;

roi2(3) = roi2(3) + cen2_y - cen2(2);
roi2(4) = roi2(4) + cen2_y - cen2(2);

%try this:
% roi2(1) = roi2(1) + cen2_x - old_cenx;
% roi2(2) = roi2(2) + cen2_x - old_cenx;
% 
% roi2(3) = roi2(3) + cen2_y - old_ceny;
% roi2(4) = roi2(4) + cen2_y - old_ceny;

transformed1 = image_transform(transform0,[(cen1_x-cen2_x), (cen1_y-cen2_y), 0] );
moving_pts
disp('2nd point transform: ')
moving_pts = point_transform(transform0,moving_pts, [-(cen2_y-cen1_y), -(cen2_x-cen1_x), 0]);
disp('Finished 2nd point transform: ')
moving_pts

roiX = roi1(1):roi1(2);
roiY = roi1(3):roi1(4);


%sol = fminsearch6555(@(x) sav(refer(roiY,roiX), transform(transformed1,x,roiY,roiX)), [10,10,0.01], [1 1 0.01], 'PlotFcns')
% why 1 not 10: error decreased a little bit
sol = fminsearch6555(@(x) -xcorr_coeff(refer(roiY,roiX), transform(transformed1,x,roiY,roiX)), [10,10,0.01], [10 10 0.01], 'PlotFcns')
final = moving_pts; 
ax = vpa(point_transform(transformed1, moving_pts, [0 0 -sol(3)]));

ax(:,1) = ax(:,1) + sol(1);
ax(:,2) = ax(:,2) + sol(2);
moving_pts = ax;


%%Caluculating the error:
dis = 0;
for i = 1:10
    dis = dis + norm(moving_pts(i) - refer_pts(i));
    pixelError(i,rrr) = norm(moving_pts(i) - refer_pts(i));
end
error(rrr) = dis/10;
rrr = rrr+1;
% another way to determine the error:
% if less than 5 pixel so correct registration
% fail =0;
% for i = 1:10
%     if pixelError(i)>=5
%         fail = fail +1;
%     end
% end
end
toc
    