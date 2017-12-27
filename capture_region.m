% CAPTURE_REGION shows the capture region for a particular point in an
%                N-D matrix. 
%
% C = CAPTURE_REGION(DATA,PT) Given and N-D matrix DATA and an Nx1 vector
% PT specifing a point/index in DATA, C is an N-D matrix the same size as
% DATA with 1s in the capture region of PT and 0s everywhere else. That is,
% a 1 in location in C indicates that starting a greedy steepest descent
% algorithm from that location will pass through PT. See the example below.
%
% C = CAPTURE_REGION(DATA) will ask for the user to click on the specified
% point in the 2-D DATA matrix. This does not work for DATA > 2-D.
%
% C =CAPTURE_REGION(DATA,PT,PLOTON) will display the recursive algorithm
% if PLOTON=1
%
% If you want this to work with steepest ascent just pass in -DATA.
%
% Example:
%     z = peaks(50);
%     x = 1:50; y=1:50;
%     [mns,mxs] = global_extrema(z);
%     % Specify the global min as the point we are going to find the 
%     % capture region for.
%     pt = [mns{1};mns{2}];
%     c  = capture_region(z,pt);
%     % Plot Results
%     subplot(1,2,1);
%     contour(z,40); hold on;
%     plot(pt(2),pt(1),'ko','lineWidth',4,'MarkerSize',12);
%     subplot(1,2,2);
%     imagesc(c); axis xy; hold on;
%     plot(pt(2),pt(1),'ko','lineWidth',4,'MarkerSize',12);
%     p = 100*length(find(c(:)==1))/length(c(:));
%     title(['Capture Region ' num2str(p) '% of space shown']);
% 
% Requires neighborsND.m
%
function c = capture_region(data,pt,ploton)

visited = zeros(size(data));
c      = zeros(size(data));

if ~exist('pt','var') || isempty(pt)
  if length(size(data)) == 2
    figure(1);
    imagesc(data); shg;
    title('Click on starting point');
    [x,y] = ginput(1);
    pt = round([y;x]);
  else
   error('Must specify a starting point: pt');
  end
end

if ~exist('ploton')
  ploton = 0;
end

c = inner(data,pt,-inf,c,visited,ploton);


function [c,visited] = inner(data,pt,val,c,visited,ploton)

sz = size(data);

% Get value at point specified
ptCell = mat2cell(pt(:),ones(1,length(pt(:))));
indx = sub2ind(sz,ptCell{:});

visited(indx) = visited(indx)+1;

% Get the neighbors to this point
nbrs  = neighborsND(pt,sz);
nIndx =sub2ind(sz,nbrs{:});
nbrPts = cell2mat(nbrs);

% And the neighbor values
nbrVals = data(nIndx);

% Get the lowest neighbor
steepestVal = min(nbrVals);

%figure(2); 
%imagesc(visited); colormap gray;
%hold on; plot(pt(2),pt(1),'rx'); hold off;
  
% If the lowest neighbor is the value we
% passed in, then this is part of the capture region.
if steepestVal >= val

  % This is part of the capture region
  c(indx) = 1;
  
  if ploton
    figure(1); hold off;
    imagesc(c.*data); colormap gray;
    hold on; plot(pt(2),pt(1),'rx'); hold off;
    drawnow;
  end
  
  % Next find the neighbors you haven't visited or already marked
  % as in the capture region. With this not so great algorithm you
  % can visit a pt at most Nb times where Nb = number of neighbors.
  tovisit = find(visited(nIndx) <= length(nbrVals) & ~c(nIndx));

  for  k=tovisit
    [c,visited] = inner(data,nbrPts(:,k),data(indx),c,visited,ploton);
  end

end





