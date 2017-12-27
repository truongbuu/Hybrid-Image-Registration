function display_image(the_image,image_title)
%DISPLAY_IMAGE  Display medical image with gray colormap and other features
%  DISPLAY_IMAGE(IMAGE) displays the image specified by matrix IMAGE in
%  grayscale with no axis and a colorbar.
%
%  DISPLAY_IMAGE(IMAGE,'IMAGE_TITLE') adds the title 'IMAGE_TITLE' to the image.

% Plot image
%-----------
imagesc(the_image,[0 255]);
colormap(gray);
axis off; axis image;
%colorbar;

% Add title, if specified
%------------------------
if nargin == 2
    title(image_title);
end;
