%function for merging netcdf files of the same model, experiment, and
%variant such that all data is in one .nc file

function [] = TemporalMerge(data_path, model_files)
    %string(model_files)
    %string(data_path)
    model = string(ncreadatt(append(data_path,model_files(1)),"/","parent_source_id"))
    experiment = string(ncreadatt(append(data_path,model_files(1)),"/", "experiment_id"))
    variant = string(ncreadatt(append(data_path,model_files(1)),"/","parent_variant_label"))
    variable = ncreadatt(append(data_path,model_files(1)), "/","variable_id")
    combined_file = append(model,"_",experiment,"_",variant,"_",variable,".nc")
    %check that all files have the same model, experiment, and variant
    for i = 1:length(model_files)
        current_model = ncreadatt(append(data_path,model_files(i)),"/","parent_source_id")
        current_experiment = ncreadatt(append(data_path,model_files(i)),"/","experiment_id")
        current_variant = ncreadatt(append(data_path,model_files(i)),"/","parent_variant_label")
        current_variable = ncreadatt(append(data_path,model_files(i)),"/","variable_id")
        if current_model ~= model | current_experiment ~= experiment | current_variant ~= variant | current_variable ~= variable
            %will this break the while loop by changing the length of file
            %names?
            model_files(i)=[]
        end
    end
    %do I need to do this for all of the variables like time, lat, lon, etc
    %in the nc file?

    %probably need to define variable dimensions
    nccreate(combined_file, variable);
    for i = 1:length(model_files)
        info = ncinfo(append(data_path,model_files(i)));
        ncwriteschema(combined_file, info);
        data = ncread(append(data_path,model_files(i)), variable);
        ncwrite(combined_file,variable,data);
    end
end


