function Y = lat_percentiles(X, percentiles, opts)

if ischar(X)
   start = opts.start;
   count = opts.count;
   switch opts.fmtin
       case '.nc'
           Xx = load_CMIP_data(X, opts.varname, opts.fdir, start, count);
           Xx = Xx{1};
       case '.mat'
           m = matfile(X);
           Xx = m.(opts.varname)(start(1):end, start(2):end, start(3):end);
   end
else
    Xx = X;
end

Y = prctile(Xx, percentiles, [2 3], 'Method', 'approximate');

if opts.plot
    if isempty(opts.lat)
        switch opts.fmtin
            case '.nc'
                try
                    latctrs = mean(ncread([opts.fdir '\' X], 'lat_bnds'), 1);
                catch
                    latctrs =  ncread([opts.fdir '\' X], 'lat');
                end
                xlat =  flip(latctrs');
            case '.mat'
                xlat = flip(-89.557443230354890:(179.1149/256):89.557443230354890)';
        end
    else
        xlat = opts.lat;
    end
    figure('Name', opts.figname); hold on; grid on
    plot(xlat, Y.*86400, 'LineWidth', 2)
    ylabel('Extreme precipitation (mm/day)')
    xlabel('Latitude')
    legend({'75th percentile', '90th percentile', '99th percentile', '99.9th percentile'})
    title(opts.title)
end

end