%% Reconstruct the same phantom model in x different image resolutions
close all
clear

res_vals = [5e-3 2.5e-3, 1e-3]; % in mm

%% Loading and initialisation
ph = 'B15E'; % 'B0','B10E','B15E','B20E','B30E'.
pl = 2; % Tumour morphology: integer from 1 to 22.

path_to_scan = briqs.load.access_mat_file(ph, pl);
load(path_to_scan);
al = brigid.antenna_locations();

% Relative permittivity and beamformer
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

beamformer = merit.beamformers.DAS; % delay and sum
fontSize = 14;
gpu = true;

for i = res_vals
    %% Get other parameters for imaging domain
    [points, axes_] = merit.domain.hemisphere('radius', 7e-2, ...
        'resolution', i);
    
    %% Calculate delays and perform imaging
    delays = merit.beamform.get_delays(channels, al, 'relative_permittivity', e_r);
    img = abs(merit.beamform(data, fa, points, delays, beamformer, 'gpu', gpu));
    
    %% Tumour characterisation for ph
    tum_location = brigid.tumour_location(ph, pl);
    z_differences = abs(points(:, 3) - tum_location(3));
    [~, idx1] = min(z_differences); % find index of smallest difference
    tum_depth = points(idx1, 3);
    tum_size = brigid.tumour_sizes(pl);
    tum_rad = tum_size(2);
    
    %% Calculate SCR (FWHM from MERIT)
    [~, dmax_xyz] = merit.metrics.SCR(img, points);
    [scr, t_max, c_max] = merit.metrics.SCR_FWHM(img, points, dmax_xyz);
    
    
    %% Calculate SCR (BRIQS) -- priori location and size
    [tumour_region, img_t, img_nt, label] = briqs.partition.regions(img, points, ...
    tum_size, tum_location, 0.02, 1);
    % [scr, t_max, c_max] = briqs.metrics.get_SCR(img_t, img_nt);
    
    
    %% LE
    % le_mm = briqs.metrics.get_LE(points, img_t, tum_location);
    
    %% Display image for ph
    figure;
    im_slice = merit.visualize.get_slice(img, points, axes_, 'z', tum_depth);
    imagesc(axes_{1,1}*100, axes_{1,2}*100, im_slice);

    xlabel('X [cm]', 'FontSize', 20);
    ylabel('Y [cm]', 'FontSize', 20);

    title([ph, ' P', num2str(pl), ...
        ' at depth z = ', num2str(tum_depth*100), ...
        ' cm (SCR = ', num2str(round(scr, 2)), ' dB)']); 

    c = colorbar;
    set(gca,'YDir','normal', 'fontSize', fontSize);
    
    %% Plot image max as d hat ie max of whole img -- use latex interpreter
    hold on;
    plot(dmax_xyz(2)*100, dmax_xyz(1)*100, 'rx', 'MarkerSize', 7, 'LineWidth', 2); 
    
    legend('$\hat{d}~$', 'Location', 'northeast', 'FontSize', fontSize, ...
        'interpreter', 'latex');
    
end

