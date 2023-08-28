function dist = eudist(x1,x2,nbins,plottf)

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

% bin data into histograms
[h1,h1edges] = histcounts(y1,nbins);
[h2,~]       = histcounts(y2,h1edges);

% Compute euclidean distance
dist = sqrt(sum((h1-h2).^2));

if nargin > 3 && plottf == 1
    figure
    hold on; grid on
    histogram(y1,80)
    histogram(y2,h1edges)
    title(['nbins = ' num2str(nbins)])
end