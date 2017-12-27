function sse_score = sse(image1,image2)
%SSE  Sum of Squared Error/Intensity function template
%  SSE_SCORE = SSE(IMAGE1,IMAGE2) is an objective function that calculates the
%  sum of the squared difference in the pixel intensities of the two input
%  images, IMAGE1 and IMAGE2. IMAGE1 and IMAGE2 are both matrices. The output
%  SSE_SCORE is the sum of the squared error. 
%
%  You are responsible for updating this function to make it fully operational.

sse_score = sum(sum((image1 - image2).*(image1 - image2)));
