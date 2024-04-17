%% Getting started guide for the BRIQS Framework
% the 'Breast Radar-based Image Quality Analysis' Framework

% A guide to:
    % load breast phantom scans of BRIGID using MERIT and BRIQS functions
    % carry out image quality analysis using BRIQS functions
    % obtain SCR, SMR, MMR, and LE and visualise models in 3d

% Details of the BRIGID breast phantoms used in data collection
    % are given in "Microwave Breast Imaging: experimental
    % tumour phantoms for the evaluation of new breast cancer diagnosis
    % systems", 2018 Biomed. Phys. Eng. Express 4 025036.

% Details of the MERIT open-source toolbox used in 
    % beamforming and imaging are given in "Open-source software for 
    % microwave radar-based image reconstruction", 2018 
    % 12th European Conference on Antennas and Propagation

% Provide a phantom group 'ph' to load and tumour type plug 'pl' to load.
    % Provide a condition for image region characterisation:
        % 1 = c1,1 = known centre, known tumour size
        % 2 = c1,2 = known centre, known tumour size + added margins
        % 3 = c1,3 = known centre, global radius value used for tumour sizes
        % 4 = c1,4 = known centre, tumour size using FWHM
        % 5 = c2,1 = centre @ brightest spot, known tumour size
        % 6 = c2,2 = centre @ brightest spot, known tumour size + added margins
        % 7 = c2,3 = centre @ brightest spot, global radius value used for tumour sizes
        % 8 = c2,4 = centre @ brightest spot, tumour size using FWHM

% close all
clear 

%% Initialise what phantom group and tumour type to load
ph = 'B0'; % Phantom group: 'B0','B10E','B15E','B20E','B30E'.
pl = 13; % Tumour morphology: integer from 1 to 22.

%% Other parameters to set: Condition, R_S if using, gpu, res, beamformer...
c = 3; % Condition 1 to 8 -- see above
R_S = 10e-3; % global region size [m] OR margin size [m] depending on c
    % As an example, try plotting B0 P13 for condition 3 with R_S = 10 mm
    % and 20 mm -- see how the metrics change for the same condition!

gpu = true; % false if not using gpu
resolution = 2.5e-3; % 2.5mm resolution
beamformer = merit.beamformers.DAS; % delay and sum

%% Load data of chosen scan
path_to_scan = briqs.load.access_mat_file(ph, pl);
load(path_to_scan);

%% set antenna locations, frequencies and channels -- from loaded data
scan = data;
frequencies = fa;
channel_names = channels;
antenna_locations = brigid.antenna_locations();

label_list = {'c1,1', 'c1,2', 'c1,3', 'c1,4', 'c2,1', 'c2,2', 'c2,3', 'c2,4'};

