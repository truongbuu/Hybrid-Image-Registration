function nbrs = neighborsND(pt,dims)

global d; 
global deltas;

pt = pt(:);

% If the last time this was called the dimnesion
% was different, update teh delta
if isempty(d) || d ~= length(pt) || isempty(deltas)
  d = length(pt);
  % Make all possible ND deltas if

  % Get center pt index
  cpt   = repmat({2},1,d);
  cindx = sub2ind(repmat(3,1,d),cpt{:});

  % Create all deltas other than 0,0,0...
  deltas = cell(d,1);
  [deltas{:}] = ind2sub(repmat(3,1,d),[1:(cindx-1) (cindx+1):3^d]);
  deltas = cell2mat(deltas)-2;
end

pts = repmat(pt(:),1,size(deltas,2))+deltas;

% If the dimension of the matrix is included
% remove invalid positions
if nargin > 1
  valid = ones(1,size(pts,2));
  for k=1:length(dims)
    valid = valid & (pts(k,:) > 0) & (pts(k,:) <= dims(k));
  end
  pts = pts(:,valid);
end

%output cell array

nbrs = mat2cell(pts,repmat(1,d,1),size(pts,2));