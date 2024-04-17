%% Please run radius sweep first and rankings

% This version shows the best 5 and worst 5 tumour types for the whole 
% radius sweep --- kind of tracks the rankings for each rad size
% two tables will be printed.

close all
clear

%% Choose
ph = 'B15E';
c = 3; % condition
m = 1; % 'SCR', 'SCR-FWHM', 'SMR', 'SMR-FWHM', 'MMR', 'LE', ...
            % 'Smax', 'Cmax', 'Smax-FWHM', 'Cmax-FWHM', 'Smean', 'Cmean'

%% Load workspace according to condition AND metric to calculate
label_list = {'c1,1', 'c1,2', 'c1,3', 'c1,4', 'c2,1', 'c2,2', 'c2,3', 'c2,4'};
source = append('results\', ph, '\workspaces\radius_sweep\', ph, '_', label_list{c}, '.mat');
load(source);
filename = append('results\', ph, '\workspaces\rankings\', ph, '_', label_list{c}, '_', metric_names{m}, '.mat');
load(filename);

%% Initialising the two tables
tab_top5 = table('Size', [5, length(m_range)], 'VariableTypes', ...
    repmat({'double'}, 1, length(m_range)), ...
    'VariableNames', strcat(cellfun(@(x) [num2str(x*1e3), 'mm'], ...
    num2cell(m_range), 'UniformOutput', false)));

tab_worst5 = table('Size', [5, length(m_range)], 'VariableTypes', ...
    repmat({'double'}, 1, length(m_range)), ...
    'VariableNames', strcat(cellfun(@(x) [num2str(x*1e3), 'mm'], ...
    num2cell(m_range), 'UniformOutput', false)));

%% fill tables with top and worst 5 rankings for each signal region size
for i = 1:length(m_range)
    tab = table(all_rankings{i}.TumourType, ...
        all_rankings{i}.Rank, 'VariableNames', {'Tumour', 'Rank'});
    tab_sorted = sortrows(tab, 'Rank'); % Sort based on Rank

    %% Extract the top and worst 5 rankings
    tab_top5{:, i} = tab_sorted{1:5, 'Tumour'};
    tab_worst5{:, i} = tab_sorted{end-4:end, 'Tumour'};
end

%% Could display results
disp('Top 5 Rankings for Each Radius:');
disp(tab_top5);

disp('Worst 5 Rankings for Each Radius:');
disp(tab_worst5);
