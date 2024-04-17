%% For the non-data-driven analysis (Clutter Region definition)
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

%% Pick a Condition (c = 2, 3, 6, 7) 
label_list = {'c1,1', 'c1,2', 'c1,3', 'c1,4', 'c2,1', 'c2,2', 'c2,3', 'c2,4'};
c = 3;
ph = 'B0'; 
path_to_scans = briqs.load.access_mat_files(ph);

%% quantities we're interested in
names = {"p'", "t'", "c'", "#p", "#t", "#c", "vol_p", "vol_t", "vol_c"};

%% Relative permittivity and beamformer
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
resolution = 2.5e-3;

%% Margin range (mm) with 1mm step increase 
a = 10; % lower limit
b = 30; % upper limit
m_range = (a:1:b)*1e-3;

%% Creating the metric and qty matrices
rl = length(path_to_scans); % row length
cl = length(m_range); % column length
values = briqs.load.init_matrix(rl, cl, names);

%% loop to calculate metrics for all 22 tumour configurations
for i = 1:length(path_to_scans)
    load(path_to_scans{i});
    al = brigid.antenna_locations(); 

    %% imaging domain, delays, and imaging 
    [points, ~] = merit.domain.hemisphere('radius', 7e-2, 'resolution', resolution);
    delays = merit.beamform.get_delays(channels, al, ...
        'relative_permittivity', e_r); 
    img = abs(merit.beamform(data, fa, points, delays, beamformer, 'gpu', true)); % use GPU

    %% Tumour characterisation
    tum_size = brigid.tumour_sizes(i);
    tum_location = brigid.tumour_location(ph, i);
       
    for j = 1:length(m_range)
        %% functions for the 2 region partitions
        [tumour_region, img_t, img_nt, label] = briqs.partition.regions(img, points, ...
        tum_size, tum_location, m_range(j), c);

        [p_dash, t_dash, c_dash] = briqs.testing_grounds.calc_mean_regions(img, img_t, img_nt);
        
        [hash_p, hash_t, hash_c] = briqs.testing_grounds.calc_num_points(tumour_region);

        vol_p = resolution*hash_p;
        vol_t = resolution*hash_t;
        vol_c = resolution*hash_c;
        
        %% Store values
        values{1}(i, j) = p_dash;
        values{2}(i, j) = t_dash;
        values{3}(i, j) = c_dash;
        values{4}(i, j) = hash_p;
        values{5}(i, j) = hash_t;
        values{6}(i, j) = hash_c;
        values{7}(i, j) = vol_p;
        values{8}(i, j) = vol_t;
        values{9}(i, j) = vol_c;
        
    end
end

% %% Save in 'mean' directory
% save_folder = append('\results\', ph, '\workspaces\mean\');
% filename = append(save_folder, ph, '_', label_list{c}, '.mat');
% save(filename);

