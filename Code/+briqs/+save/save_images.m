function save_images(ph, pl) 
    %% file paths
    results_folder = 'results\';

    img_folder = append(results_folder , sprintf('%s', ph), '\images');

    %% filenames
    img_filename = sprintf('Image_Slice_%s_P%d.png', ph, pl);

    image_path = fullfile(img_folder, img_filename);
    saveas(gcf, image_path);

end
