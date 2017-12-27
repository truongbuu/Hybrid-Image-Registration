%PROBING_EXPERIMENT  Template probing experiment script.
%
%  This script probes sets up a probing experiment by filling in the 
%  inputs to function 'probe.m' and graphically plotting the output.
%
%  You can/should use this script as a template for your own probing
%  experiments.


% Set the fixed and moving images here
close all;
fixed_image  =  refer;
moving_image =  transformed1;

% Set ROI
% Either set it by hand:           roi= [min_x max_x min_y max_y]
% or specify it graphically with : roi = round(specify_roi(fixed_image));
% or use a predefined one such as: roi = ROI_ALIEN_BRAIN
roi = roi1;

% Display fixed image with ROI
figure;
display_image(fixed_image,'IMAGE NAME HERE');
hold on;
plot([roi(1) roi(1) roi(2) roi(2) roi(1)],[roi(3) roi(4) roi(4) roi(3) roi(3)],'r-'); 


% Make a cell array of all objective functions you want to try out
% The @ specifies a function handle. Don't forget the @
obj_functions = {@sse,@sav,@joint_entropy,@xcorr_coeff};
  
% Specify the translations and rotations you want to probe
% For example, for just translation only do something like the following:
delta_xs   = linspace(-30,30,31); 
delta_ys   = linspace(-30,30,31);
thetas     = 0;

% Set this variable to 1 to show the image transformations as we probe
% Set it to 0 to speed up the proccess
ploton = 1;

% Call function 'probe'
surfaces = probe(fixed_image, moving_image, roi, obj_functions, ...
                 delta_xs,delta_ys,thetas,ploton);
    
                 
% Here are two simple ways to display the results
% You may want to add things like showing the capture region and 
% local and global minima and maxima
% 
% type help local_extrema
%      help global_extream
%      help capture_region
%
% If 2D
if length(thetas) == 1
  
  for f=1:length(obj_functions)
    
    psurface = surfaces{f}(:,:,1);
    
    figure(655+f); clf;
    subplot(1,2,1);
    surf(delta_xs,delta_ys,psurface); colormap default; colorbar;
    xlabel('\delta_x');ylabel('\delta_y'); zlabel(func2str(obj_functions{f}),'interpreter','none');
    title(['Probe surface using ' func2str(obj_functions{f})],'interpreter','none');

    subplot(1,2,2);
    contour(delta_xs,delta_ys,psurface,100,'lineWidth',1);colormap default;
    xlabel('\delta_x');ylabel('\delta_y');
    title(['Probe surface contours using ' func2str(obj_functions{f})],'interpreter','none');
  end
  
% If 3D you can use the volume slicer tool 
else

  %For example, if we want to look at the first objective functions
  %probing surface in 3D we could do:
  volumeslicer(surfaces{1},'DimNames',{'dy','dx','theta'},'DimRanges',{delta_ys,delta_xs,thetas});
  
end
  
