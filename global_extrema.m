% GLOBAL_EXTREMA  find global min and max in an N-D matrix (N>=2)
%
% [MINIMA,MAXIMA] = GLOBAL_EXTREMA(DATA) returns two cell arrays containing
% the indices of global minima and maxima in the N-D matrix data. MINIMA and
% MAXIMA will be cell arrays of size N. If there is more than one extrema
% with the same global min or max value it will return all of them
%
% Example 2-D:
%     z = peaks(50);
%     x = 1:50; y=1:50;
%     [mns,mxs] = global_extrema(z);
%     contour(z,50); hold on;
%     % Plot global Min
%     plot(x(mns{2}),y(mns{1}),'ko','lineWidth',4,'MarkerSize',12);
%     % Plot global Max
%     plot(x(mxs{2}),y(mxs{1}),'kx','lineWidth',4,'MarkerSize',12);
%     hold off;
%
% Requires neighbordsND.m to be in your path if you are using this on an
% N-D matrix were N >= 3
function [minima,maxima] = global_extrema(D)

[mn,mni] = min(D(:));
[mx,mxi] = max(D(:));

sz = size(D);
minima = cell(length(sz),1);
[minima{:}] = ind2sub(sz,mni(:)');
maxima = cell(length(sz),1);
[maxima{:}] = ind2sub(sz,mxi(:)');
