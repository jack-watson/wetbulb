%function for regridding netcdf files using bilinear interpolation
%***This should only be done after wetbulb is calculated otherwise error
%will propagate****


%do i need orig resolution or can we tell that from the file attributes?
%need a way to automate that
function [] = BilinInterp(ncdf4_orig, data_path, orig_resolution, new_resolution) 
    var_name = ncreadatt(append(data_path,ncdf4_orig),"/","variable_id")
    %this might be wrong may need syntax for reading dimension ID
    %can loop through all dimensions and assign to lat, lon, or time etc
    %need to change these to use ncinfo function as opposed to ncreadatt
    %need to append data_path to all
    interpolated_file = append(ncdf4_orig,"_interpolated");

    lat_info = ncinfo(append(data_path,ncdf4_orig),"lat")
    lon_info = ncinfo(append(data_path,ncdf4_orig), "lon")
    time_info = ncreadinfo(append(data_path,ncdf4_orig),"time")
    orig_data = ncread(ncdf4_orig, var_name);
    scale_factor = orig_resolution/new_resolution
    size(orig_data)
    
    %idk about this
    bad_data_value = ncreadatt(ncdf4_orig, var_name, "_FillValue")
    orig_data(find(orig_data==bad_data_value))=nan;
    %may need to flip grid
    %will need to change numbers for lon/lat bounds based on desired
    %resolution, need to find a way to make that variable

    %Throughout the code below make sure indexing/x and y are correctly
    %attributed to lat and lon - need to add code to check dims and flip
    %grid if necessary

    %this code is lat x lon
    %what data structures are those
    [OY,OX]=meshgrid(90:-1*orig_resolution:-90, -180:orig_resolution:177.5); 
    [NY,NX]=meshgrid(89.875:-1*new_resolution:-89.875,-179.875:new_resolution:179.875);
    new_data = nan(double(lon_info.Size)*scale_factor, double(lat_info.Size)*scale_factor, double(time_info.Size));
    %should consider array type - do we need to make it single()?
    for i= 1:length(time)
        %look into the single thing
        new_data(:,:,i) = interp2(OY,OX,orig_data(:,:,i),NY,NX,'bilinear')
    end
    %still need code to write this interpolated array into an .nc file
    
     info = ncinfo(append(data_path,ncdf4_orig));

    %sets up new temporally merged file infrastructure by writing the
    %schema from one of the model files
    %I think the schema only needs to be written once since time is an
    %unlimited dimension and that is all that we are adding to
        ncwriteschema(interpolated_file, info);
    

        %change all model_files to ncdf4_orig
        %need to redefine lat_bnds and lon_bnds as well as lat and lon
        data_height = ncread(append(data_path,ncdf4_orig),"height");
        data_time_bnds = ncread(append(data_path,model_files(i)),"time_bnds");
        data_time = ncread(append(data_path,model_files(i)),"time");

        %assign below to OYOX and NYNX from above; need to also redefine
        %lat and lon bounds
        data_lat = ncread(append(data_path,model_files(i)),"lat");
        data_lon = ncread(append(data_path,model_files(i)), "lon");
        %dimensions are not in the same order across models :( will need to
        %address this
        
        ncwrite(interpolated_file,"lat_bnds",data_lat_bnds,[1 1]);
        ncwrite(interpolated_file,"lon_bnds",data_lon_bnds,[1 1]);
        ncwrite(interpolated_file,"time_bnds",data_time_bnds,[1 1]);
        ncwrite(interpolated_file,"height",data_height,[1]);
        ncwrite(interpolated_file,"time",data_time,[1]);
        ncwrite(interpolated_file,"lat",data_lat,[1]);
        ncwrite(interpolated_file,"lon",data_lon,[1]);
        ncwrite(interpolated_file,variable,new_data,[1 1 1]);
        ncdisp(interpolated_file)
end

    % rhum = ncread('rhum.mon.mean.nc','rhum');
    % %i believe this shortens it to just the year 2004
    % Rhum2004 = squeeze(rhum(:,:,:,301:312));
    % size(Rhum2004)
    % %i think this is finding which are _fillValue aka not real data
    % %this is stored in the _FillValue attribute. Makes those NaN
    % Rhum2004(find(Rhum2004==32766|Rhum2004==-32767))=nan;
    % %rearranges based on desired format of lat/lon i think? Maybe flipping the
    % %grid, should check if we need to do that
    % Rhum2004=[Rhum2004(73:144,:,:);Rhum2004(1:72,:,:)];%-180->180 
    % %google meshgrid function - creates easily referrable grid coordinates with
    % %desired size. The first line is the original size and the second is the
    % %new size
    % [OY,OX]=meshgrid(90:-2.5:-90, -180:2.5:177.5); 
    % [NY,NX]=meshgrid(89.875:-0.25:-89.875,-179.875:0.25:179.875); 
    % %creates empty .mat
    % RH2004=nan(1440,720,12); 
    % %loops through time dimension
    % for i=1:12 
    % RH2004(:,:,i) = ...
    % single(interp2(OY,OX,Rhum2004(:,:,i),NY,NX,'bilinear')); 
    % end
    % %this focuses only on the rhum variable - would need to then write to a new
    % %.nc file
    % save RH2004 RH2004
    % ncdisp("rhum.mon.mean.nc")