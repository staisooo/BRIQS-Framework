%% All 3d plots 
% For 1 breast phantom model, this will plot the following:
    % Figure 1: 3d phantom model of intensities
    % Figure 2: 3d phantom model of Signal and Clutter Regions (red points
                % for signal region but hollow blue mesh for easier visualisation) 
    % Figure 3: Figure For slicing the phantom in the YZ-plane via an X-slider (as red and blue points)
% Current run time = 12 seconds!!

%% Updated conditions list
    % 1 = c1,1 = known centre, known tumour size
    % 2 = c1,2 = known centre, known tumour size + added margins
    % 3 = c1,3 = known centre, global radius value used for tumour sizes
    % 4 = c1,4 = known centre, tumour size using FWHM
    % 5 = c2,1 = centre @ brightest spot, known tumour size
    % 6 = c2,2 = centre @ brightest spot, known tumour size + added margins
    % 7 = c2,3 = centre @ brightest spot, global radius value used for tumour sizes
    % 8 = c2,4 = centre @ brightest spot, tumour size using FWHM

%% Note it fails for conditions with FWHM -- 
% i think it's because the whole domain is actually the signal region
% so it isnt plotting anything as blue (clutter region)

clear
close all

%% Initialising
c = 7; % condition
m = 20e-3; % margin/rad size in m
ph = 'B0'; % Phantom group: 'B0','B10E,'B15E','B20E','B30E'
pl = 6; % Tumour morphology: integer from 1 to 22.

%% Loading data, freq, and channels
path_to_scan = briqs.load.access_mat_file(ph, pl);
load(path_to_scan);

%% set up parameters for imaging and calculating domain
al = brigid.antenna_locations();
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

fontSize = 16;


%%%%%%%%%%%%%% Plots %%%%%%%%%%%%%%%

%% Figure 1: 3d model with intensities (hard to see through though)
figure(1); 
[signal_region, ~, ~] = briqs.partition.regions(img, points, tum_rad, tum_loc, m, c);
signal_3d = points(signal_region == 1, :); % Points where reg == 1
clutter_3d = points(signal_region == 0, :); % Points where reg == 0

% Plot colours using img intensities
scatter3(signal_3d(:,2)*100, signal_3d(:,1)*100, signal_3d(:,3)*100, 20, img(signal_region == 1), 'filled');
hold on;
scatter3(clutter_3d(:,2)*100, clutter_3d(:,1)*100, clutter_3d(:,3)*100, 20, img(signal_region == 0), 'filled');

title(['3D Model of Phantom ', ph, ' P', num2str(pl)]);
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
colorbar;
hold off; 


%% Figure 2: outline the imaging domain as a mesh
figure(2);
scatter3(signal_3d(:, 2)*100, signal_3d(:, 1)*100, signal_3d(:, 3)*100, 'ro', 'filled');
hold on;

% Extract convex hull of blue dots and plot it as a see-through mesh
k = convhull(clutter_3d(:, 2)*100, clutter_3d(:, 1)*100, clutter_3d(:, 3)*100);
trisurf(k, clutter_3d(:, 2)*100, clutter_3d(:, 1)*100, clutter_3d(:, 3)*100, 'FaceAlpha', 0, 'FaceColor', 'blue', 'EdgeColor', 'blue');

% Set plot properties
title('Signal and Clutter Regions', 'FontSize', fontSize);
xlabel('X [cm]', 'FontSize', fontSize);
ylabel('Y [cm]', 'FontSize', fontSize);
zlabel('Z [cm]', 'FontSize', fontSize);
legend(['Signal Region (', num2str(m*100), ' cm)'], 'Imaging Domain Outline', 'Location','northeast');
xlim([-10 10]);
ylim([-10 10]);
zlim([0 8]);
xticks(-10:2.5:10);
yticks(-10:2.5:10);
zticks(0:2:8);
set(gca, 'FontSize', fontSize);


%% Figure 3: interactive window, x-slider for "yz plane slicing"
figure(3);
scatter3(clutter_3d(:, 2)*100, clutter_3d(:, 1)*100, clutter_3d(:, 3)*100, 'b.');
hold on;
scatter3(signal_3d(:, 2)*100, signal_3d(:, 1)*100, signal_3d(:, 3)*100, 'ro', 'filled');

title('Interactive Window for Slider');
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

%% Create a slider for adjusting x-axis limits
slider = uislider('Position', [100, 50, 300, 3], 'Limits', [-7, 7], ...
    'ValueChangedFcn', @(src, event) updatePlot(src, img, points, tum_loc, tum_rad, m, c, fontSize));
slider.MajorTicks = -7:1:7;
slider.MinorTicks = -7:0.1:7;
slider.Value = 0;


function updatePlot(slider, img, points, tum_loc, tum_rad, m, c, f)
    fontSize = f;
    x_val = slider.Value; % Get current slider value
    fig = gcf;
    clf(fig, 'reset'); % Clear current fig

    %% Plot signal as red and clutter as blue with adjusted x-axis
    [signal_region, ~, ~] = briqs.partition.regions(img, points, tum_loc, tum_rad, m, c);
    signal_3d = points(signal_region == 1, :); % Points where reg == 1
    clutter_3d = points(signal_region == 0, :); % Points where reg == 0

    %% Make new regions based on changes to slider
    new_signal_3d = signal_3d(signal_3d(:,2)*100 >= x_val & signal_3d(:,2)*100 <= 7 & signal_3d(:,2)*100 >= -7, :);
    new_clutter_3d = clutter_3d(clutter_3d(:,2)*100 >= x_val & clutter_3d(:,2)*100 <= 7 & clutter_3d(:,2)*100 >= -7, :);

    scatter3(new_signal_3d(:,2)*100, new_signal_3d(:,1)*100, new_signal_3d(:,3)*100, 20, 'ro', 'filled');
    hold on;
    scatter3(new_clutter_3d(:,2)*100, new_clutter_3d(:,1)*100, new_clutter_3d(:,3)*100, 20, 'b.');

    title(['Interactive Window for Slider (X = ', num2str(round(x_val,2)), ' cm)'], 'FontSize', fontSize);
    xlabel('X [cm]', 'FontSize', fontSize);
    ylabel('Y [cm]', 'FontSize', fontSize);
    zlabel('Z [cm]', 'FontSize', fontSize);
    xlim([-10 10]);
    ylim([-10 10]);
    zlim([0 8]);
    xticks(-10:2.5:10);
    yticks(-10:2.5:10);
    zticks(0:2:8);
    % legend('Signal Region', 'Clutter Region'); % messes with window tho
    set(gca, 'FontSize', fontSize);

end
