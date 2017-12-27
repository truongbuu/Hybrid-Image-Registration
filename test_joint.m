bcount = 256;
image1 = mri;
image2 = ct;

shift = 8 - log2(bcount);

image1 = floor(image1);
image2 = floor(image2);

composite =   bitshift(image1, -shift) ...
            + bitshift(bitshift(image2, -shift), 8-shift);

edges = [0 : bcount*bcount-1];

histogram = histc(composite(:), edges);

sh = sum(histogram);
histogram = histogram * (1 / (sh + (sh==0)));

entropy_score = -sum(histogram.*log2(histogram + (histogram==0)));