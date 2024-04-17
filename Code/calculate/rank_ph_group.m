%% Please run metrics_rad_sweep.m first (or metrics_no_rad_sweep.m)
% Uses the workspaces saved in \results\<ph>\workspaces\

%% Conditions
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

%% Choose phantom group, condition, and metric to rank
ph = 'B10E';
c = 7; % condition
met = 1; % 'SCR', 'SCR-FWHM', 'SMR', 'SMR-FWHM', 'MMR', 'LE', ...
            % 'Smax', 'Cmax', 'Smax-FWHM', 'Cmax-FWHM', 'Smean', 'Cmean'

%% Load workspace accordingly
label_list = {'c1,1', 'c1,2', 'c1,3', 'c1,4', 'c2,1', 'c2,2', 'c2,3', 'c2,4'};
filename = append('results\', ph, '\workspaces\radius_sweep\', ph, '_', label_list{c}, '.mat');
load(filename);

%% Extract metric scores
current_metric = metric_vals{met};

all_rankings = cell(1, numel(m_range));
for i = 1:numel(m_range)
    radii = repmat(m_range(i), length(path_to_scans), 1);

    % Combine tumour radii and selected metric scores into one matrix
    df = [radii, current_metric(:, i)];

    % Define ranking score -- just the actual metric score
    score = df(:, 2);
    
    % sort from the highest score
    [~, sorted_idx] = sort(score, 'descend'); 

    % Assign ranks 
    ranks = zeros(size(sorted_idx));
    ranks(sorted_idx) = 1:length(sorted_idx);
    
    % create tumour type index for keeping track
    tum_type_idx = (1:22)'; % Tumour Type P1 to P22
    df = [tum_type_idx, df]; % Add to dataframe (or whatever it's called in MATLAB)

    %% Store the results
    all_rankings{i} = table(df(:, 1), df(:, 2), df(:, 3), score, ranks, ...
        'VariableNames', {'TumourType', 'TumourRadii', metric_names{met}, 'RankingMetric', 'Rank'});
end


%% Save workspace for further analyses
save_folder = append('results\', ph, '\workspaces\rankings\');
filename = append(save_folder, ph, '_', label_list{c}, '_', metric_names{met}, '.mat');
save(filename);

