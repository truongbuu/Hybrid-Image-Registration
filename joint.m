function result = joint(im1,im2)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
[~,~,indrow] = unique(im1(:)); %// Change here
[~,~,indcol] = unique(im2(:)); %// Change here

jointHistogram = accumarray([indrow indcol], 1);
jointProb = jointHistogram / numel(indrow);
indNoZero = jointHistogram ~= 0;
jointProb1DNoZero = jointProb(indNoZero);
jointEntropy = -sum(jointProb1DNoZero.*log2(jointProb1DNoZero));
result = jointEntropy;
end


