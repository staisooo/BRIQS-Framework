% Returns logical tumour array, tumour and non-tumour images,
    % value of c, name of condition in thesis, partition condition
        % 1 = c1,1 = known centre, known tumour size
        % 2 = c1,2 = known centre, known tumour size + added margins
        % 3 = c1,3 = known centre, global radius value used for tumour sizes
        % 4 = c1,4 = known centre, tumour size using FWHM
        % 5 = c2,1 = centre @ brightest spot, known tumour size
        % 6 = c2,2 = centre @ brightest spot, known tumour size + added margins
        % 7 = c2,3 = centre @ brightest spot, global radius value used for tumour sizes
        % 8 = c2,4 = centre @ brightest spot, tumour size using FWHM
        
function [tumour, img_t, img_nt, t] = regions(img, points, tum_size, tum_location, m, c)

    switch c 
        case 1 % c1,1 = known centre, known tumour size
            tumour = sum(((points-tum_location)./(tum_size)).^2, 2) <= 1;
            t = 'c1,1';

        case 2 % c1,2 = known centre, known tumour size + added margins
            tumour = sum(((points-tum_location)./(tum_size + m)).^2, 2) <= 1;
            t = 'c1,2';

        case 3 % c1,3 = known centre, global radius value used for tumour sizes
            tumour = sum(((points-tum_location)./(m)).^2, 2) <= 1;
            t = 'c1,3';

        case 4 % c1,4 = known centre, tumour size using FWHM
            [f(1), f(2), f(3)] = merit.metrics.FWHM(img, points);
            tumour = sum(((points-tum_location)./f).^2, 2) <= 1;
            t = 'c1,4';

        case 5 % c2,1 = centre @ brightest spot, known tumour size
            [~, mx] = max(img);
            max_loc = points(mx, :);
            tumour = sum(((points-max_loc)./tum_size).^2, 2) <= 1;  
            t = 'c2,1';

        case 6 % c2,2 = centre @ brightest spot, known tumour size + added margins
            [~, mx] = max(img);
            max_loc = points(mx, :);
            tumour = sum(((points-max_loc)./tum_size + m).^2, 2) <= 1;  
            t = 'c2,2';

        case 7 % c2,3 = centre @ brightest spot, global radius value used for tumour sizes
            [~, mx] = max(img);
            max_loc = points(mx, :);
            tumour = sum(((points-max_loc)./m).^2, 2) <= 1;  
            t = 'c2,3';

        case 8 % c2,4 = centre @ brightest spot, tumour size using FWHM
            [~, mx] = max(img);
            max_loc = points(mx, :);
            [f(1), f(2), f(3)] = merit.metrics.FWHM(img, points);
            tumour = sum(((points-max_loc)./f).^2, 2) <= 1;
            t = 'c2,4';
    end

    %% Initialize new images
    img_t = img; % 'tumour' image == signal reg
    img_nt = img; % 'non tumour' image == clutter reg

    %% Modify images based on tumour region
    img_t(~tumour) = 0;
    img_nt(tumour) = 0;

end
