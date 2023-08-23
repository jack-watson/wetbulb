%function for merging netcdf files of the same model, experiment, and
%variant such that all data is in one .nc file

function [] = TemporalMerge(data_path, model_files)
%replace below with temporal merge function once debugged

    %gets attributes of current model/var/exp being studied
    model = string(ncreadatt(append(data_path,model_files(1)),"/","parent_source_id"))
    experiment = string(ncreadatt(append(data_path,model_files(1)),"/", "experiment_id"))
    variant = string(ncreadatt(append(data_path,model_files(1)),"/","parent_variant_label"))
    variable = string(ncreadatt(append(data_path,model_files(1)), "/","variable_id"))

    %creates file name for temporally merged file
    combined_file = append(model,"_",experiment,"_",variant,"_",variable,".nc")
    

    %check that all files have the same model, experiment, and variant
    for i = 1:length(model_files)
        current_model = string(ncreadatt(append(data_path,model_files(i)),"/","parent_source_id"))
        current_experiment = string(ncreadatt(append(data_path,model_files(i)),"/","experiment_id"))
        current_variant = string(ncreadatt(append(data_path,model_files(i)),"/","parent_variant_label"))
        current_variable = string(ncreadatt(append(data_path,model_files(i)),"/","variable_id"))
        if current_model ~= model | current_experiment ~= experiment | current_variant ~= variant | current_variable ~= variable
            %will this break the while loop by changing the length of file
            %names?
            model_files(i)=[]
        end
    end

    %probably need to define variable dimensions
    %since time is an 'unlimited' dimension, maybe we only need to write
    %schema once?
    %takes info from one of the files to create schema
    info = ncinfo(append(data_path,model_files(1)));

    %next 3 lines just for troubleshooting
    info2 = ncinfo(append(data_path,model_files(2)));
    file1_data = ncread(append(data_path,model_files(1)), variable);
    file2_data = ncread(append(data_path,model_files(2)), variable);

    %sets up new temporally merged file infrastructure by writing the
    %schema from one of the model files
    %I think the schema only needs to be written once since time is an
    %unlimited dimension and that is all that we are adding to
    ncwriteschema(combined_file, info);

    %loops through all of the current model/var/exp files and temporally
    %merges
    for i = 1:length(model_files) %commented out for troubleshooting

        %obtains size of time dimension at this point in merging
        combined_info = ncinfo(combined_file, "time");

        %ncwriteschema(combined_file, info); don't think we need see above

        ncdisp(combined_file) %for troubleshooting
        data_height = ncread(append(data_path,model_files(i)),"height");
        data_lat_bnds = ncread(append(data_path,model_files(i)),"lat_bnds");
        data_lon_bnds = ncread(append(data_path,model_files(i)),"lon_bnds");
        data_time_bnds = ncread(append(data_path,model_files(i)),"time_bnds");
        data_time = ncread(append(data_path,model_files(i)),"time");
        data_lat = ncread(append(data_path,model_files(i)),"lat");
        data_lon = ncread(append(data_path,model_files(i)), "lon");
        data_var = ncread(append(data_path, model_files(i)), variable);
        %dimensions are not in the same order across models :( will need to
        %address this

        %gets size of time dimension and makes the data type double
        time_size = double(combined_info.Size)

        %defines where the new data should be appended along the time
        %dimension; lat and lon start at zero
        start = time_size + 1
        ncwrite(combined_file,"lat_bnds",data_lat_bnds,[1 1]);
        ncwrite(combined_file,"lon_bnds",data_lon_bnds,[1 1]);
        ncwrite(combined_file,"time_bnds",data_time_bnds,[1 start]);
        ncwrite(combined_file,"height",data_height,[1]);
        ncwrite(combined_file,"time",data_time,[start]);
        ncwrite(combined_file,"lat",data_lat,[1]);
        ncwrite(combined_file,"lon",data_lon,[1]);
        ncwrite(combined_file,variable,data_var,[1 1 start]);
        ncdisp(combined_file)
    end
end


