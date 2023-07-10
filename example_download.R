library(data.table) # uses data.table under the hood
library(progressr) # for download progress bars
library(progress) # for download progress bars
library(future.apply) #parallizes downloads


handlers(global = TRUE)
handlers("progress")

source("download_files.R")
source("esgf_query.R")

filesets_ecearth = esgf_query(
    project = c("CMIP6"),
    variable = c("tasmax"),
    source = NULL, # c("CanESM5"),
    variant = c("r1i1p1f1"),
    experiment = c("piControl"),
    frequency = c("day"),
    resolution =NULL,  #c("100 km"), # null means all, probably should change that
    type = "File"
)


sum(filesets_ecearth$file_size)/1024/1024/1024 #filesize in gb
destination_path = c("D:/Datasets/ESGF_download_tests")
create_fileset_destinations(filesets_ecearth, destination_path) # creates a file structure
add_node_status(filesets_ecearth) # to prevent attempting to download from servers which are down
download_from_fileset(filesets_ecearth) # begin downloads; no parallel call
