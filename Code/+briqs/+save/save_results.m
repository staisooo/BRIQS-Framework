function save_results(ph, pl, metrics, metric_names) 
    %% file paths
    results_folder = 'results\';

    img_folder = append(results_folder , ph, '\images');
    num_folder = append(results_folder, ph, '\numeric');    

    %% filenames
    img_filename = sprintf('Image_Slice_%s_P%d.png', ph, pl);
    metrics_filename = sprintf('Metrics_%s_P%d.csv', ph, pl);

    image_path = fullfile(img_folder, img_filename);
    saveas(gcf, image_path);

    fid = fopen(fullfile(num_folder, metrics_filename), 'w');
    fprintf(fid, '%s,', metric_names{:});
    fprintf(fid, '\n');
    fclose(fid);

    dlmwrite(fullfile(num_folder, metrics_filename), metrics, ...
        '-append', 'precision', 4);
end
