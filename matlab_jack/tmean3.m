function fighandle = tmean3(ts, coords, cmapext, lcolor, figname)

load coastlines

meshtf = false;
if nargin == 1 || isempty(coords)
    latlim = [-90 90];
    lonlim = [0 360];
elseif nargin >= 2 && ~isempty(coords)
    if numel(coords) == 4
        latlim = coords(1,:);
        lonlim = coords(2,:);
    elseif numel(coords) > 4
        lat = coords(:,1);
        lon = coords(:,2);
        latlim = [min(lat), max(lat)];
        lonlim = [min(lon), max(lon)];
        [mlat, mlon] = meshgrid(lat, lon);
        meshtf = true;
    end
end

if nargin < 4 || isempty(lcolor)
    lcolor = 'w';
end

if nargin > 4 && ~isempty(figname)
    fg = figure('Name', figname); hold on
else
    fg = figure; hold on
end

switch ndims(ts) % this enforces either a 2 or 3 dimensional array/matrix
    case 3
        % pointwise temporal mean (along 3rd axis) of 3D matrix
        tsAvg = mean(ts, 3);
    case 2
        tsAvg = ts;
end

worldmap(latlim,lonlim)
if meshtf
    pcolorm(mlat,mlon,tsAvg)
else
    pcolorm(latlim, lonlim, tsAvg)
end
geoshow(coastlat,coastlon,'Color',lcolor)

if nargin >= 3 && ~isempty(cmapext)
    caxis manual
    caxis([cmapext(1) cmapext(2)])
end
colormap(jet)
colorbar

if nargout > 0
   fighandle = fg; 
end

end