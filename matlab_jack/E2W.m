function wlon = E2W(elon)

% converts degrees east (0, 360) to degrees west (-180, 180) with reference
% to the prime meridian

% can also convert from degrees east with arbitrary sign change reference
% meridians/longitudes
% e.g. an array of sorted ascending longitudinal coords with bounds 
% (-14, 346) degrees east converted to (-180, 180) degrees west 

% annoying function to convert between weird non-standard coordinate
% conventions bc of different IPCC/CMIP and landmask.m systems

wlon = elon.*0;

for i = 1:length(elon)
    ei = elon(i);
    if ei*-1 > 0 % if negative (edge case, CMIP files go from -0.3515625 --> 359.6484375
       if ei + 360 >= 180
           wi = ei*-1;
       elseif ei + 360 < 180
           wi = (ei+360)*-1;
       end
    elseif ei >= 0 % most cases
        if ei <= 180
           wi = ei*-1; 
        elseif ei > 180
            wi = 360 - ei;
        end
    end
    wlon(i) = wi;
end

end