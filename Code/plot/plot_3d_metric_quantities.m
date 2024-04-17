%% 3d plots including metric quantities: dmax/Smax, dtum, LE, Cmax 
% Conditions
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

%% initialise condition, margin, phantom group, and tumour type ('plug')
c = 3;
margin = 25e-3; % region size in mm/margin size
ph = 'B0'; % Phantom group: 'B0','B10E','B15E','B20E','B30E'.
pl = 13; % Tumour morphology: integer from 1 to 22.

% Load
path_to_scan = briqs.load.access_mat_file(ph, pl);
load(path_to_scan);
label_list = {'c1,1', 'c1,2', 'c1,3', 'c1,4', 'c2,1', 'c2,2', 'c2,3', 'c2,4'};

%% set antenna locations, frequencies and channels 
scan = data;
frequencies = fa;
channel_names = channels;

%% other parameters
antenna_locations = brigid.antenna_locations();

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

res = 2.5e-3;
beamformer = merit.beamformers.DAS; % delay and sum
gpu = true;

%% Calculate delays and perform imaging
[points, axes_] = merit.domain.hemisphere('radius', 7e-2, 'resolution', res);
delays = merit.beamform.get_delays(channel_names, antenna_locations, ...
  'relative_permittivity', e_r);

img = abs(merit.beamform(scan, frequencies, points, delays, ...
    beamformer, 'gpu', gpu));

tum_loc = brigid.tumour_location(ph, pl);
z_differences = abs(points(:,3)-tum_loc(3));
[~, idx] = min(z_differences);
tum_depth = points(idx, 3);
tum_size = brigid.tumour_sizes(pl);
tum_rad = tum_size(2);

%% Set up regions for outlines
[sig_reg, img_t, img_nt] = briqs.partition.regions(img, points, tum_rad, tum_loc, margin, c);

signal_3d = points(sig_reg == 1, :); % Points where reg == 1
clutter_3d = points(sig_reg == 0, :); % Points where reg == 0

%% Plot as red and blue mesh outlines
fontSize = 20;
figure;

%% Extract convex hull of signal and clutter regions and plot as see-through mesh
sig_mesh = convhull(signal_3d(:, 2)*100, signal_3d(:, 1)*100, signal_3d(:, 3)*100);
trisurf(sig_mesh, signal_3d(:, 2)*100, signal_3d(:, 1)*100, signal_3d(:, 3)*100, ...
    'FaceAlpha', 0.2, 'FaceColor', 'red', 'EdgeColor', 'red', 'EdgeAlpha', 0.1);

hold on;

clut_mesh = convhull(clutter_3d(:, 2)*100, clutter_3d(:, 1)*100, clutter_3d(:, 3)*100);
trisurf(clut_mesh, clutter_3d(:, 2)*100, clutter_3d(:, 1)*100, clutter_3d(:, 3)*100, ...
    'FaceAlpha', 0.2, 'EdgeColor', 'blue', 'EdgeAlpha', 0.1);

title(['Metric Quantities for ', ph, ...
    ' P', num2str(pl), ' (', label_list{c} ,')']);
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
grid off;

%% Plot four quantities

% d_tum -- known tumour location as red point
scatter3(tum_loc(2)*100, tum_loc(1)*100, tum_loc(3)*100, 'ro', 'filled', ...
    'markeredgecolor', 'r', 'LineWidth', 3);
hold on;

% d_max -- brightest pixel location in Signal Region (Smax if centred there)
% green point
[~, smx] = max(img_t);
smax_loc = points(smx, :);
scatter3(smax_loc(2)*100, smax_loc(1)*100, smax_loc(3)*100, 'go', ...
    'filled', 'markeredgecolor', 'g', 'LineWidth', 3);
hold on;

% C_max -- brightest pixel location in Clutter region as black point
[~, cmx] = max(img_nt);
cmax_loc = points(cmx, :);
scatter3(cmax_loc(2)*100, cmax_loc(1)*100, cmax_loc(3)*100, 'ko', ...
    'filled', 'markeredgecolor', 'k', 'LineWidth', 3);

hold on;

% Localisation error 
distance_LE = 1e3*norm(tum_loc - smax_loc);
% plot dotted line
plot3([tum_loc(2)*100, smax_loc(2)*100], [tum_loc(1)*100, smax_loc(1)*100], ...
    [tum_loc(3)*100, smax_loc(3)*100], 'k:', 'LineWidth', 2);
hold on;

% Legend
legend(['Signal region (', num2str(margin*100), ' cm)'], 'Clutter region', '$\it{d}_{\mathrm{tum}}$', ...
    '$\it\hat{{S}}$','$\it\hat{{C}}$', ['LE = ', num2str(round(distance_LE,1)), ' mm'], ...
    'Location','northeast', 'fontsize', 12, 'interpreter', 'latex');

%% Calculate SCR and LE 
disp(['SCR = ', num2str(round(briqs.metrics.get_SCR(img_t, img_nt),2)), ...
    ' dB for ', label_list{c}, '.']);
disp(['LE = ', num2str(round(briqs.metrics.get_LE(points, img_t, tum_loc),2)), ...
    ' mm for ', label_list{c}, '.']);

