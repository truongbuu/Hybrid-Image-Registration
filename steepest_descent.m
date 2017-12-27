% STEEPEST_DESCENT runs a greedy steepest descent
% 
% [ENDPT,VISITED] = STEEPEST_DESCENT(DATA,PT,PLOTON) runs steepest descent
% starting at point PT in DATA. ENPT is where it stops and VISTED is a
% matrix the same size as DATA with 1s in all the locations visited when
% running steepest descent. PLOTON=1 shows the algorithm in action in 2D.
% 
function [endPt,visited] = steepest_descent(data,pt,ploton)

visited = zeros(size(data));

sz = size(data);
if ~exist('ploton','var'), ploton =0; end

if ~exist('pt','var') || isempty(pt) && length(size(data)) == 2
  figure(1);
  imagesc(data); shg;
  title('Click on starting point');
  [x,y] = ginput(1);
  pt = round([y;x]);
elseif ~exist('pt','var')
  error('pt','%s','Must specify a starting point');
end
startPt = pt;
canRoll = 1;

while canRoll

  % Get value at point specified
  ptCell = mat2cell(pt(:),ones(1,length(pt(:))));
  indx = sub2ind(sz,ptCell{:});
  val = data(indx);
  visited(indx) = 1;

  % Get the neighbors to this point
  nbrs  = neighborsND(pt,sz);
  nIndx =sub2ind(sz,nbrs{:});
  nbrPts = cell2mat(nbrs);

  % And the neighbor values
  nbrVals = data(nIndx);

  % Get the lowest neighbor
  [steepestVal,steepestIndx] = min(nbrVals);
  
  if steepestVal > val
    canRoll = 0;
  else
    pt = nbrPts(:,steepestIndx);
  end
  
  if ploton
    figure(1); hold off;
    imagesc(visited.*data); colormap gray;
    drawnow;
  end
  
end

endPt = pt;



