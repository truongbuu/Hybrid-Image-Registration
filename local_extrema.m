% LOCAL_EXTREMA  find local min and maximum in an N-D matrix (N>=2)
%
% [MINIMA,MAXIMA] = LOCAL_EXTREMA(DATA) returns two cell arrays containing
% the indices of local minima and maxima in the N-D matrix data. MINIMA and
% MAXIMA will be cell arrays of size N.
%
% Example 2-D:
%     z = peaks(50);
%     x = 1:50; y=1:50;
%     [mns,mxs] = local_extrema(z);
%     contour(z,50); hold on;
%     % Plot Minima
%     plot(x(mns{2}),y(mns{1}),'ko','lineWidth',4,'MarkerSize',12);
%     % Plot Maxima
%     plot(x(mxs{2}),y(mxs{1}),'kx','lineWidth',4,'MarkerSize',12);
%     hold off;
%
% Requires neighbordsND.m to be in your path if you are using this on an
% N-D matrix were N >= 3.

function [minima,maxima] = local_extrema(data)

sz = size(data);

if length(sz) < 3
  
  % IF we are 2d or 1d do it the fast way
  mx = ordfilt2(data,9,ones(3,3));
  mx = (mx == data);
  
  mi = ordfilt2(data,1,ones(3,3)); 
  mi = (mi == data);
  
else
  
  % If we are > 2D then do it the slow way
  % until I find a faster method.
  ptC = cell(length(sz),1);
  mi = zeros(prod(sz));
  mx = zeros(prod(sz));
  for k=1:prod(sz)
    val = data(k);
    [ptC{:}] = ind2sub(sz,k);
    pt = cell2mat(ptC);
    
    nbrs = neighborsND(pt,sz);
    nIndx =sub2ind(sz,nbrs{:});
    nbrVals = data(nIndx);
    
    if max(nbrVals) <= val 
      mx(k) = 1;
    elseif min(nbrVals) >= val
      mi(k) = 1;
    end
    
  end

  
end


mxIndx = find(mx(:));
miIndx = find(mi(:));

minima = cell(length(sz),1);
[minima{:}] = ind2sub(sz,miIndx(:)');

maxima = cell(length(sz),1);
[maxima{:}] = ind2sub(sz,mxIndx(:)');
  
