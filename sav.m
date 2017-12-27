function sav_score = sav(image1, image2)
%SAV  Sum of Absolute Value function template
%  SAV_SCORE = SAV(IMAGE1,IMAGE2) is an objective function that calculates the
%  sum of the absolute value of the intensity difference between the pixels of
%  the two input images, IMAGE1 and IMAGE2. IMAGE1 and IMAGE2 are both matrices.
%  The output SAV_SCORE is the sum of the absolute value of the intensity
%  difference.
%
%  You are responsible for updating this function to make it fully operational.

sav_score = sum(sum(abs(image1-image2)));
