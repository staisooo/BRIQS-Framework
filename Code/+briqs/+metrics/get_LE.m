function LE_mm = get_LE(points, img_t, tum_location)
    [~, smx] = max(img_t);
    smax_loc = points(smx, :);
    LE = norm(tum_location - smax_loc); % euclidean distance
    LE_mm = 1e3 * LE; % norm
end