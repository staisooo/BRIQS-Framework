%% Radius Sweep calculations for conditions 2,3,6,7
    %  (~200 to 500 s runtime) -- can also just load workspace
    % rad sweep means this code uses more than one signal region size
    % for calculating scores

%% Updated conditions list
    % 1 = c1,1 = known centre, known tumour size
    % 2 = c1,2 = known centre, known tumour size + added margins
    % 3 = c1,3 = known centre, global radius value used for tumour sizes
    % 4 = c1,4 = known centre, tumour size using FWHM
    % 5 = c2,1 = centre @ brightest spot, known tumour size
    % 6 = c2,2 = centre @ brightest spot, known tumour size + added margins
    % 7 = c2,3 = centre @ brightest spot, global radius value used for tumour sizes
    % 8 = c2,4 = centre @ brightest spot, tumour size using FWHM

clear

%% Loading
c = 7;
ph = 'B30E';  % phantoms 'B0', 'B10E', 'B15E', 'B20E', or 'B30E'
path_to_scans = briqs.load.access_mat_files(ph);

%% Initialising
metric_names = {'SCR', 'SCR-FWHM', 'SMR', 'SMR-FWHM', 'MMR', 'LE', ...
    'Smax', 'Cmax', 'Smax-FWHM', 'Cmax-FWHM', 'Smean', 'Cmean'};

% Glandular-dependent Relative Permitivitty values (O'Loughlin D., et al., 2019)
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
gpu = true; % false if no gpu usage

%% Global Radius size range
a = 10; % lower limit in mm 
b = 30; % upper limit in mm
m_range = (a:1:b)*1e-3; % metres

%% Creating the metric matrices
rl = length(path_to_scans); % row length
cl = length(m_range); % column length
metric_vals = briqs.load.init_matrix(rl, cl, metric_names);

%% loop to calculate metrics for all 22 tumour configurations
for i = 1:length(path_to_scans)
    load(path_to_scans{i});
    al = brigid.antenna_locations(); 

    %% imaging domain, delays, and imaging 
    [points, ~] = merit.domain.hemisphere('radius', 7e-2, 'resolution', resolution);
    delays = merit.beamform.get_delays(channels, al, ...
        'relative_permittivity', e_r); 
    img = abs(merit.beamform(data, fa, points, delays, beamformer, 'gpu', gpu));

    %% Tumour characterisation
    tum_size = brigid.tumour_sizes(i);
    tum_location = brigid.tumour_location(ph, i);
       
    for j = 1:length(m_range)
        %% functions for the 2 region partitions
        [signal_region, img_t, img_nt, label] = briqs.partition.regions(img, points, ...
        tum_size, tum_location, m_range(j), c);
        
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
        metric_vals{1}(i, j) = scr;
        metric_vals{2}(i, j) = scr_fwhm;
        metric_vals{3}(i, j) = smr;
        metric_vals{4}(i, j) = smr_fwhm;
        metric_vals{5}(i, j) = mmr;
        metric_vals{6}(i, j) = le_mm;
        
        %% Store values of metric quantities
        metric_vals{7}(i, j) = smax;
        metric_vals{8}(i, j) = cmax;
        metric_vals{9}(i, j) = smax_fwhm;
        metric_vals{10}(i, j) = cmax_fwhm;
        metric_vals{11}(i, j) = smean;
        metric_vals{12}(i, j) = cmean;
        
    end
end

%% All workspaces and excel files included in the results\ folder
% use the following to re-save if re-running

% %% Save Excel
% briqs.save.save_sheets(ph, metric_vals, label, metric_names);
% 
% %% Save Workspace
% save(append('results\', ph, '\workspaces\radius_sweep\', ph, '_', label, '.mat'));