% Relative permittivity and beamformer (O'Loughlin D., et al., 2019)
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

%% Calculate delays and perform imaging
[points, axes_] = merit.domain.hemisphere('radius', 7e-2, 'resolution', resolution);
delays = merit.beamform.get_delays(channel_names, antenna_locations, ...
  'relative_permittivity', e_r);
img = abs(merit.beamform(scan, frequencies, points, delays, ...
    beamformer, 'gpu', gpu));

%% Tumour characterisation
% Localisation
% since z values of tum_location and points not always completely equal:
tum_loc = brigid.tumour_location(ph, pl);
z_differences = abs(points(:,3)-tum_loc(3));
[~, idx] = min(z_differences); % find index of smallest difference
tum_depth = points(idx, 3);
tum_size = brigid.tumour_sizes(pl);
tum_rad = tum_size(2);


%% Set up imaging regions and plot
[sig_reg, img_t, img_nt] = briqs.partition.regions(img, points, tum_rad, tum_loc, R_S, c);

signal_3d = points(sig_reg == 1, :); % Points where reg == 1
clutter_3d = points(sig_reg == 0, :); % Points where reg == 0

% Plot image regions as outlined meshes using a convex hull
figure; 
fontSize = 18;

signal_mesh = convhull(signal_3d(:, 2)*100, signal_3d(:, 1)*100, signal_3d(:, 3)*100);
trisurf(signal_mesh, signal_3d(:, 2)*100, signal_3d(:, 1)*100, signal_3d(:, 3)*100, ...
    'FaceAlpha', 0.2, 'FaceColor', 'red', 'EdgeColor', 'red', 'EdgeAlpha', 0.1);

hold on;

clutter_mesh = convhull(clutter_3d(:, 2)*100, clutter_3d(:, 1)*100, clutter_3d(:, 3)*100);
trisurf(clutter_mesh, clutter_3d(:, 2)*100, clutter_3d(:, 1)*100, clutter_3d(:, 3)*100, ...
    'FaceAlpha', 0.2, 'EdgeColor', 'blue', 'EdgeAlpha', 0.1);

title(['3D Plot of Phantom ', ph, ...
    ' P', num2str(pl), ' for Condition ', label_list{c}]);
xlabel('X [cm]', 'FontSize', fontSize);
ylabel('Y [cm]', 'FontSize', fontSize);
zlabel('Z [cm]', 'FontSize', fontSize);

xlim([-10 10]);
ylim([-10 10]);
zlim([0 8]);
xticks(-10:2.5:10);
yticks(-10:2.5:10);
zticks(0:2:8);

set(gca, 'FontSize', fontSize);
hold on;

%% Plotting and Calculating the other metric quantities

% d_tum -- known tumour location
scatter3(tum_loc(2)*100, tum_loc(1)*100, tum_loc(3)*100, 'ro', 'filled', ...
    'markeredgecolor', 'r', 'LineWidth', 3); hold on;

% d_max/d hat i.e.,  S_max/S hat -- brightest pixel in Signal Region 
[~, smx] = max(img_t);
smax_loc = points(smx, :);
scatter3(smax_loc(2)*100, smax_loc(1)*100, smax_loc(3)*100, 'go', ...
    'filled', 'markeredgecolor', 'g', 'LineWidth', 3); hold on;

% C_max -- brightest pixel in Clutter region
[~, cmx] = max(img_nt);
cmax_loc = points(cmx, :);
scatter3(cmax_loc(2)*100, cmax_loc(1)*100, cmax_loc(3)*100, 'ko', ...
    'filled', 'markeredgecolor', 'k', 'LineWidth', 3); hold on;

% Localisation Error between d_tum and S_max -- plot as dashed line
le = round(briqs.metrics.get_LE(points, img_t, tum_loc),1);
plot3([tum_loc(2)*100, smax_loc(2)*100], [tum_loc(1)*100, smax_loc(1)*100], ...
    [tum_loc(3)*100, smax_loc(3)*100], 'k:', 'LineWidth', 2); hold on;

% legend
legend(['Signal region (', num2str(R_S*100), ' cm)'], 'Clutter region', '$\mathbf{d}_{\mathrm{tum}}$', ...
    '$\it\hat{{S}}$','$\it\hat{{C}}$', ['LE = ', num2str(le), ' mm'], ...
    'Location','northeast', 'fontsize', 12, 'interpreter', 'latex');

%% Calculate the Contrast-based Metrics
scr = round(briqs.metrics.get_SCR(img_t, img_nt),2);
smr = round(briqs.metrics.get_SMR(img_t, img),2);
mmr = round(briqs.metrics.get_MMR(img_t, img),2);

disp(['Contrast-based metrics and LE for phantom ', ph, ...
    ' and tumour type P', num2str(pl), ' for Condition ', label_list{c}, ...
    ' (Signal Region Size = ', num2str(R_S*1e3), ' mm).']);

disp(['SCR = ', num2str(scr), ' dB.']);
disp(['SMR = ', num2str(smr), ' dB.']);
disp(['MMR = ', num2str(mmr), ' dB.']);
disp(['LE = ', num2str(le), ' mm.']);

