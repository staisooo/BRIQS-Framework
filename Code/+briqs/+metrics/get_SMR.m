function [SMR, SMAX, CMEAN] = get_SMR(img_t, img)
    SMAX = max(img_t);
    CMEAN = mean(img); % Mean of whole image
    SMR = 20*log10(SMAX ./ CMEAN);
end