function opts = pctConfig(template, start, count, varname, fdir, plottf, figname, title)

if isempty(template)
    opts = struct;
else
    opts = template;
end

opts.start = start;
opts.count = count;
opts.fdir = fdir;
opts.varname = varname;

opts.plot = plottf;
opts.figname = figname;
opts.title = title;


end