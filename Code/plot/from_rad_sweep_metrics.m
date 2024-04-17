%% Every metric calculated -- plotted here
% normalised to end at the same endpoint in the last m_range value

close all
clear

%% Choose phantom, condition, and metric to load
ph = 'B0';
c = 3; % condition -- refer back to getting_started.m
m = 1; % 'SCR', 'SCR-FWHM', 'SMR', 'SMR-FWHM', 'MMR', 'LE', ...
            % 'Smax', 'Cmax', 'Smax-FWHM', 'Cmax-FWHM', 'Smean', 'Cmean'

%% Load workspace accordingly
label_list = {'c1,1', 'c1,2', 'c1,3', 'c1,4', 'c2,1', 'c2,2', 'c2,3', 'c2,4'};
filename = append('results\', ph, '\workspaces\radius_sweep\', ph, '_', label_list{c}, '.mat');
load(filename);

%% Rainbow Colour scheme
tumours = 22;
for i = 1:tumours
    hue = (i-1)/tumours;
    rgb_color = hsv2rgb([hue*0.92, 1, 1]);
    rbow(i, :) = rgb_color;
end
rbow_factor = 0.85;

%% Plot a figure for each metric
fs = 14;
for k = 1:length(metric_names)
    figure;
    hold on;

    m = metric_vals{k};

    % Min and Max for each line plot
    min_vals = min(m, [], 2);
    max_vals = max(m, [], 2);

    % Max value at the 25 mm margin size
    max_25mm = max(m(:, end));

    for i = 1:size(m, 1)
        offset = max_25mm - max_vals(i); % subtract from max @ 25mm

        plot(m_range*1e3, m(i, :) + offset, 'LineWidth', 1, ...
            'color', rbow(i, :)*rbow_factor);

        % Instead of a legend
        text(m_range(1)*1e3, m(i, 1) + offset, ...
            sprintf('Tumour #%d', i), 'HorizontalAlignment', ...
            'right', 'VerticalAlignment', 'middle', 'FontSize', 7, ...
            'color', rbow(i, :));

    end

    xlabel('Signal Region Size (mm)');
    ylabel([metric_names{k}, ' Values']);
    title(['Radius Sweep for ', ph, ' phantoms (', label_list{c}, ': ', metric_names{k}, ')']);
    xticks(m_range*1000);
    xticklabels(10:1:30);
    set(gca, 'FontSize', fs);
    xlim([7 31]);
    grid on;
    hold off;

end


