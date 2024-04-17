% The one mainly used for saving labelled excel sheets eg. in radius sweep
function save_sheets(ph, metric_vals, t, metric_names)
    save_location = append('results\', ph, '\numeric\');
    filename = append(ph, '_', t, '.xlsx');

    % save each metric as a separate sheet
    for k = 1:length(metric_vals)
        metric_data = num2cell(metric_vals{k});
        xlswrite(fullfile(save_location, filename), metric_data, metric_names{k});
    end
end
