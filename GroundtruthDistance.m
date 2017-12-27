pixelError = zeros(10,22); % to save the error between each point of the 10
error = zeros(22,1); % to save the error of each pair of the 22 (P type)
ROI22Pairs = [2,3,4,5,8,9,10,11,12,13,14,15,25,26,27,28,30,31,32,36,39,47];
%ROI22Pairs = [15,25,26,27,28,30,31,32,36,39,47];
rrr=1; % current pair order
for p = ROI22Pairs
    if (p<10)
        pp = ['0',+int2str(p)];
    else
        pp = int2str(p);
    end

%%Read Ground truth:
gtruth_file = ['Ground_Truth/control_points_P',pp,'_1_2.txt'];
ground_truth = dlmread(gtruth_file);
refer_pts = ground_truth(:,1:2);
moving_pts = ground_truth(:,3:4);

%%Caluculating the error:
dis = 0;
for i = 1:10
    dis = dis + norm(moving_pts(i) - refer_pts(i));
    pixelError(i,rrr) = norm(moving_pts(i) - refer_pts(i));
end
error(rrr) = dis/10;
rrr = rrr+1;
end