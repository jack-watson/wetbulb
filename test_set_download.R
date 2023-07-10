
# Script for downloading a set of ESM outputs from CMIP5 and CMIP6 models that
# is representative of the +/- 20 terabytes of data in our full analysis while 
# being manageable to share, store, manipulate and analyze on consumer PCs. This
# lets us efficiently unit test and debug our code  while building out a 
# codebase for processing, analyzing, and visualizing an arbitrarily large number
# of climate model simulation runs. 

# Variables: tasmax (max near-surface temp), huss (near-surface specific humidity),
# and orog (gridded surface altitude above sea level at resolution of other vars)

# Timestep: daily

# Variants: r1i1p1f1

# Experiments: piControl, SSP585 (CMIP6), RCP8.5 (CMIP5)
# This lets us compare baseline pre-industrial conditions with a hypothetical 
# "worst-case" high emissions scenario out to 2100.  

# CMIP5 models: CSIRO-Mk3.6.0 (Australia), MIROC5 (Japan), GISS-E2-H (US NASA),
# FGOALS-g2 (China), MPI-ESM-LR (Germany)

# CMIP6 models: ACCESS-CM2 (Australia), MIROC6 (Japan), E3SM-2-0 (US DOE), 
# FGOALS-f3-L (China), MPI-ESM1-2-HR (Germany)

# Make sure all R scripts, including this one, are in the same folder. Set this
# folder as your working directory by running:
# setwd("some/file/path/to/these/scripts") 
# with the file path being the path specific to your machine.
# Use getwd() to see your current working directory path


# 1. Load libraries and config -------------------------------------------------
library(data.table) # uses data.table under the hood
library(progressr) # for download progress bars
library(progress) # for download progress bars
library(future.apply) #parallizes downloads

handlers(global = TRUE)
handlers("progress")

source("download_files.R")
source("esgf_query.R")



# 2. Specify search criteria and query ESGF database ---------------------------

# 2.1 CMIP6, by variable
filesets_CMIP6_orog = esgf_query(
  project = c("CMIP6"),
  variable = c("orog"),
  source = c("ACCESS-CM2", "MIROC6", "E3SM-2-0", "FGOALS-f3-L", "MPI-ESM1-2-HR"), 
  variant = NULL,
  experiment = NULL,
  frequency = NULL,
  resolution =NULL,  #c("100 km"), # null means all, probably should change that
  type = "File"
)

filesets_CMIP6_tasmax = esgf_query(
  project = c("CMIP6"),
  variable = c("tasmax"),
  source = c("ACCESS-CM2", "MIROC6", "E3SM-2-0", "FGOALS-f3-L", "MPI-ESM1-2-HR"), 
  variant = c("r1i1p1f1"),
  experiment = c("piControl", "SSP585"),
  frequency = c("day"),
  resolution =NULL,  #c("100 km"), # null means all, probably should change that
  type = "File"
)

filesets_CMIP6_huss = esgf_query(
  project = c("CMIP6"),
  variable = c("huss"),
  source = c("ACCESS-CM2", "MIROC6", "E3SM-2-0", "FGOALS-f3-L", "MPI-ESM1-2-HR"), 
  variant = c("r1i1p1f1"),
  experiment = c("piControl", "SSP585"),
  frequency = c("day"),
  resolution =NULL,  #c("100 km"), # null means all, probably should change that
  type = "File"
)

# 2.2 CMIP5
filesets_CMIP5_orog = esgf_query(
  project = c("CMIP5"),
  variable = c("orog"),
  source = c("CSIRO-Mk3.6.0", "MIROC5", "GISS-E2-H", "FGOALS-g2", "MPI-ESM-LR"), 
  variant = NULL,
  experiment = NULL,
  frequency = NULL,
  resolution =NULL,  
  type = "File"
)

filesets_CMIP5_tasmax = esgf_query(
  project = c("CMIP5"),
  variable = c("tasmax"),
  source = c("CSIRO-Mk3.6.0", "MIROC5", "GISS-E2-H", "FGOALS-g2", "MPI-ESM-LR"), 
  variant = c("r1i1p1"),
  experiment = c("piControl", "rcp85"),
  frequency = c("day"),
  resolution =NULL,  
  type = "File"
)

filesets_CMIP5_huss = esgf_query(
  project = c("CMIP5"),
  variable = c("hus"),
  source = c("CSIRO-Mk3.6.0", "MIROC5", "GISS-E2-H", "FGOALS-g2", "MPI-ESM-LR"), 
  variant = NULL, #c("r1i1p1"),
  experiment = c("piControl", "rcp85"),
  frequency = c("day"),
  resolution =NULL,  
  type = "File"
)


# 3. Download data files corresponding to search results -----------------------

sum(filesets_ecearth$file_size)/1024/1024/1024 #filesize in gb
destination_path = c("D:/Datasets/ESGF_download_tests")
create_fileset_destinations(filesets_ecearth, destination_path) # creates a file structure
add_node_status(filesets_ecearth) # to prevent attempting to download from servers which are down
download_from_fileset(filesets_ecearth) # begin downloads; no parallel call
