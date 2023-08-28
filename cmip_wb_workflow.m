%Workflow script for cmip5/6 wetbulb data generation
%Sophia Bailey and Jack Watson
%July 15, 2023

%establish data paths for three different variables needed to calculate
%wetbulb
data_path_huss = "C:\Users\sbail\OneDrive\Documents\ClimateResearch2023\Test_data\data\huss\";
data_path_tasmax = "C:\Users\sbail\OneDrive\Documents\ClimateResearch2023\Test_data\data\tasmax\";
data_path_orog = "C:\Users\sbail\OneDrive\Documents\ClimateResearch2023\Test_data\data\orog\";

data_paths_unprocessed = [data_path_huss, data_path_tasmax, data_path_orog];

%create data paths to put temporally merged files
data_path_merged_huss = "C:\Users\sbail\OneDrive\Documents\ClimateResearch2023\merged\huss\"
data_path_merged_tasmax = "C:\Users\sbail\OneDrive\Documents\ClimateResearch2023\merged\tasmax\"
data_path_merged_orog = "C:\Users\sbail\OneDrive\Documents\ClimateResearch2023\merged\orog\"

%map procedure below to all three variable data paths
for s = 1:length(data_paths_unprocessed)
    %creates list of files in current data path
    file_names = ls(append(data_paths_unprocessed(s),"*.nc"));
    file_names = string(file_names);
    %checks which files are unsuccessfully downloaded
    bad_files = DataSummary(data_paths_unprocessed(s),file_names);
    bad_files = string(bad_files);
    %creates list of models based on data files
    models = strings;
    for i = 1:2
        models(i) = string(ncreadatt(append(data_paths_unprocessed(s),file_names(i)),"/","parent_source_id"))
    end
    %removes duplicates from list of models
    unique_models = unique(models)

    %needs to remove models that have any badly downloaded files
    for i = 1:length(bad_files)
        is_model_bad = ismember(string(ncreadatt(append(data_paths_unprocessed(s),bad_files(i)),"/","parent_source_id")),unique_models);
        if is_model_bad == 1
            unique_models(unique_models == string(ncreadatt(append(data_paths_unprocessed(s),bad_files(i)),"/","parent_source_id"))) = [];
        end

    end

    %sorts files and adds all files corresponding to one model into a list
    for i = 1:length(unique_models)
        model_files = strings;
        current_model = unique_models(i);
        k = 1;
        for j = 1:length(file_names)
            if string(ncreadatt(append(data_paths_unprocessed(s),file_names(j)),"/","parent_source_id")) == current_model
                model_files(k) = file_names(j);
                %can this be done better? maybe model_files(end+1)
                k = k+1;
            end
        end
        TemporalMerge(data_paths_unprocessed(s), model_files)
    end
end

merged_huss_file_names = string(ls(append(data_path_merged_huss,"*.nc")));
merged_tasmax_file_names = string(ls(append(data_path_merged_tasmax,"*.nc")));
merged_orog_file_names = string(ls(append(data_path_merged_orog,"*.nc")));
%function to go through every model type and take all 3 variables to
for i = 1:length(unique_models)
    current_model = unique_models(i)
    for j = 1:length(merged_huss_file_names)
        if string(ncreadatt(append(data_path_merged_huss,merged_huss_file_names(j)),"/","parent_source_id")) == current_model
            huss_file = merged_huss_file_names(j)
        end
    end
    for k = 1:length(merged_orog_file_names)
        if string(ncreadatt(append(data_path_merged_orog,merged_orog_file_names(k)),"/","parent_source_id")) == current_model
            orog_file = merged_orog_file_names(k)
        end
    end
    for l = 1:length(merged_tasmax_file_names)
        if string(ncreadatt(append(data_path_merged_tasmax,merged_tasmax_file_names(l)),"/","parent_source_id")) == current_model
            tasmax_file = merged_tasmax_file_names(l)
        end
    end

    huss_data = ncread(append(data_path_merged_huss, huss_file));
    orog_data = ncread(append(data_path_merged_orog, orog_file));
    tasmax_data = ncread(append(data_path_merged_tasmax, tasmax_file));

    %should write conditional to give error if tasmax and huss aren't same
    %size
    %this only loops through lat and lon, need to also loop through time
    %double check order of lat and lon here
    for lat_dim = 1:size(huss_data,1)
        for lon_dim = 1:size(huss_data,2)
            for time_dim = 1:size(huss_data,3)
                %fix sophie
                pressure_data(lat_dim,lon_dim,time_dim) = SurfacePressureElev(tasmax_data(lat_dim,lon_dim,time_dim),orog_data(lat_dim,lon_dim,time_dim));
                %check units
                wetbulb_data(lat_dim,lon_dim,time_dim) = WetBulb(tasmax_data(lat_dim,lon_dim,time_dim),pressure_data(lat_dim,lon_dim,time_dim),huss_data(lat_dim,lon_dim,time_dim));
            end
        end
    end
    %write wetbulb data to .nc file now using same schema as either huss or
    %tasmax and then rewrite
    file_info = ncinfo(append(data_path_merged_huss,huss_file));
    wetbulb_data_path = "C:\Users\sbail\OneDrive\Documents\ClimateResearch2023\Test_data\data\wetbulb\";
    wetbulb_file = append(wetbulb_data_path,current_model,"_wetbulb.nc");
    ncwriteschema(wetbulb_file,file_info);
    nccreate(wetbulb_file,"wetbulb","Dimensions",{"lon","lat","time"}); %finish filling in dimensions with sizes from lon, lat, time
    
    %call bilinear interpolation function on new .nc file with wetbulb data
    BilinInterp(wetbulb_file,wetbulb_data_path,"wetbulb");
end

%figures?

%thresholds?
%at some point generate file that gives the average wetbulb based on the
%ensemble

