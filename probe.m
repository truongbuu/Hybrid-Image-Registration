function probing_results = probe(fixed_image, moving_image, roi, objective_functions,...
                                 delta_xs,delta_ys,thetas,ploton)
%PROBE  Carries out image probing experiments
%  PROBING_RESULTS = PROBE(FIXED_IMAGE, MOVING_IMAGE, ROI, OBJ_FUNCS, ...
%                          DELTA_XS, DELTA_YS, THETAS, PLOTON)
%  probes the moving image with respect to the fixed image using each of 
%  the specified objective functions within the specified region-of-interest. The
%  moving image is shifted according to delta x,delta y and rotation/theta values.
%
%  Inputs:
%    FIXED_IMAGE  - image matrix. No transformation is applied to this image
%    MOVING_IMAGE - image matrix. Updated transformation estimates are applied
%                   to this image
%    ROI          - region-of-interest to apply objective function to.
%                   Format = [min_x max_x min_y max_y];          
%    OBJ_FUNCS    - A cell array of objective functions:
%                  e.g. {@sse,@sav,@joint_entropy,@xcorr_coeff}
%    DELTA_XS     - pixel shift values in the X direction
%    DELTA_YS     - pixel shift values in the Y direction
%    THETAS       - image rotation values
%    PLOTON       - if nonzero, displays the input images at intermediate stages of
%                   the probing experiments
%
%  Output:
%    PROBING_RESULT - score map/surface containing all the objective function
%                     results evaluated during the probing.
%                     PROBING_RESULTS{k}(yi,xi,ti) is the result for objective
%                     function OBJ_FUNCS{k}, at settings DELTA_XS(xi),
%                     DELTA_YS(yi), THETAS(ti)
%
%  Calls function: image_transform.m

if ~exist('ploton','var') || isempty(ploton)
    ploton = 0;
end

Nobj   = length(objective_functions);
Nx     = length(delta_xs);
Ny     = length(delta_ys);
Ntheta = length(thetas);

if ~exist('roi','var') || isempty(roi)
  roi = [1 size(fixed_image,2) 1 size(fixed_image,2)];
else  
  roi    = round(roi);
end
roiX   = roi(1):roi(2);
roiY   = roi(3):roi(4);

probing_results = cell(1,Nobj);
for f=1:Nobj
  probing_results{f} = zeros([Ny,Nx,Ntheta]);
end


if ploton > 0
    figure(655); subplot(1,3,1); imagesc(fixed_image); colormap(gray); 
    hold on;
    plot([roi(1) roi(1) roi(2) roi(2) roi(1)],[roi(3) roi(4) roi(4) roi(3) roi(3)],'r-');
    title('fixed image'); axis image;
end


for iy = 1:Ny
  dy = delta_ys(iy);

  for ix = 1:Nx
    dx = delta_xs(ix);

    for it = 1:Ntheta
      theta = thetas(it);
      
      if ploton >= 0
        fprintf('dx: %2.2f, dy: %2.2f, theta: %01.3f\r',dx,dy,theta);
      end
      
      % Perform image transform
      transform = [dx dy theta];
      moved_image = image_transform(moving_image,transform);
      
      % Display if ploton
      if ploton > 0
        subplot(1,3,2); imagesc(moved_image); colormap(gray); hold on;
        plot([roi(1) roi(1) roi(2) roi(2) roi(1)],[roi(3) roi(4) roi(4) roi(3) roi(3)],'r-'); 
        hold off;
        title('moved image'); axis image;
  
        subplot(1,3,3); display_alignment(fixed_image,moved_image); hold on;
        plot([roi(1) roi(1) roi(2) roi(2) roi(1)],[roi(3) roi(4) roi(4) roi(3) roi(3)],'r-'); 
        hold off;
        title('Alignment'); axis image;
        drawnow;
      end
      
      % Evaluate each objective function within the region of interest
      for f=1:Nobj
        probing_results{f}(iy,ix,it) = objective_functions{f}(fixed_image(roiY,roiX),moved_image(roiY,roiX));
      end
      
    end
  end
end
