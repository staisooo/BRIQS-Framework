function mat = init_matrix(rl, cl, metric_names)
    mat = cell(numel(metric_names), 1);

    for i = 1:numel(metric_names)
        mat{i} = zeros(rl, cl);
    end
end
