function path_to_scans = access_mat_files(ph) 
    % access multiple mat files from the same phantom group

    % path to scans
    folder_path = 'dataset\data\rotation';

    % array to store path files
    path_to_scans = cell(1, 22);

    for i = 1:length(path_to_scans)
        filename = sprintf('%s_P%d_*.mat', ph, i);

        % construct filename and search for the file in folder_path
        files = dir(fullfile(folder_path, filename));

        % search for matching files in the folder
        if ~isempty(files)
            % assuming only 1 matching file...
            full_filename = fullfile(folder_path, files(1).name);
            path_to_scans{i} = full_filename;
        else
            path_to_scans{i} = '';
        end
    end
end
