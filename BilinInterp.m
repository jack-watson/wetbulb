%function for regridding netcdf files using bilinear interpolation
%***This should only be done after wetbulb is calculated otherwise error
%will propagate****


%do i need orig resolution or can we tell that from the file attributes?
%need a way to automate that
function [] = BilinInterp(ncdf4_orig, data_path, var_id) 
    ncdf4_orig = file_names(i); %just need for scripting, fxn ncdf4_orig is input arg
    var_name = var_id;
    %this might be wrong may need syntax for reading dimension ID
    %can loop through all dimensions and assign to lat, lon, or time etc
    %need to change these to use ncinfo function as opposed to ncreadatt
    %need to append data_path to all
    interpolated_file_name_stem = erase(ncdf4_orig,".nc");
    interpolated_file = append(interpolated_file_name_stem,"_interpolated_withbounds.nc");

    lat_info = ncinfo(append(data_path,ncdf4_orig),"lat");
    lon_info = ncinfo(append(data_path,ncdf4_orig), "lon");
    time_info = ncinfo(append(data_path,ncdf4_orig),"time");
    orig_data = ncread(ncdf4_orig, var_name);
    %need a lat and lon scale factor because not everything is given in
    %squares
    new_res_lat = 2;
    new_res_lon = 2;
    
    lat = ncread(append(data_path,ncdf4_orig),"lat");
    lon = ncread(append(data_path,ncdf4_orig),"lon");
    lat_bnds = ncread(append(data_path,ncdf4_orig),"lat_bnds");
    lon_bnds = ncread(append(data_path,ncdf4_orig),"lon_bnds");
    time = ncread(append(data_path,ncdf4_orig),"time");

    orig_res_lat = round(lat(2) - lat (1),1);
    orig_res_lon = round(lon(2) - lon(1),1);
    scale_factor_lat = orig_res_lat/new_res_lat;
    scale_factor_lon = orig_res_lon/new_res_lon;
    size(orig_data);
    
    %idk about this but supposedly deals with bad/fill values 
    %bad_data_value = ncreadatt(ncdf4_orig, var_name, "_FillValue")
    %orig_data(find(orig_data==bad_data_value))=nan;

    %orig_data = rot90(orig_data); %flips grid 90 degrees to orient correctly

    %lat is 64, lon is 128 for tasmax test file. to be oriented right the
    %matrix should be 64 (rows/y variable) and 128 (columns/x variable)


    %this code is lat x lon

    %instead of old and new maybe can just read in lat and lon data and
    %make new matrices for new lat and lon data?
    %try below
    [OY,OX] = meshgrid(lat,lon);
    new_lat = -90:new_res_lat:90;
    new_lon = 0:new_res_lon:358;
    [NY,NX] = meshgrid(lat(1):new_res_lat:lat(end),lon(1):new_res_lon:lon(end));
    %[NY,NX]=meshgrid(89.875:-1*new_resolution:-89.875,-179.875:new_resolution:179.875);

    %creates empty array for new data that is the correct scaled size
    new_data = nan(size(NX,1),size(NX,2),size(orig_data,3));
    %need empty arrays for new lat bounds and new lon bounds

    %should consider array type - do we need to make it single()? I think
    %no
    for i= 1:length(time)
        new_data(:,:,i) = interp2(OY,OX,orig_data(:,:,i),NY,NX,'bilinear');

        %Vq = interp2(X,Y,V,Xq,Yq) returns interpolated values of a function of two variables at specific query points using linear interpolation. The results always pass through the original sampling of the function. X and Y contain the coordinates of the sample points. V contains the corresponding function values at each sample point. Xq and Yq contain the coordinates of the query points.
    end
    %still need code to write this interpolated array into an .nc file

    %instead of writing full schema, need to take the schema from each
    %variable individually, and manually write schema for variables lat,
    %lon, lat_bnds, lon_bnds, var

    %don't need to include height I think
    %data_height = ncread(append(data_path,ncdf4_orig),"height");
    data_time_bnds = ncread(append(data_path,ncdf4_orig),"time_bnds");
    data_time = ncread(append(data_path,ncdf4_orig),"time");
    data_lat = new_lat;
    data_lon = new_lon;
    data_lat_bnds = lat_bnds*scale_factor_lat;
    data_lon_bnds = lon_bnds*scale_factor_lon;

    time_schema = ncinfo(append(data_path,ncdf4_orig),"time");
    time_bnds_schema = ncinfo(append(data_path,ncdf4_orig),"time_bnds");

    ncwriteschema(interpolated_file,time_schema);
    ncwriteschema(interpolated_file,time_bnds_schema);

    nccreate(interpolated_file,"lat","Dimensions",{"lat",size(new_lat,2)});
    nccreate(interpolated_file,"lon","Dimensions",{"lon",size(new_lon,2)});
    nccreate(interpolated_file,"lat_bnds","Dimensions",{"bnds",2,"lat",size(new_lat,2)});
    nccreate(interpolated_file,"lon_bnds","Dimensions",{"bnds",2,"lon",size(new_lon,2)});
    %check order of lon and lat here
    nccreate(interpolated_file,var_name,"Dimensions",{"lon",size(new_lon,2),"lat",size(new_lat,2),"time",size(data_time,2)});
    ncdisp(interpolated_file)

    
    %ncwrite(interpolated_file,"lat_bnds",data_lat_bnds,[1 1]);
    %ncwrite(interpolated_file,"lon_bnds",data_lon_bnds,[1 1]);
    %ncwrite(interpolated_file,"time_bnds",data_time_bnds,[1 1]);
    %ncwrite(interpolated_file,"height",data_height,[1]);
    ncwrite(interpolated_file,"time",data_time,[1]);
    ncwrite(interpolated_file,"lat",data_lat,[1]);
    ncwrite(interpolated_file,"lon",data_lon,[1]);
    ncwrite(interpolated_file,var_name,new_data,[1 1 1]);
    ncdisp(interpolated_file)
end