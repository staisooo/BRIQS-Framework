%% Superimpose all rank correlation (Spearman CC) plots of the 5 ph groups

close all
clear

%% Loop through each phantom
ph_values = {'B0', 'B10E', 'B15E', 'B20E', 'B30E'};

titles = {'SCR', 'SCR-FWHM', 'SMR', 'SMR-FWHM', 'MMR', 'LE', ...
    'Smax', 'Cmax', 'Smax-FWHM', 'Cmax-FWHM', 'Smean', 'Cmean'};

label_list = {'c1,1', 'c1,2', 'c1,3', 'c1,4', 'c2,1', 'c2,2', 'c2,3', 'c2,4'};
met = 3; % Index of the metric to consider
cc = hsv(length(ph_values));

%% Initialize arrays to store Spearman CC (and p-values if needed)
m_range = (10:1:30)*1e-3; % m
rho_vals_all = zeros(length(ph_values), numel(m_range)); % 5 phantoms
p_vals_all = zeros(length(ph_values), numel(m_range)); % 5 phantoms


%% Plot all 5
figure;
for ph_idx = 1:length(ph_values)
    ph = ph_values{ph_idx};
    
    % Initialize arrays to store rankings for each case
    rankings_all = zeros(22, numel(m_range), 2); % 22 tumours, 21 radii, 2 conditions
    
    for c = [3, 7] % conditions c1,3 and c2,3
        % Load rankings
        source = append('results\', ph, '\workspaces\radius_sweep\', ph, '_', label_list{c}, '.mat');
        load(source);
        filename = append('results\', ph, '\workspaces\rankings\', ph, '_', label_list{c}, '_', metric_names{met}, '.mat');
        load(filename);

        % Extract and store rankings
        for i = 1:numel(m_range)
            rankings_all(:, i, c==[3,7]) = all_rankings{i}.Rank;
        end
    end
    
    %% Calculate for all R_S
    for i = 1:numel(m_range)
        [rho_vals_all(ph_idx, i), p_vals_all(ph_idx, i)] = corr(rankings_all(:, i, 1), rankings_all(:, i, 2), 'Type', 'Spearman');
    end
    
    % Plot with HSV colour scheme
    plot(m_range*1e3, rho_vals_all(ph_idx, :), 'o-', 'Color', cc(ph_idx, :), 'LineWidth', 3.0);
    hold on;
end

xlabel('Signal Region Size (mm)');
ylim([-1 1])
yticks(-1:0.2:1);
xticks(10:2:30);
ylabel("Spearman's Correlation Coefficients");
title([titles{met}, ' Rank Correlation']);
legend(ph_values, 'Location', 'southeast', 'NumColumns', 5);
grid on;
grid minor;
set(gca, 'FontSize', 24);

hold off;

