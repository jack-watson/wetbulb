function X = run_ECS_analysis(fnA, fcnHdl, opts)

% Abstract function shell to load CMIP projections (built for anomalies, 
% but any gridded .nc file), compute anomalies, apply a statistical function, 
% and save/return results.

% rows of file names in fnA are taken to be multiple files within a single
% analysis, while columns are taken to specify multiple iterations of the
% same analysis. To compute a function that takes in pr, tas, and rtmt for
% 2 sets of files, fnA should take the form:
% fnA = {'pr_1.nc', 'tas_1.nc', 'rtmt_1.nc'; 
%       'pr_2.nc', 'tas_2.nc', 'rtmt_2.nc'};

% If using multiple file inputs per analysis as above, fcnHdl should be a
% wrapper for the desired function that takes in a cell array containing
% each variable. e.g. if pr, tas, and rtmt are 3D arrays, then fcnHdl
% should accept as input fcnHdl({pr, tas, rtmt})

% opts.variable_name
% opts.source_directory
% opts.data_start_index (optional)
% opts.data_count_index (optional)
% opts.save_tf
% opts.save_directory
% opts.save_filename
% opts.save_version
% opts.target_varname

if isffield(opts, 'top_level') && opts.top_level
    opts = opts.ECS_workflow_opts;
end

vnames = opts.variable_name;
sdir   = opts.source_directory;

if ischar(fnA) || (iscell(fnA) && size(fnA,1) == 1)
    
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
    
    if size(fnA,2) > 1 && iscell(fnA) % if more than one var/file per analysis
        nvars = size(fnA,2);
        A = cell(nvars,1);
        for vi = 1:nvars
           fnvi = fnA{vi};
           if iscell(vnames) && length(vnames) == nvars
               vni = vnames{vi};
           else
               if iscell(vnames)
                   vni = vnames{1};
               elseif ischar(vnames)
                   vni = vnames;
               end
           end
           if ~isempty(regexp(fnvi, '.mat', 'match'))
               Ai = load([sdir '\' fnvi], vni);
               if isstruct(Ai)
                   Ai = Ai.(vni);
               end
           elseif ~isempty(regexp(fnvi, '.nc', 'match'))
               Ai = load_CMIP_data(fnvi, vni, sdir, start, count);
           end
           if iscell(Ai)
               A{vi} = Ai{1};
           else
               A{vi} = Ai;
           end
        end
    else
        if iscell(fnA)
            fnA = fnA{1};
        end
        if ~isempty(regexp(fnA, '.mat', 'match'))
            A = load([sdir '\' fnA], vnames);
            if isstruct(A)
                A = A.(vnames);
            end
        elseif ~isempty(regexp(fnA, '.nc', 'match'))
            A = load_CMIP_data(fnA, vnames, sdir, start, count);
        end
        if iscell(A)
            A = A{1};
        end
    end
    
elseif iscell(fnA) && size(fnA,1) > 1 % recursive case
    nfiles = size(fnA,1);
    optsi = opts;
    for fi = 1:nfiles
        optsi.save_filename = opts.save_filename{fi};
        X = run_ECS_analysis(fnA(fi,:), fcnHdl, optsi);
    end
    return
end

X = fcnHdl(A); % run function on anomaly (or cell) array A, return results in X

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
            saveVer = opts.save_version;
            save(savePath, 'X', ['-v' saveVer])
        case '.nc'
            nccreate(savePath, opts.target_varname)
            ncwrite(savePath, opts.target_varname, X)
    end
end

end