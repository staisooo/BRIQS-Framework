%% Doing this by signal radius size -- all ph in same pool

clear

%% Initialise
c = 3; % CONDITION
m = 5; %  {1 'SCR', 2 'SCR-FWHM', 3 'SMR', 4 'SMR-FWHM', 5 'MMR', 6 'LE', ...
    % 7 'Smax', 8 'Cmax', 9 'Smax-FWHM', 10 'Cmax-FWHM', 11 'Smean', 12 'Cmean'};
rad_idx = 6; % 1 = 10mm, 11 = 20mm, and 21 = 30mm

ph_values = {'B0', 'B10E', 'B15E', 'B20E', 'B30E'};
label_list = {'c1,1', 'c1,2', 'c1,3', 'c1,4', 'c2,1', 'c2,2', 'c2,3', 'c2,4'};

rad_vals_all_ph = [];
for i = 1:length(ph_values)
    ph = ph_values{i};
    load(append('results\', ph, '\workspaces\radius_sweep\', ph, '_', label_list{c}, '.mat'));

    metric_vals_cell = metric_vals{m,:};
    rad_vals = metric_vals_cell(:, rad_idx);
    rad_vals_all_ph = [rad_vals_all_ph; rad_vals];
end

%% Now we have 110x1 array, calc stats for that radius size:
min_val = min(rad_vals_all_ph);
max_val = max(rad_vals_all_ph);
mean_val = mean(rad_vals_all_ph);

%% Easy access
disp([metric_names{m}, ' Statistics for ', label_list{c} ' (Signal Region size of ', ...
    num2str(rad_idx+9), ' mm)']);
disp(['Min: ', num2str(round(min_val, 1)), ' dB.']);
disp(['Max: ', num2str(round(max_val, 1)), ' dB.']);
disp(['Mean: ', num2str(round(mean_val, 1)), ' dB.']);
