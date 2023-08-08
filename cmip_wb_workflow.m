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

%function to go through every model type and take all 3 variables to
%calculate wet bulb by mapping onto all models in unique models function
    %within this the wetbulb calculation function will be called as well as
    %a function to calculate surface pressure based on elevation

    %will need to do it so the wetbulb function is called for every data
    %point and then written to an .nc file, similarly for the surface
    %pressure based on elevation

%Only after wetbulb is calculated, a regridding function is called to
%perform bilinear interpolation on the results onto a common grid

