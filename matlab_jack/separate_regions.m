function R = separate_regions(M, latrange, lonrange, gridedgelats, gridedgelons, plottf)

% still need to implement how to concatenate regions that roll over edges
% of the grid longitudinally

if length(latrange) ~= length(lonrange)
   error('Latitude and longitude region boundaries must have the same number of pairs') 
end

for ri = 1:size(lonrange,1)
    lati1 = latrange(ri,1);
    lati2 = latrange(ri,2);
    loni1 = lonrange(ri,1);
    loni2 = lonrange(ri,2);
    
%     [~,~,latidx_1] = unique(abs(gridedgelats - lati1),'stable');
%     nearestlat1 = gridedgelats(latidx_1 == 1);
    
    [~, latidx_1] = min(abs(gridedgelats(:,1) - lati1));
    [~, latidx_2] = min(abs(gridedgelats(:,2) - lati2));
    
    [~, lonidx_1] = min(abs(gridedgelons(:,1) - loni1));
    [~, lonidx_2] = min(abs(gridedgelons(:,2) - loni2));
    
    latlim = [gridedgelats(latidx_1,1), gridedgelats(latidx_2,2)];
    
    if lonidx_1 > lonidx_2
        regioni = M(latidx_2:latidx_1, lonidx_2:lonidx_1, :);
        lonlim = [gridedgelons(lonidx_2,2), gridedgelons(lonidx_1,1)];
    else
        regioni = M(latidx_2:latidx_1, lonidx_1:lonidx_2, :);
        lonlim = [gridedgelons(lonidx_1,1), gridedgelons(lonidx_2,2)];
    end
    
    if plottf
        load coastlines
        figure('Name', ['Region extending from ' num2str(lati2) '-' num2str(lati1) 'N, ' num2str(loni1) '-' num2str(loni2) 'E'])
        hold on
        worldmap(latlim,lonlim)
        pcolorm(latlim,lonlim,regioni)
        geoshow(coastlat,coastlon,'Color','w')
        colormap(jet)
        colorbar
    end
    
end



end