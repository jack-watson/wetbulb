%Workflow script for cmip5/6 wetbulb data generation
%Sophia Bailey and Jack Watson
%July 15, 2023

%can use arrayfun(func, array_name) to apply procedure to entire array

%for loop iterates through all of the unique model/variable combinations
%If directories are unsorted, will need some sort of sorting function
    %look at how Stone wrote the R script to sort them into directories?
%If/when directories are sorted, call temporal merge
data_path_huss = "C:\Users\sbail\OneDrive\Documents\ClimateResearch2023\Test_data\data\huss\"
data_path_tasmax = "C:\Users\sbail\OneDrive\Documents\ClimateResearch2023\Test_data\data\tasmax\"
data_path_orog = "C:\Users\sbail\OneDrive\Documents\ClimateResearch2023\Test_data\data\orog\"

data_path_merged_huss = "C:\Users\sbail\OneDrive\Documents\ClimateResearch2023\merged\huss\"
data_path_merged_tasmax = "C:\Users\sbail\OneDrive\Documents\ClimateResearch2023\merged\tasmax\"
data_path_merged_orog = "C:\Users\sbail\OneDrive\Documents\ClimateResearch2023\merged\orog\"

%map procedure below to all three variable data paths
file_names = ls(append(data_path,"*.nc"))
file_names = string(file_names)
models = strings
for i = 1:2
    models(i) = string(ncreadatt(append(data_path,file_names(i)),"/","parent_source_id"))
end
unique_models = unique(models)

for i = 1:length(unique_models)
    model_files = strings
    current_model = unique_models(i)
    k = 1
    for j = 1:2
        if string(ncreadatt(append(data_path,file_names(j)),"/","parent_source_id")) == current_model
            model_files(k) = file_names(j)
            k = k+1
        end
    end
    TemporalMerge(data_path, model_files)
end

merged_huss_file_names = ls(append(data_path_merged_huss,"*.nc"))
merged_huss_file_names = string(merged_huss_file_names)
merged_tasmax_file_names = ls(append(data_path_merged_tasmax,"*.nc"))
merged_tasmax_file_names = string(merged_tasmax_file_names)
merged_orog_file_names = ls(append(data_path_merged_orog,"*.nc"))
merged_orog_file_names = string(merged_orog_file_names)
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
    for row = 1:height(huss_data)
        for column = 1:width(huss_data)
            pressure_data(row,column) = SurfacePressureElev(tasmax_data(row,column),orog_data(row,column))
            %check units
            wetbulb_data(row,column) = WetBulb(tasmax_data(row,column),pressure_data(row,column),huss_data(row,column))
        end
    end
    %write wetbulb data to .nc file now using same schema as either huss or
    %tasmax and then rewrite
    file_info = ncinfo(append(data_path_merged_huss,huss_file));
    wetbulb_data_path = "C:\Users\sbail\OneDrive\Documents\ClimateResearch2023\Test_data\data\wetbulb\";
    wetbulb_file = append(wetbulb_data_path,current_model,"_wetbulb.nc");
    ncwriteschema(wetbulb_file,file_info);
    nccreate(wetbulb_file,"wetbulb","Dimensions",{"lon","lat","time"}); %finish filling in dimensions with sizes from lon, lat, time

    BilinInterp(wetbulb_file,wetbulb_data_path,"wetbulb");
    %call bilinear interpolation function on new .nc file with wetbulb data
end


%at some point generate file that gives the average wetbulb based on the
%ensemble

