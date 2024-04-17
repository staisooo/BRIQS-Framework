function [MMR, SMEAN, CMEAN] = get_MMR(img_t, img)
    SMEAN = mean(img_t);
    CMEAN = mean(img); % important: Mean of Whole image
    MMR = 20*log10(SMEAN ./ CMEAN);
end