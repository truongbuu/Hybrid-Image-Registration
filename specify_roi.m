% SPECIFY_ROI  Allows you select a region-of-interest in an image
%
% ROI = SPECIFY_ROI(IM)  shows IM and asks user to click and drag a box to
% indicate a region-of-interest. ROI is returned as [min_x max_x min_y
% max_y].
%
function roi = specify_roi(im)

if exist('im','var')
  figure;
  imagesc(im); colormap gray;
end

c='n';

while c~='y'
  title('Click and drag ROI rectangle');
  
  % Use matlabs rbbox example
  k = waitforbuttonpress;
  point1 = get(gca,'CurrentPoint');    % button down detected
  finalRect = rbbox;                   % return figure units
  point2 = get(gca,'CurrentPoint');    % button up detected
  point1 = point1(1,1:2);              % extract x and y
  point2 = point2(1,1:2);
  p1 = min(point1,point2);             % calculate locations
  offset = abs(point1-point2);         % and dimensions
  x = [p1(1) p1(1)+offset(1) p1(1)+offset(1) p1(1) p1(1)];
  y = [p1(2) p1(2) p1(2)+offset(2) p1(2)+offset(2) p1(2)];
  hold on
  axis manual
  h = plot(x,y,'r','linewidth',2);         % draw box around selected region
  
  title('Is this ok? Press ''y'' to finish, or ''n'' to try again');
  while(waitforbuttonpress == 0) end

  c = get(gcf,'CurrentCharacter');
  
  if c~='y' delete(h); end

end

roi = [p1(1) p1(1)+offset(1) p1(2) p1(2)+offset(2)];
