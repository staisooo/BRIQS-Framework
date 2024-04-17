%% run from_rad_sweep_quantities.m first 

% Shows where the crossover points are for chosen tum_to_plot

close all

%% Initialise table to store crossover info
co_table = table('Size', [0, 2], 'VariableTypes', {'double', 'cell'}, ...
            'VariableNames', {'TumourType', 'CrossoverRadius'});
co_thresh = 0.005; % crossover allowance

%% Loop through each tumour
for idx = 1:length(tum_to_plot)
    i = tum_to_plot(idx);

    %% Storing values and COs
    Smax_vals = metric_vals{7}(i, :);
    Cmax_vals = metric_vals{8}(i, :);
    co_rad = [];

    for m1 = 1:length(m_range)-1
        for m2 = m1+1:length(m_range)
            % if Smax and Cmax within the threshold
            if abs(Smax_vals(m1) - Cmax_vals(m1)) < co_thresh && abs(Smax_vals(m2) - Cmax_vals(m2)) < co_thresh
                co_rad = unique([co_rad, m_range(m1)*1e3, m_range(m2)*1e3]);
            end
        end
    end

    %% Add new table entries for any tumour types with COs
    if ~isempty(co_rad)
        co_rad = co_rad(1:min(length(tum_to_plot), end));
        new_entry = table(i, {co_rad}, 'VariableNames', {'TumourType', 'CrossoverRadius'});
        co_table = [co_table; new_entry];
    end

end

% Display the crossover table
disp(['Crossover Table for ', ph, ' phantoms (', label_list{c}, ')']);
disp(co_table);
