%% 2D slices/cutouts of signal and clutter regions
    % NOTE: They wont be necessarily at the same depth!
    % IMO: 3D modelling is better for visualisation -- but here,
            % selling point is that we can see the intensities

% Updated conditions list
    % 1 = c1,1 = known centre, known tumour size
    % 2 = c1,2 = known centre, known tumour size + added margins
    % 3 = c1,3 = known centre, global radius value used for tumour sizes
    % 4 = c1,4 = known centre, tumour size using FWHM
    % 5 = c2,1 = centre @ brightest spot, known tumour size
    % 6 = c2,2 = centre @ brightest spot, known tumour size + added margins
    % 7 = c2,3 = centre @ brightest spot, global radius value used for tumour sizes
    % 8 = c2,4 = centre @ brightest spot, tumour size using FWHM

clear
close all

%% Initialising
fontSize = 16;
c = 3; % condition
m = 20e-3; % margin/rad size in mm
ph = 'B0'; % Phantom group: 'B0','B10E,'B15E','B20E','B30E'
pl = 3; % Tumour morphology: integer from 1 to 22.

%% Loading data, freq, and channels
path_to_scan = briqs.load.access_mat_file(ph, pl);
load(path_to_scan);

%% set up parameters for imaging and calculating domain
al = brigid.antenna_locations();
resolution = 2.5e-3;
beamformer = merit.beamformers.DAS; % delay and sum

e_r_list = [8.75, 8.5, 10.25, 11.75, 12.5]; % GD rel permittivity values

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


%% Calculate points, axes for plotting and delays
[points, axes_] = merit.domain.hemisphere('radius', 7e-2, 'resolution', resolution);
delays = merit.beamform.get_delays(channels, al, ...
  'relative_permittivity', e_r);

%% Perform imaging
img = abs(merit.beamform(data, fa, points, delays, ...
    beamformer, 'gpu', true));

%% Tumour characterisation
tum_loc = brigid.tumour_location(ph, pl);
z_differences = abs(points(:,3)-tum_loc(3));
[~, idx] = min(z_differences); % find index of smallest difference

tum_depth = points(idx, 3);
tum_size = brigid.tumour_sizes(pl);
tum_rad = tum_size(2);

%% functions for img_t and img_nt
[signal_region, img_t, img_nt] = briqs.partition.regions(img, points, tum_size, ...
    tum_loc, m, c);

%% Metrics calculation -- optional
[scr, smax, cmax] = briqs.metrics.get_SCR(img_t, img_nt);

[~, mx] = max(img_t);
smax_loc = points(mx, :);

%% Plot
figure;
im_slice_t = merit.visualize.get_slice(img_t, points, axes_, 'z', tum_depth);
imagesc(axes_{1,1}*100, axes_{1,2}*100, im_slice_t);
colorbar;
title(['Tumour Location of ', ph, ' P', num2str(pl), ' @ z = ', num2str(tum_depth*100), ' cm']);
xlabel('X [cm]');
ylabel('Y [cm]');
ylim([-7 7]);
xlim([-7 7]);
xticks(-6:2:6); 
yticks(-6:2:6);
%% plot Smax -- optional
hold on;
scatter(tum_loc(2)*100, tum_loc(1)*100, 'rx', 'LineWidth', 1.6);
legend('${d}_{\mathrm{tum}}~$', 'Location', 'northeast', 'FontSize', fontSize, ...
    'Interpreter', 'latex');
% legend('\it{S}_{tum}', 'Location', 'northeast', 'FontSize', fontSize);
set(gca,'YDir','normal', 'fontSize', fontSize)

%% Plot -- brightest
figure;
im_slice_t = merit.visualize.get_slice(img_t, points, axes_, 'z', smax_loc(3));
imagesc(axes_{1,1}*100, axes_{1,2}*100, im_slice_t);
colorbar;
title(['Signal region of ', ph, ' P', num2str(pl), ' @ z = ', num2str(smax_loc(3)*100), ' cm']);
xlabel('X [cm]');
ylabel('Y [cm]');
%% plot Smax -- optional
hold on;
scatter(smax_loc(2)*100, smax_loc(1)*100, 'rx', 'LineWidth', 1.6);
legend('$\hat{S~}$', 'Location', 'northeast', 'FontSize', fontSize, ...
    'Interpreter', 'latex');
% legend('\it{d}_{hat}', 'Location', 'northeast', 'FontSize', fontSize);
% % % legend('\it{d}_{hat}', 'Location', 'northeast', 'FontSize', fontSize);
set(gca,'YDir','normal', 'fontSize', fontSize)

[~, mx] = max(img_nt);
cmax_loc = points(mx, :);

%% Plot Cmax
figure;
im_slice_nt = merit.visualize.get_slice(img_nt, points, axes_, 'z', cmax_loc(3));
imagesc(axes_{1,1}*100, axes_{1,2}*100, im_slice_nt);
colorbar;
title(['Clutter region of ', ph, ' P', num2str(pl), ' @ z = ', num2str(cmax_loc(3)*100), ' cm']);
xlabel('X [cm]');
ylabel('Y [cm]');
ylim([-7 7]);
xlim([-7 7]);
xticks(-6:2:6); 
yticks(-6:2:6);
set(gca,'YDir','normal', 'fontSize', fontSize)
hold on;
scatter(cmax_loc(2)*100, cmax_loc(1)*100, 'kx', 'LineWidth', 1.6);
legend('$\hat{C~}$', 'Location', 'northeast', 'FontSize', fontSize, ...
    'Interpreter', 'latex');
% legend('\it{C}_{max}', 'Location', 'northeast', 'FontSize', fontSize);


%% clutter region -- just by using tum_depth
% clutter depth same as tumour depth
clut_depth = tum_depth;

% Find the indices of points in the clutter region at the specified depth
clutter_indices = find(points(:, 3) == clut_depth);

% collect all points that are at this tumour depth
clutter_points = points(clutter_indices, :);

% Get the max value of the second column
cmax_xyz = max(clutter_points);

distance_LE = 1e3*norm(tum_loc - smax_loc);

% % Plot cmax
% hold on;
% scatter3(cmax_xyz(2), cmax_xyz(1), cmax_xyz(3), 'kx', 'LineWidth', 2);
% legend('\it{C}_{max}', 'Location', 'northeast', 'FontSize', fontSize);
