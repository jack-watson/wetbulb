
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

# CMIP6 models: ACCESS-CM2 (Australia), MIROC6 (Japan), MPI-ESM1-2-HR (Germany)

# Make sure all R scripts, including this one, are in the same folder. Set this
# folder as your working directory by running:
# setwd("some/file/path/to/these/scripts") 
# with the file path being the path specific to your machine.
# Use getwd() to see your current working directory path

# configure to your path
#setwd("C:/Users/Kevin/Desktop/SDS/Wet bulb project/R scripts")

# install.packages("phonTools")
# install.packages("stringr")

# 1. Load libraries and config -------------------------------------------------
library(data.table) # uses data.table under the hood
library(progressr) # for download progress bars
library(progress) # for download progress bars
library(future.apply) #parallizes downloads
library(stringr) # for easy string comparisons etc
library(phonTools) # so I can make arrays of zeros(x,y=0)
library(lubridate) # for doing math on datetime

handlers(global = TRUE)
handlers("progress")

source("download_files.R")
source("esgf_query.R")

# 2. Specify search criteria and query ESGF database ---------------------------

# We want a representative sample to test on. Criteria includes:
# - Runs at 100km and 250km resolution
# - At least 3 models per CMIP era
# - Runs for piControl and ssp585 (CMIP6) or rcp85 (CMIP5)
# - Variables tasmax, orog (elevation), huss (near-surface specific humidity) or 
#   hurs (near-surface relative humidity)**
# - Ideally spans 1850-2100, 2000-2100 if exceeds storage constraints
# - Selected models within a MIP era should all be from different countries
# - Between MIP eras, models should be from same set of countries, ideally 
#   different versions of the same model family (e.g., CanESM2, CanESM5)

# **We have temperature so it doesn't matter if we have relative or specific 
# humidity-- we can convert between the two. Bob Kopp's Davies-Jones WBT MATLAB
# function takes boolean input to indicate if humidity input is rel. or spec.

## CMIP6 models:

# ACCESS-CM2 (Australia)
# - orog: yes, 250km
# - tasmax: piControl, ssp585
# - huss: piControl, ssp585

# MIROC6 (Japan)
# - orog: yes,250km
# - tasmax: piControl, ssp585
# - huss: piControl, ssp585

# MPI-ESM1-2-HR (Germany)
# - orog: yes, 100km
# - tasmax: piControl, ssp585
# - huss:piControl, ssp585


# 2.1 CMIP6, by variable =======================================================

modelNames_CMIP6 = c("ACCESS-CM2", "MIROC6", "MPI-ESM1-2-HR")

# orog, CMIP6 ------------------------------------------------------------------
filesets_CMIP6_orog = esgf_query(
  project = c("CMIP6"),
  variable = c("orog"),
  source = modelNames_CMIP6,
  replica = FALSE,
  variant = NULL,
  experiment = "piControl",
  frequency = NULL,
  resolution =NULL,  #c("100 km"), 
  type = "File"
)
orog6_df = data.frame(filesets_CMIP6_orog)
unique(orog6_df[c("source_id","nominal_resolution")])
orog6_df = orog6_df[orog6_df["frequency"] == "fx",] # remove inexplicable monthly results?
# 250km orog for MIROC6 and ACCESS-CM2
# 100km orog for FGOALS-f3-L, E3SM-2-0, and MPI-ESM1-2-HR

# tasmax, CMIP6 ----------------------------------------------------------------
filesets_CMIP6_tasmax = esgf_query(
  project = c("CMIP6"),
  variable = c("tasmax"),
  source = modelNames_CMIP6, 
  variant = c("r1i1p1f1"),
  experiment = c("piControl", "ssp585"),
  frequency = c("day"),
  resolution =NULL,  #c("100 km"), # null means all, probably should change that
  type = "File"
)
tas6_df <- data.frame(filesets_CMIP6_tasmax)
unique(tas6_df[c("source_id","nominal_resolution", "experiment_id")])
tas6_df_piC <- tas6_df[tas6_df$experiment_id == "piControl", ]
tas6_df_585 <- tas6_df[tas6_df$experiment_id == "ssp585", ]
tas6_df_585 <- tas6_df_585[tas6_df_585$datetime_start >= "1999-01-01" & tas6_df_585$datetime_end <= "2101-01-01", ]

