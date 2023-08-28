function paramEsts = movingParetoFit(x, windowSize, method, methodParam)

% INPUT
%   x - [n x 1] array of data to estimate pareto dist. parameters for
%   windowSize - [scalar] specifying window size to perform moving estimate
%   method - [string/char] either 'block maxima' or 'peak over threshold';
%              specifies which method to ID extreme values with
%   methodParam - [scalar] takes the form of either the threshold for peak
%               over threshold, or block size for block maxima
% OUTPUT
%   params [n-windowSize x 2] array of shape and scale parameters estimated from data

if isa(x, 'cell')
    x = x{:};
end

if size(x,1) == 1 && size(x,2) == 1 && size(x,3) > 1
    x = reshape(x, [numel(x),1]);
end

if any(x <= 0)
    posMin = min(x(x > 0));
    x(x <= 0) = deal(posMin);
end

paramEsts = zeros(length(x)-windowSize, 2);

for i = 1:length(x)-windowSize
    startIdx = i;
    endIdx   = i + windowSize;
    xwin = x(startIdx:endIdx);
    switch method
        case 'peak over threshold'
            if nargin < 4
                [xextrema, ~] = peakOverThresh(xwin);
            else
                [xextrema, ~] = peakOverThresh(xwin, methodParam);
            end
        case 'block maxima'
            xextrema = blockMaxima(xwin, methodParam);
    end
    parmhat  = gpfit(xextrema);
    paramEsts(i,:) = parmhat;
end

end