function save_results_multiple(ph, metric_vals, metric_names)
    results_folder = 'results\';
    metrics_folder = fullfile(results_folder, ph, 'numeric');

    filename = sprintf('Metrics_%s.csv', ph);

    fid = fopen(fullfile(metrics_folder, filename), 'w');

    fprintf(fid, '%s', metric_names{1}); % metric names in 1st row
    for i = 2:numel(metric_names)
        fprintf(fid, ',%s', metric_names{i});
    end
    fprintf(fid, '\n');

    % Write values for each corresponding metric
    for row = 1:22
        for col = 1:numel(metric_vals)
            fprintf(fid, '%f', metric_vals{col}(row));
            if col < numel(metric_vals)
                fprintf(fid, ',');
            end
        end
        fprintf(fid, '\n');
    end

    % Close csv
    fclose(fid);
end

