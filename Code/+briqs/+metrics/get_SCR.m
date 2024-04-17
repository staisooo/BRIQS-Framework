function [SCR, SMAX, CMAX] = get_SCR(img_t, img_nt)
    SMAX = max(img_t);
    CMAX = max(img_nt); % mean of clutter reg C = P \ S
    SCR = 20*log10(SMAX ./ CMAX); % scale to decibels
end