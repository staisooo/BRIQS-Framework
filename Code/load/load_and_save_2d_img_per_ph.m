%% only run if you want to load and download 22 2d images
% from one phantom group
% 2d slice depth is at known tumour location

close all
clear

%% Choose phantom group to load
ph = 'B0'; % 'B0','B10E','B15E','B20E','B30E'
path_to_scans = briqs.load.access_mat_files(ph);

%% Relative permittivity and beamformer
e_r_list = [8.75, 8.5, 10.25, 11.75, 12.5]; % Glandular-dependent values

if strcmp(ph, 'B0') 
    e_r = e_r_list(1);
elseif strcmp(ph, 'B10E')
    e_r = e_r_list(2);
elseif strcmp(ph, 'B15E')
    e_r = e_r_list(3);
elseif strcmp(ph, 'B20E')
    e_r = e_r_list(4);
elseif strcmp(ph, 'B30E')
    e_r = e_r_list(5);
else
    e_r = 10.25; % Fixed Value
end

beamformer = merit.beamformers.DAS; % delay-and-sum beamformer
resolution = 2.5e-3;

%% loop to save all 22 tumour images per group
for i = 1:length(path_to_scans)
    load(path_to_scans{i});
    al = brigid.antenna_locations(); 

    %% Imaging domain, delays, and imaging 
    [points, axes_] = merit.domain.hemisphere('radius', 7e-2, 'resolution', resolution);
    delays = merit.beamform.get_delays(channels, al, 'relative_permittivity', e_r); 
    img = abs(merit.beamform(data, fa, points, delays, beamformer, 'gpu', true)); 

    %% Tumour characterisation
    tum_size = brigid.tumour_sizes(i);
    tum_location = brigid.tumour_location(ph, i);
    z_differences = abs(points(:,3)-tum_location(3));
    [~, idx] = min(z_differences); % find index of smallest difference
    tum_depth = points(idx, 3);

    %% Display image
    figure;
    im_slice = merit.visualize.get_slice(img, points, axes_, 'z', tum_depth);
    imagesc(axes_{1,1}*100, axes_{1,2}*100, im_slice);
    xlabel('X [cm]');
    ylabel('Y [cm]');
    title(['Phantom ', ph, ' with Tumour type ', num2str(i), ...
        ' at depth z = ', num2str(tum_depth*100), ' cm']); 
    colorbar;
    set(gca,'YDir','normal')

    briqs.save.save_images(ph, i);

end