uq_tas6_piC <- unique(tas6_df_piC[c("source_id","nominal_resolution", "experiment_id")])
for (i in 1:nrow(uq_tas6_piC)) {
  name_i <- uq_tas6_piC$source_id[i]
  df_i <- tas6_df_piC[tas6_df_piC$source_id == name_i, ]
  start_i <- min(df_i$datetime_start)
  end_i <- start_i %m+% years(250)
  df_subset_i <- df_i[df_i$datetime_start <= end_i, ]
  if (i == 1) {
    tas6_df_piC_250yr <- df_subset_i
  } else {
    tas6_df_piC_250yr <- rbind(tas6_df_piC_250yr, df_subset_i)
  }
}
tas6_df <- rbind(tas6_df_585, tas6_df_piC_250yr)

# huss, CMIP6 ------------------------------------------------------------------
filesets_CMIP6_huss = esgf_query(
  project = c("CMIP6"),
  variable = c("huss"),
  source = modelNames_CMIP6, 
  variant = c("r1i1p1f1"),
  experiment = c("piControl", "ssp585"),
  frequency = c("day"),
  resolution =NULL,  #c("100 km"), # null means all, probably should change that
  type = "File"
)
hus6_df = data.frame(filesets_CMIP6_huss)
unique(hus6_df[c("source_id","nominal_resolution", "experiment_id")])
hus6_df_piC <- hus6_df[hus6_df$experiment_id == "piControl", ]
hus6_df_585 <- hus6_df[hus6_df$experiment_id == "ssp585", ]
hus6_df_585 <- hus6_df_585[hus6_df_585$datetime_start >= "1999-01-01" & hus6_df_585$datetime_end <= "2101-01-01", ]

uq_hus6_piC <- unique(hus6_df_piC[c("source_id","nominal_resolution", "experiment_id")])
for (i in 1:nrow(uq_hus6_piC)) {
  name_i <- uq_hus6_piC$source_id[i]
  df_i <- hus6_df_piC[hus6_df_piC$source_id == name_i, ]
  start_i <- min(df_i$datetime_start)
  end_i <- start_i %m+% years(250)
  df_subset_i <- df_i[df_i$datetime_start <= end_i, ]
  if (i == 1) {
    hus6_df_piC_250yr <- df_subset_i
  } else {
    hus6_df_piC_250yr <- rbind(hus6_df_piC_250yr, df_subset_i)
  }
}
hus6_df <- rbind(hus6_df_585, hus6_df_piC_250yr)


# 2.2 CMIP5 ====================================================================

modelNames_CMIP5 = c("CSIRO-Mk3.6.0", "MIROC5", "MPI-ESM-LR")

# orog, CMIP5 ------------------------------------------------------------------
filesets_CMIP5_orog = esgf_query(
  project = c("CMIP5"),
  variable = c("orog"),
  source = modelNames_CMIP5, 
  variant = NULL,
  experiment = "piControl",
  frequency = NULL,
  resolution =NULL,  
  type = "File"
)
orog5_df = data.frame(filesets_CMIP5_orog)
unique(orog5_df[c("source_id")])
# add datetime_start and datetime_end columns so we can append to other dataframes
orog5_df$datetime_start = rep(as.Date("0000-01-01"), nrow(orog5_df))#c((1:nrow(orog5_df))*0)
orog5_df$datetime_end = rep(as.Date("0000-01-01"), nrow(orog5_df)) #c((1:nrow(orog5_df))*0)


# tasmax, CMIP5 ----------------------------------------------------------------
filesets_CMIP5_tasmax = esgf_query(
  project = c("CMIP5"),
  variable = c("tasmax"),
  source = modelNames_CMIP5, 
  variant = c("r1i1p1"),
  experiment = c("piControl", "rcp85"),
  frequency = c("day"),
  resolution =NULL,  
  type = "File"
)
tas5_df = data.frame(filesets_CMIP5_tasmax)
# CSIRO-Mk3 is returning hur, hus, ua, ta, va, wap when searching tasmax... this fixes it, not a permanent solution though
tas5_df <- tas5_df[!(tas5_df$source_id == "CSIRO-Mk3.6.0" & !grepl("/ta/", tas5_df$file_url)), ]

