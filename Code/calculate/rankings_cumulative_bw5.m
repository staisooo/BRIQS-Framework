%% Please run radius sweep first and rankings

% Rank top 5 best and top 5 worst (cumulative way)
% will print out the 10 tumour types that were the best and worst
% in rankings for the duration of the radius sweep

close all
clear

%% Choose
ph = 'B0';
c = 3; % condition 
m = 1; % 'SCR', 'SCR-FWHM', 'SMR', 'SMR-FWHM', 'MMR', 'LE', ...
            % 'Smax', 'Cmax', 'Smax-FWHM', 'Cmax-FWHM', 'Smean', 'Cmean'

%% Load workspace according to condition AND metric to calculate
label_list = {'c1,1', 'c1,2', 'c1,3', 'c1,4', 'c2,1', 'c2,2', 'c2,3', 'c2,4'};
source = append('results\', ph, '\workspaces\radius_sweep\', ph, '_', label_list{c}, '.mat');
load(source);
filename = append('results\', ph, '\workspaces\rankings\', ph, '_', label_list{c}, '_', metric_names{m}, '.mat');
load(filename);

%% Compare rankings in one table
tab = table(all_rankings{1}.TumourType, 'VariableNames', {'Tumour'});

% Add ranking columns for each radius
for i = 1:numel(m_range)
    ranking_column = all_rankings{i}.Rank;
    tab = [tab, table(ranking_column, 'VariableNames',...
        {[num2str(m_range(i)*1e3), 'mm']} )];
end
disp(tab); % diplay ranking table

%% Get the Top 5 and worst 5
tumour_types = tab{:, 'Tumour'};

%% Count top 5 for all radii
cumulative_r_counts = sum(tab{:, 2:end} <= 5, 2);
[~, top5_ranks_idx] = sort(cumulative_r_counts, 'descend');
top5_types = tumour_types(top5_ranks_idx(1:5));

%% the worst 5
bottom5_types = tumour_types(top5_ranks_idx(end-4:end));

%% Summarise
disp(['For ', ph, ' phantoms, the ' metric_names{m}, ' rankings for ', label_list{c}, ' ', ...
    'according to a cumulative ranking count score: ']);
disp(['The Top 5 ranked tumour types are: ', num2str(top5_types'), '  and']);
disp(['The Bottom 5 ranked tumour types are: ', num2str(bottom5_types')]);

