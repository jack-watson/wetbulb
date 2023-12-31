#function to write metadata to excel and returns list of unsuccessfully downloaded files (0 bytes)

#needs tidyverse, ncdf4, and xlsx libraries


#inputs are list of files to iterate through and working directory in which they are found
write_metadata_xls = function(working_dir){
  library(tidyverse)
  library(ncdf4)
  library(xlsx)
  setwd(working_dir)
  fileNames <- list.files(pattern= "\\.nc$", recursive = TRUE)
  model_name = c() #parent_source_id
  variant = c() #variant_label
  variable = c() #variable_id
  time_units = c() #time units
  num_days = c() #sizing of time dimension
  gridding = c() #grid, or could use lat Size and lon Size, should note units of lat and lon
  spatial_res = c() #nominal_resolution
  file_size = c()
  downloaded_successfully = c()
  
  #set up empty vector for list of unsuccessfully downloaded files
  unsuccessful_downloads = c()
  
  #create a dataframe by going through list of files based on directory and iterate through
  for (fileName in fileNames){
    current_nc_file <- nc_open(fileName)
    current_fileSize = file.info(fileName)$size
    file_size <- append(file_size, current_fileSize)
    
    current_model_name <- ncatt_get(current_nc_file, 0, "parent_source_id")
    model_name <- append(model_name, current_model_name$value)
    current_variant <- ncatt_get(current_nc_file, 0, "variant_label")
    variant <- append(variant, current_variant$value)
    current_spatial_res <- ncatt_get(current_nc_file, 0, "nominal_resolution")
    spatial_res <- append(spatial_res, current_spatial_res$value)
    current_time_units <- ncatt_get(current_nc_file, "time", "units")
    time_units <- append(time_units, current_time_units$value)
    num_days <- append(num_days, dim(ncvar_get(current_nc_file, "time")))
    current_variable <- ncatt_get(current_nc_file, 0, "variable_id")
    variable <- append(variable, current_variable$value)
    current_gridding <- ncatt_get(current_nc_file, 0, "grid")
    gridding <- append(gridding, current_gridding$value)
    
    #conditional statement should check the file size
    if (current_fileSize > 0){
      downloaded_successfully <- append(downloaded_successfully, "Y")
    }
    else{
      append(downloaded_successfully, "N")
      append(unsuccessful_downloads, fileName)
    }
  }
  
  #add each column to dataframe
  df <- data.frame(fileNames, model_name, variable, variant, time_units, num_days, gridding, spatial_res, file_size, downloaded_successfully)
  
  #set up Excel sheet with column names & print dataframe to Excel sheet
  write.xlsx(df, "CMIP_downloads.xls", sheetName = "Sheet1")
  
  #use unsuccessful downloads to call for download retry but include some sort of counter/stopper so that downloads aren't repeated endlessly
  return(unsuccessful_downloads)
}