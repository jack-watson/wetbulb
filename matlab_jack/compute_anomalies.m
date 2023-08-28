function A = compute_anomalies(piFn, forcedFn, opts)

% compute_anomalies() subtracts file specified by piFn from file specified
% by forcedFn, returning the anomalies in forcedFn relative to piFn. Built
% specifically for gridded (3d array) CMIP datasets loaded from workspace
% or netcdf files.

% opts.top_level
% opts.anomaly_opts
% opts.return_output
% opts.source
% opts.piControl_source_directory
% opts.forced_source_directory
% opts.data_start_index
% opts.data_count_index
% opts.variable_name
% opts.avg_tf
% opts.piControl_averaging_function
% opts.save_tf
% opts.save_directory;
% opts.save_filename;
% opts.save_version;

if isffield(opts, 'top_level') && opts.top_level
    opts = opts.anomaly_opts;
end

% Recursive if piFn and forcedFn are a cell array of char file names
% indicating multiple sets of anomalies to compute
if iscell(piFn) && iscell(forcedFn) ...
        && all(cellfun(@ischar, piFn)) && all(cellfun(@ischar, forcedFn))
    if ~all(size(piFn) == size(forcedFn))
        error('Dimension mismatch: when input is specified as cell arrays of char file names, dimensions must match')
    end
    nfiles = length(piFn);
    if opts.return_output
        A = cell(nfiles,1); 
    end
    optsi = opts;
    for fi = 1:nfiles % recur
        optsi.save_filename = opts.save_filename{fi};
        piFni = piFn{fi};
        fcFni = forcedFn{fi};
        Ai = compute_anomalies(piFni, fcFni, optsi);
        if opts.return_output
           A{fi} = Ai; 
        end
    end
    return
end

% Configure input
switch opts.source
    case 'workspace'
        pX = piFn; % preindustrial control run
        fX = forcedFn; % (presumptively) forced run, e.g. abrupt_4xCO2
    case '.nc'
        if isffield(opts, 'piControl_source_directory')
            piSourceDir = opts.piControl_source_directory;
        else
            piSourceDir = cd;
        end
        if isffield(opts, 'forced_source_directory')
            fcSourceDir = opts.forced_source_directory;
        else
            fcSourceDir = cd;
        end
        
        if isffield(opts, 'data_start_index')
            start = opts.data_start_index;
            if ~isffield(opts, 'data_count_index')
                count = [Inf Inf Inf];
            else
                count = opts.data_count_index;
            end
        else
            start = [1 1 1];
            count = [Inf Inf Inf];
        end
        
        varName = opts.variable_name;
        pX = load_CMIP_data(piFn, varName, piSourceDir, start, count);
        fX = load_CMIP_data(forcedFn, varName, fcSourceDir, start, count);
end

if iscell(pX) % remove cell wrapper output from load_CMIP_data
    pX = pX{1};
end
if iscell(fX)
    fX = fX{1};
end


% Maybe compute averages of piControl, then compute anomalies
if ~all(size(pX, 1:2) == size(fX, 1:2)) % enforce shape
    error('Shape mismatch: dimensions [1, 2] of data must be the same to compute anomalies')
end    

if size(pX,3) == 1
    A = fX - pX;
elseif size(pX,3) > 1
    if isffield(opts, 'avg_tf') && opts.avg_tf % average piControl run before computing anomalies?
        avgFun = opts.piControl_averaging_function; % e.g. opts.piControl_averaging_function = @(x) mean(x,3);
        pXmu   = avgFun(pX);
        A = fX - pXmu;
    else
        if size(pX,3) == size(fX,3)
            A = fX - pX;
        else
            error('Shape mismatch: with no averaging, dimension [3] of data must be same to compute anomalies')
        end
    end
end

% Save results to file, or not
if isffield(opts, 'save_tf') && opts.save_tf
    saveDir = opts.save_directory;
    saveFn  = opts.save_filename;
    if isffield(opts, 'disco') && opts.disco
        savePath = [saveDir '/' saveFn];
    else
        savePath = [saveDir '\' saveFn];
    end
    switch opts.save_format
        case '.mat'
            if isffield(opts, 'save_version')
                saveVer = opts.save_version;
                save(savePath, 'A', ['-v' saveVer])
            else
                save(savePath, 'A')
            end
        case '.nc'
            nccreate(savePath, opts.target_varname)
            ncwrite(savePath, opts.target_varname, A)
    end
   
end

end
    