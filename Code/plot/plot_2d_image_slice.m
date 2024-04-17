%% This simply loads one phantom scan as a full image slice at tum depth

%% Load one phantom scan
ph = 'B0';  
    % Phantom group: 'B0','B10E','B15E','B20E','B30E'.
pl = 1; 
    % Tumour morphology: integer from 1 to 22.
path_to_scan = briqs.load.access_mat_file(ph, pl);
load(path_to_scan);

%% set antenna locations, frequencies and channels 
scan = data;
frequencies = fa;
channel_names = channels;

%% other parameters
antenna_locations = brigid.antenna_locations();
resolution = 2.5e-3;
beamformer = merit.beamformers.DAS; % delay and sum

e_r_list = [8.75, 8.5, 10.25, 11.75, 12.5]; % Glandular-dependent rel permittivity values

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
    e_r = 10.25; % Fixed Value from the same study
end

%% Generate imaging domain 
[points, axes_] = merit.domain.hemisphere('radius', 7e-2, 'resolution', resolution);

%% Uncomment to visualise imaging domain
% figure;
% scatter3(points(:, 1)*100, points(:, 2)*100, points(:, 3)*100, '+');
% title('Imaging domain');
% xlabel('X [cm]');
% ylabel('Y [cm]');
% zlabel('Z [cm]');

%% Calculate delays
% returns a function that calculates the delay to each point from every antenna:
delays = merit.beamform.get_delays(channel_names, antenna_locations, ...
  'relative_permittivity', e_r);

%% Perform imaging
img = abs(merit.beamform(scan, frequencies, points, delays, ...
    beamformer, 'gpu', true));

%% Tumour characterisation
% Localisation
% since z values of tum_location and points not always completely equal:
tum_location = brigid.tumour_location(ph, pl);
z_differences = abs(points(:,3)-tum_location(3));
[~, idx] = min(z_differences); % find index of smallest difference
tum_depth = points(idx, 3);
tum_size = brigid.tumour_sizes(pl);
tum_rad = tum_size(2);

%% Display image
fs = 16;
figure;
im_slice = merit.visualize.get_slice(img, points, axes_, 'z', tum_depth);
imagesc(axes_{1,1}*100, axes_{1,2}*100, im_slice);
xlabel('X [cm]', 'FontSize',fs);
ylabel('Y [cm]', 'FontSize',fs);
title(['Phantom ', ph, ' with Tumour type ', num2str(pl), ...
    ' at depth z = ', num2str(tum_depth*100), ' cm'], 'FontSize',fs); 
c = colorbar;
set(gca,'YDir','normal', 'fontSize', fs)

