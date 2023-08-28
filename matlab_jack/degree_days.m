function [CDD, HDD] = degree_days(tas)
%for now using tas (daily average surface temperature)
CDD = zeros(size(tas,1),size(tas,2),size(tas,3));
HDD = zeros(size(tas,1),size(tas,2),size(tas,3));
thresh = 273.15 + 22 %convert celsius to kelvin
for lat = 1:size(tas,1)
    for lon = 1:size(tas,2)
        for day = 1:size(tas,3)
            if tas(lat,lon,day) >= thresh
                %result array for cooling degree days
                %will be zero if temp <= 22 Celsius
                CDD(lat,lon,day) = tas(lat,lon,day) - thresh;
            else
                %result array for heating degree days
                %will be zero if temp >= 22 Celsius
                HDD(lat,lon,day) = thresh - tas(lat,lon,day);
            end
        end
    end
end
end
