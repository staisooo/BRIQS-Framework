%% For Tumour Detection Criteria
% Updated conditions list
    % 1 = c1,1 = known centre, known tumour size
    % 2 = c1,2 = known centre, known tumour size + added margins
    % 3 = c1,3 = known centre, global radius value used for tumour sizes
    % 4 = c1,4 = known centre, tumour size using FWHM
    % 5 = c2,1 = centre @ brightest spot, known tumour size
    % 6 = c2,2 = centre @ brightest spot, known tumour size + added margins
    % 7 = c2,3 = centre @ brightest spot, global radius value used for tumour sizes
    % 8 = c2,4 = centre @ brightest spot, tumour size using FWHM

close all
clear 

%% Loading P0 scans -- ie the ones with no tumour 
c = 3;
ph = 'B20E';  
    % Phantom group: 'B0','B10E','B15E','B20E','B30E'.
pl = 0; 
    % Tumour morphology: 0
path_to_scan = briqs.load.access_mat_file(ph, pl);
load(path_to_scan);

%% Initialising
metric_names = {'SCR', 'SCR-FWHM', 'SMR', 'SMR-FWHM', 'MMR', 'LE', ...
    'Smax', 'Cmax', 'Smax-FWHM', 'Cmax-FWHM', 'Smean', 'Cmean'};

% Glandular-dependent Relative Permitivitty values
e_r_list = [8.75, 8.5, 10.25, 11.75, 12.5]; 

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
resolution = 2.5e-3; % mm
m = 10e-3;

metric_vals = briqs.load.init_array(1, metric_names);
gpu = true;

load(path_to_scan);
al = brigid.antenna_locations(); 

%% imaging domain, delays, and imaging 
[points, axes_] = merit.domain.hemisphere('radius', 7e-2, 'resolution', resolution);
delays = merit.beamform.get_delays(channels, al, ...
    'relative_permittivity', e_r); 
img = abs(merit.beamform(data, fa, points, delays, beamformer, 'gpu', gpu)); % use GPU

%% Tumour characterisation
tum_size = brigid.tumour_sizes(pl);
tum_location = brigid.tumour_location(ph, pl);
   
%% functions for the 2 region partitions
[signal_region, img_t, img_nt, label] = briqs.partition.regions(img, points, ...
tum_size, tum_location, m, c);

%% Calculate metrics
% 1, BRIQS SCR
[scr, smax, cmax] = briqs.metrics.get_SCR(img_t, img_nt);

% 2, SCR-FWHM
[~, smax_xyz] = merit.metrics.SCR(img, points);
[scr_fwhm, smax_fwhm, cmax_fwhm] = merit.metrics.SCR_FWHM(img, points, smax_xyz);

% 3, SMR -- clutter region = whole image
[smr, ~, cmean] = briqs.metrics.get_SMR(img_t, img_nt);

% 4, SMR-FWHM
smr_fwhm = merit.metrics.SMR(img, points);

% 5, MMR -- clutter region = whole image
[mmr, smean, ~] = briqs.metrics.get_MMR(img_t, img_nt);

% 6, LE (mm)
le_mm = briqs.metrics.get_LE(points, img_t, tum_location);

%% Store values of metrics
metric_vals{1} = scr;
metric_vals{2} = scr_fwhm;
metric_vals{3} = smr;
metric_vals{4} = smr_fwhm;
metric_vals{5} = mmr;
metric_vals{6} = le_mm;

%% Store values of metric quantities
metric_vals{7} = smax;
metric_vals{8} = cmax;
metric_vals{9} = smax_fwhm;
metric_vals{10} = cmax_fwhm;
metric_vals{11} = smean;
metric_vals{12} = cmean;


%% Plot
tum_size = brigid.tumour_sizes(pl);
tum_location = brigid.tumour_location(ph, pl);
z_differences = abs(points(:,3)-tum_location(3));
[~, idx] = min(z_differences); % find index of smallest difference
tum_depth = points(idx, 3);

figure;
im_slice = merit.visualize.get_slice(img, points, axes_, 'z', tum_depth);
imagesc(axes_{1,1}*100, axes_{1,2}*100, im_slice);
xlabel('X [cm]');
ylabel('Y [cm]');
title(['Phantom ', ph, ' P0 at depth z = ', num2str(tum_depth*100), ' cm']); 
colorbar;
% clim([0 0.05]);
set(gca,'YDir','normal')
