function Y = smean3(X, windowSz, ylab, timestep, xfmt)

if nargin > 1 && ~isempty(windowSz)% if window size is input then assume it's a moving average
    Y = movmean(reshape(mean(X, [1 2]), [], 1), windowSz);
    movtf = true;
elseif (size(X,1) > 1 || size(X,2) > 1) && (size(X,1) == 1 || size(X,2) == 1)
    if nargin > 1 && ~isempty(windowSz)
        Y = movmean(X, windowSz);
        movtf = true;
    else
        Y = X;
        movtf = false;
    end
else
    Y = reshape(mean(X, [1 2]), [], 1);
    movtf = false;
end



figure('Name', ['Spatial average over time' num2str(normrnd(0,1))])
hold on; grid on
if nargin > 3 && ~isempty(timestep)
    t = 1:length(Y);
    switch timestep
        case 'day'
            dt = days(t);
        case 'month'
            dt = months(t);
        case 'year'
            dt = years(t);
    end
    plot(dt,Y, 'LineWidth',2)
    if nargin > 4 && ~isempty(xfmt)
       xtickformat(xfmt)
       ax = gca;
       ax.XAxis.Exponent = 0;
    end
else
    plot(Y, 'LineWidth', 2)
end
xlabel('Time')
if nargin > 2 && ~isempty(ylab)
   ylabel(ylab) 
end


switch movtf
    case true
        legend({['Smoothed moving avg. of spatial mean, k = ' num2str(windowSz)]})
    case false
        legend({'Spatial mean'})
end

end