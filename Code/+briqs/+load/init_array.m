function array = init_array(rl, metric_names)
    array = cell(numel(metric_names), 1); % column length = 1

    for i = 1:numel(metric_names)
        array{i} = zeros(rl, 1);
    end
end
