%% run rad_sweep_metrics.m first 
% This is for plotting Smax, Cmax, and optionally, the other standalone quantities

close all;

%% choose tumour types to plot -- or all
% tum_to_plot = (1:22);
tum_to_plot = [13, 3];

qty_vals_to_plot = {metric_vals{7}, metric_vals{8}}; % just Smax and Cmax
% 'SCR', 'SCR-FWHM', 'SMR', 'SMR-FWHM', 'MMR', 'LE', ...
            % 'Smax', 'Cmax', 'Smax-FWHM', 'Cmax-FWHM', 'Smean', 'Cmean'
qty_names_to_plot = {metric_names{7}, metric_names{8}};

%% Plot a figure for each tumour
fontSize = 14;
for idx = 1:length(tum_to_plot)
    i = tum_to_plot(idx);

    figure;
    hold on;

    for k = 1:length(qty_vals_to_plot)
        scatter(m_range*1e3, qty_vals_to_plot{k}(i, :), 'filled');
    end

    xlabel('Signal Radius Size (mm)');
    ylabel(['Values']);
    title(['Plot of ', qty_names_to_plot{1} ' and ', qty_names_to_plot{2}, ...
        ' for ', ph,' P', num2str(i), ' (', label_list{c}, ')']);
    xticks(m_range*1000);
    xticklabels(10:1:30);
    xlim([9 31]);
    set(gca, 'FontSize', fontSize);
    grid on;
    legend(qty_names_to_plot, 'Location', 'best');
    hold off;

end 
