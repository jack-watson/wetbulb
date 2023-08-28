function [y, ylocs] = peakOverThresh(x, thresh)

if size(x,1) == 1 && size(x,2) == 1 && size(x,3) > 1
    x = reshape(x, [numel(x),1]);
end

[pks,locs] = findpeaks(x);

if nargin > 1
    y = pks(pks > thresh);
    ylocs = locs(pks > thresh);
else
    y = pks;
    ylocs = locs;
end

end