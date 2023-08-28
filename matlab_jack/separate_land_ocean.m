function [land, ocean] = separate_land_ocean(X, lat, lon, quality)

% quality: scalar integer within range 1 to 100 inclusive
% time complexity scales superlinearly with quality: see landmask.m 

if nargin <= 3 || ~isscalar(quality)
    quality = 95; % same default used by author of landmask.m
end

if max(lon) > 180  % shortsighted 'temporary' hardcoded hack #1
    lon = E2W(lon);
end
if lat(1) > lat(end) % and #2
   lat = flip(lat); 
end

[mlon, mlat] = meshgrid(lon, lat); 

landtf = landmask(mlat, mlon, quality); % mask that land

[land, ocean] = deal(X); % copies of X into land and ocean

land(~landtf) = NaN;
ocean(landtf) = NaN;

end