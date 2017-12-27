function new_point = point_transform(moving_image, refer_point, t_params)
%theta = t_params(3);
%A2 = [cos(theta) sin(theta) 0; -sin(theta) cos(theta) 0; t_params(1) t_params(2) 1];
%tform3 = maketform('affine', A2);

%uv3 = tformfwd(tform3, refer_point);

[xsize, ysize] = size(moving_image);
[xcoords, ycoords] = meshgrid(1:xsize, 1:ysize);

x_center = xsize / 2;
y_center = ysize / 2;

x_shift = t_params(1);
y_shift = t_params(2);
angle   = t_params(3);

m11 = cos(angle);
m12 = -sin(angle);
m21 = -m12;
%m21 = sin(angle);
m22 = m11;

x_offset = x_center - x_shift;
y_offset = y_center - y_shift;

s = size(refer_point);

%new_xcoords = m11 * (xcoords - x_center) + m12 * (ycoords - y_center) + x_offset;
%new_ycoords = m21 * (xcoords - x_center) + m22 * (ycoords - y_center) + y_offset;
for i = 1:s(1)
    refer_point(i,1) = m11 * (refer_point(i,1) - x_center) + m12 * (refer_point(i,2) - y_center) + x_center + m11*y_shift + m12*x_shift;
    refer_point(i,2) = m21 * (refer_point(i,1) - x_center) + m22 * (refer_point(i,2) - y_center) + y_center + m21*y_shift + m22*x_shift;
end


new_point = refer_point;

