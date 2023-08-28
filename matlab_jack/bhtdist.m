function [dist, coeff] = bhtdist(x1,x2,nbins)
% s = bhtdist(x1,x2)
%       returns a histogram similarity in the range 0..1
%
% Compares 2 normalised histograms using the Bhattacharyya coefficient.
% Assumes that sum(x1) == sum(x2) == 1

% Check proper formatting and dimensionality of input

d1 = size(x1);
d2 = size(x2);

if length(d1) > 2
    if d1(3) > 1
        y1 = reshape(x1, [d1(3),1]);
        y2 = reshape(x2, [d2(3),1]);
    elseif d1(3) == 1
        if d1(1) > 1 && d1(2) == 1
            y1 = reshape(x1, [d1(1),1]);
            y2 = reshape(x2, [d2(1),1]);
        elseif d1(2) > 1 && d1(1) == 1
            y1 = reshape(x1, [d1(2),1]);
            y2 = reshape(x2, [d2(2),1]);
        end
    end
else
    y1 = x1;
    y2 = x2;
end
    
if numel(y1) ~= numel(y2)
    if numel(y1) > numel(y2)
        y1 = y1(1:numel(y2));
    elseif numel(y2) > numel(y1)
        y2 = y2(1:numel(y1));
    end
end

% normalize inputs unless told otherwise with normtf = 0
% if nargin < 4 || normtf == 1
%    y1 = (y1 - mean(y1))./std(y1);
%    y2 = (y2 - mean(y2))./std(y2);
% end

% bin data into histograms
[h1,h1edges] = histcounts(y1,nbins);
[h2,h2edges] = histcounts(y2,h1edges);

% Compute Bhattacharyya coefficient and Bhattacharyaa distance
coeff = sum(sqrt(h1.*h2));
dist = sqrt(1 - coeff);
%dist  = -log(coeff);

end