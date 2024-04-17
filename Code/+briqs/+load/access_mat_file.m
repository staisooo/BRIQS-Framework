function mat_file = access_mat_file(ph, pl)
   filename = sprintf('%s_P%d_*.mat', ph, pl);
   
   % path to scans
   folder_path = 'dataset\data\rotation';

   % construct filename and search for the file in folder_path
   files = dir(fullfile(folder_path, filename));

   if ~isempty(files)
       % assuming only 1 matching file...
       full_filename = fullfile(folder_path, files(1).name);
       mat_file = full_filename; % Return the path
   else
       error('No matching file found.');
   end
end
