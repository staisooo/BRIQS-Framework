%% Please load rank_ph_group first
   % graphs spearman CC plot vs increasing signal region size
   % Loads one condition, one phantom group (22 tum types) TWICE
        % Loaded conditions 3 and 7 usually

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

%% Choose 1dt set of phantom group, condition, and metric (already ranked)
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

tab1 = table(all_rankings{1}.TumourType, 'VariableNames', {'Tumour'});

for i = 1:numel(m_range)
    ranking_column = all_rankings{i}.Rank;
    tab1 = [tab1, table(ranking_column, 'VariableNames',...
        {[num2str(m_range(i)*1e3), 'mm']} )];
end

%% Load the 2nd set
ph = 'B0';
c = 7; % condition -- refer back to getting_started.m
m = 1; % 'SCR', 'SCR-FWHM', 'SMR', 'SMR-FWHM', 'MMR', 'LE', ...
            % 'Smax', 'Cmax', 'Smax-FWHM', 'Cmax-FWHM', 'Smean', 'Cmean'

%% Load workspace according to condition AND metric to calculate
label_list = {'c1,1', 'c1,2', 'c1,3', 'c1,4', 'c2,1', 'c2,2', 'c2,3', 'c2,4'};
source = append('results\', ph, '\workspaces\radius_sweep\', ph, '_', label_list{c}, '.mat');
load(source);
filename = append('results\', ph, '\workspaces\rankings\', ph, '_', label_list{c}, '_', metric_names{m}, '.mat');
load(filename);

tab2 = table(all_rankings{1}.TumourType, 'VariableNames', {'Tumour'});

for i = 1:numel(m_range)
    ranking_column = all_rankings{i}.Rank;
    tab2 = [tab2, table(ranking_column, 'VariableNames',...
        {[num2str(m_range(i)*1e3), 'mm']} )];
end

%% Extract rankings from tables
n = length(path_to_scans);
rankings1 = zeros(n, numel(m_range));
rankings2 = zeros(n, numel(m_range));

for i = 1:numel(m_range)
    rankings1(:, i) = tab1{:, i + 1};
    rankings2(:, i) = tab2{:, i + 1};
end

%% Calculate Spearman correlation coefficients (and optionally, p-vals)
rho_vals = zeros(1, numel(m_range));
p_vals = zeros(1, numel(m_range));

for i = 1:numel(m_range)
    [rho_vals(i), p_vals(i)] = corr(rankings1(:, i), rankings2(:, i), 'Type', 'Spearman');
end

%% Update: Plot rho vs increasing radius sizea
figure;
plot(m_range*1e3, rho_vals, 'o-', 'LineWidth', 2);
xlabel('Radius Size (mm)');
xticks(10:1:30);
ylabel("Spearman's Correlation Coefficient");
title(['Phantom ', ph, ': Condition c1,3 vs c2,3 (', metric_names{m}, ')']);
grid on;
grid minor;
% ylim([-1 1]);