unique(tas5_df[c("source_id", "experiment_id")])
tas5_df_piC <- tas5_df[tas5_df$experiment_id == "piControl", ]
tas5_df_85 <- tas5_df[tas5_df$experiment_id == "rcp85", ]
tas5_df_85 <- tas5_df_85[tas5_df_85$datetime_start >= "1999-01-01" & tas5_df_85$datetime_end <= "2101-01-01", ]


uq_tas5_piC <- unique(tas5_df_piC[c("source_id", "experiment_id")])
for (i in 1:nrow(uq_tas5_piC)) {
  name_i <- uq_tas5_piC$source_id[i]
  df_i <- tas5_df_piC[tas5_df_piC$source_id == name_i, ]
  start_i <- min(df_i$datetime_start)
  end_i <- start_i %m+% years(250)
  df_subset_i <- df_i[df_i$datetime_start <= end_i, ]
  if (i == 1) {
    tas5_df_piC_250yr <- df_subset_i
  } else {
    tas5_df_piC_250yr <- rbind(tas5_df_piC_250yr, df_subset_i)
  }
}
tas5_df <- rbind(tas5_df_85, tas5_df_piC_250yr)

# huss, CMIP5 ------------------------------------------------------------------
filesets_CMIP5_huss = esgf_query(
  project = c("CMIP5"),
  variable = c("hus"),
  source = modelNames_CMIP5, 
  variant = c("r1i1p1"),
  experiment = c("piControl", "rcp85"),
  frequency = c("day"),
  resolution =NULL,  
  type = "File"
)
hus5_df = data.frame(filesets_CMIP5_huss)
unique(hus5_df[c("source_id", "experiment_id")])
hus5_df_piC <- hus5_df[hus5_df$experiment_id == "piControl", ]
hus5_df_85 <- hus5_df[hus5_df$experiment_id == "rcp85", ]
hus5_df_85 <- hus5_df_85[hus5_df_85$datetime_start >= "1999-01-01" & hus5_df_85$datetime_end <= "2101-01-01", ]

uq_hus5_piC <- unique(hus5_df_piC[c("source_id", "experiment_id")])
for (i in 1:nrow(uq_hus5_piC)) {
  name_i <- uq_hus5_piC$source_id[i]
  df_i <- hus5_df_piC[hus5_df_piC$source_id == name_i, ]
  start_i <- min(df_i$datetime_start)
  end_i <- start_i %m+% years(250)
  df_subset_i <- df_i[df_i$datetime_start <= end_i, ]
  if (i == 1) {
    hus5_df_piC_250yr <- df_subset_i
  } else {
    hus5_df_piC_250yr <- rbind(hus5_df_piC_250yr, df_subset_i)
  }
}
hus5_df <- rbind(hus5_df_85, hus5_df_piC_250yr)


# 3. Download data files corresponding to search results =======================

df_CMIP6 <- rbind(orog6_df, tas6_df, hus6_df)
df_CMIP5 <- rbind(orog5_df, tas5_df, hus5_df)

dt_CMIP6 <- as.data.table(df_CMIP6, TRUE)
dt_CMIP5 <- as.data.table(df_CMIP5, TRUE)

sprintf("Total CMIP6 download size: %f GB",sum(df_CMIP6$file_size)/1024/1024/1024) # filesize in GB
sprintf("Total CMIP5 download size: %f GB",sum(df_CMIP5$file_size)/1024/1024/1024) # filesize in GB

#sum(filesets_ecearth$file_size)/1024/1024/1024 #filesize in gb
destination_path = c("D:/Datasets/ESGF_download_tests/test_set_07262023")

create_fileset_destinations(dt_CMIP6, destination_path) # creates a file structure
add_node_status(dt_CMIP6) # to prevent attempting to download from servers which are down
download_from_fileset(dt_CMIP6) # begin downloads; no parallel call

create_fileset_destinations(dt_CMIP5, destination_path) # creates a file structure
add_node_status(dt_CMIP5) # to prevent attempting to download from servers which are down
download_from_fileset(dt_CMIP5) # begin downloads; no parallel call

