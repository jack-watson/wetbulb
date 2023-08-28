function [bad_files] = DataSummary(data_path,files_to_check)
    bad_files = strings;
    for i = 1:length(files_to_check)
        try
            ncdisp(append(data_path,files_to_check(i)));
        catch
            bad_files(end+1) = files_to_check(i);
        end
    end
end
