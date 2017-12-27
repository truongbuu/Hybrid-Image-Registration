function display_data(data,dim)
%DISPLAY_VOLUME  Display 3D datasets slice-by-slice
%  DISPLAY_VOLUME(DATA, DIM) displays 3D dataset DATA slice-by-slice along
%  dimension DIM. DATA is a 3D matrix.

% Last modified: 4/19/06, 2:00pm, Eric Weiss


slices = size(data,dim);

min_data = min(data(:));
max_data = max(data(:));
rows = ceil(slices/4);

figure;
for i = 1 : slices
    subplot(rows,4,i);
    switch dim
        case 1
            imagesc(squeeze(data(i,:,:)),[min_data max_data]);
        case 2
            imagesc(squeeze(data(:,i,:)),[min_data max_data]);
        case 3
            imagesc(squeeze(data(:,:,i)),[min_data max_data]);
    end;
    xlabel(['Slice ' num2str(i)]);
end
colorbar;
