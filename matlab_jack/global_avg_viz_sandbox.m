
% CMIP etc.
figure('Name', 'Global average 365 day moving mean, precip.')
hold on; grid on
plot(movmean(reshape(mean(pr5A, [1 2]), [], 1), 365), 'LineWidth', 2)
plot(movmean(reshape(mean(pr6A, [1 2]), [], 1), 365), 'LineWidth', 2)
legend({'CMIP5', 'CMIP6'})

%% Can I use coastline graphical objects to delineate land/sea grid cells?
% I guess we'll see lol

% Load an arbitrary CMIP6 file for testing... 
% This EC-Earth3-Veg dataset is the abrupt-4xCO2 precip flux anomalies
% relative to preindustrial control
addpath('D:\CMIP\CMIP6 data\EC-Earth3-Veg')
fname = 'pr_day_EC-Earth3-Veg_4xCO2_piControl_anomalies_r1i1p1f1_gr_20000101-20001231.mat';
load(fname) % loads variable A ('anomaly')
tmean3(A)
% Coordinates for (at least this) model output are in degrees NORTH, degrees EAST
% LAT: -90, 90
% LON: -0.3515625, 359.6484375
glat = load_CMIP_data('pr_day_EC-Earth3-Veg_abrupt-4xCO2_r1i1p1f1_gr_18500101-18501231.nc', 'lat');
glat_bnds = load_CMIP_data('pr_day_EC-Earth3-Veg_abrupt-4xCO2_r1i1p1f1_gr_18500101-18501231.nc', 'lat_bnds');
glon = load_CMIP_data('pr_day_EC-Earth3-Veg_abrupt-4xCO2_r1i1p1f1_gr_18500101-18501231.nc', 'lon');
glon_bnds = load_CMIP_data('pr_day_EC-Earth3-Veg_abrupt-4xCO2_r1i1p1f1_gr_18500101-18501231.nc', 'lon_bnds');
glat = glat{1}; glon = glon{1}; glat_bnds = glat_bnds{1}; glon_bnds = glon_bnds{1};

% landmask.m (file exchange function) examples... most promising option
% landmask.m uses coordinates in degrees NORTH, degrees WEST
% Now let's try landmasking our data...
% Z = mean(A,3);
% lon = E2W(glon);
% lat = flip(glat);
% [mlon, mlat] = meshgrid(lon, lat);
% landcells = landmask(mlat,mlon);
% Z(landcells) = NaN;

[A_land, A_ocean] = separate_land_ocean(mean(A,3), glat, glon, 100);
[cmin,cmax] = global_colorbar_bounds({A_land; A_ocean});
tmean3(A_land,  [], [cmin cmax])
tmean3(A_ocean, [], [cmin cmax])

% to answer my original question, yes

%% Now do it for estimated GEV parameter maps and percentiles

% For the one year of Earth3-Veg we've been using, firstly
bmAmon  = grid_block_maxima(A, 30);
bmAweek = grid_block_maxima(A,  7);
[pAmon,ciAmon, cnvAmon] = grid_gevfit(bmAmon);
[pAweek, ciAweek, cnvAweek] = grid_gevfit(bmAweek);
shpAmo  = pAmon(:,:,1);
shpAwk  = pAweek(:,:,1);
tmean3(shpAmo(shpAmo < 10))
tmean3(shpAwk(shpAwk < 10))

tmean3(pAmon(:,:,1))
tmean3(pAweek(:,:,1))

% don't load 6.82 GB file directly into workspace
m = matfile('canESM_gev_workspace_anomalies.mat');
bm6 = grid_block_maxima(m.pr6A, 30);
bm5 = grid_block_maxima(m.pr5A, 30);
[pEsts6,pCIs6] = grid_gevfit(bm6);
[pEsts5,pCIs5] = grid_gevfit(bm5);

tmean3(pEsts6(:,:,1))
tmean3(pEsts5(:,:,1))







