%% Plot for clutter region
    % AKA non-data-driven analysis
% note, tilde isnt available nor is bar for plots so a prime (') is used to
% indicate the mean values here

close all
clear

%% Figure/plot settings
cc = hsv(16);
fontSize = 20;

%% Setting parameters for ideal normalised image + worst case for p'-c'
s_tilde = 1;
c_tilde = 0;

m_range = (10:1:30) * 1e-3; % mm -- 10 to 30mm
res_range = (0.5:0.5:5) * 1e-3; % mm -- 0.5 mm to 5 mm w/ 0.5 mm step
r_hs = 0.07; % res of hemisphere -- 7 cm

%% Plot
figure;
for i = 1:length(res_range)
    res = res_range(i);

    for j = 1:length(m_range)
        %% Excess 'wafer' points
        vol_p = (2/3*pi*(r_hs)^3);
        vol_t = (4/3*pi*(m_range(j))^3);
        n_chips = vol_p / vol_t;
        hash_p_expected = pi * r_hs^2 / res^2;
        hash_p_excess = n_chips * res^2;
        hash_p_excess_wafer = hash_p_expected + hash_p_excess;

        %% #p, #t, #c and p'-c' 
        hash_p = (vol_p / res^3) + hash_p_excess_wafer/2;
        hash_t = vol_t / res^3;
        hash_c = hash_p - hash_t;
        p_minus_c = ((hash_t/hash_p) * s_tilde) + ((hash_c/hash_p) * c_tilde);

        %% Store values
        mat{i, j} = p_minus_c;
        hash_p_vals{i, j} = hash_p;
        hash_t_vals{i, j} = hash_t;
        hash_c_vals{i, j} = hash_c;
    end

    %% Plot values with different colors
    plot(m_range*1e3, cell2mat(mat(i, :)), 'Color', cc(i, :), 'LineWidth', 3);
    hold on;
end

xlabel('Signal Region Size (mm)');
ylabel("Difference between means of \it{P} and \it{C}");
xticks(10:2:30);
title("Plot for Clutter Region Definition");
set(gca, 'FontSize', fontSize);
legend(arrayfun(@(x) sprintf('r = %0.1fmm', x*1e3), ...
    res_range, 'UniformOutput', false), 'Location', 'northwest', ...
    'NumColumns', 3);


%% Superimpose actual dataset results for all 5 phantoms (res = 2.5 mm)
ph_values = {'B0', 'B10E', 'B15E', 'B20E', 'B30E'};
label_list = {'c1,1', 'c1,2', 'c1,3', 'c1,4', 'c2,1', 'c2,2', 'c2,3', 'c2,4'};

% Initialize a cell array to store the p_minus_c values for each ph
all_p_minus_c = cell(length(ph_values), 1);

for ph_idx = 1:length(ph_values)
    ph = ph_values{ph_idx};
    c = 7; 
    filename = append('results\', ph, '\workspaces\mean\', ph, '_', label_list{c}, '.mat');
    load(filename);

    %% Calculate p_minus_c for the current ph
    hash_p_vals = values{4};
    hash_t_vals = values{5};
    p_minus_c = hash_t_vals ./ hash_p_vals;

    %% Store the p_minus_c values in the cell array
    all_p_minus_c{ph_idx} = p_minus_c;

    %% Plot averaged values with a different color scheme
    plot(m_range*1e3, mean(all_p_minus_c{ph_idx}, 1), 'Color', cc(ph_idx+9, :), 'LineWidth', 3);
    hold on;
end

grid minor;
hold off;
