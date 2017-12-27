function MI = mutual_info(image1,image2,bcount)
%JOINT_ENTROPY  Image joint entropy estimation using histogramming
%  ENTROPY_SCORE = JOINT_ENTROPY(IMAGE1,IMAGE2) estimates the joint entropy of a
%  pair of images using histogramming. IMAGE1 and IMAGE2 are matrices. The
%  output ENTROPY_SCORE defines the joint information content of the two images.
%
%  ENTROPY_SCORE = JOINT_ENTROPY(IMAGE1,IMAGE2,BUCKET_COUNT) uses the optional
%  input argument BUCKET_COUNT, which specifies the number of buckets to be used
%  for the histogramming operation. If not specified, the default value of
%  BUCKET_COUNT is 32. Note: this number should be a power of two! 

% Input argument checking
%------------------------
if ~exist('bcount')
    bcount = 256;
end;

shift = 8 - log2(bcount);

image1 = floor(image1);
image2 = floor(image2);

% Prepare the histogram: 
% Reorganize the joint intensites into a single number for MATLAB's
% 1D histogram function (assume intensities scaled 0 ... 255)
composite =   bitshift(image1, -shift) ...
            + bitshift(bitshift(image2, -shift), 8-shift);

edges = [0 : bcount*bcount-1];

histogram = histc(composite(:), edges);

sh = sum(histogram);
histogram = histogram * (1 / (sh + (sh==0)));

entropy_score = -sum(histogram.*log2(histogram + (histogram==0)));
%%%


MI = composite;

