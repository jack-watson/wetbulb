function CFU = consec_frost_days(A)

% IN:  A   - (lat, lon, ndays) 3d array of model data
% OUT: CFU - (lat, lon, nyears) 3d array of indices computed over each year
%           number of consecutive frost days (0C or lower min) per year 
ndays = size(A,3); % number of days along 3rd dimension of matrix A
nyears = floor(ndays/365); % number of years, assuming 365 days per year
thresh = 273.15 + 0; % 0 Celcius to Kelvin

CFU = zeros(size(A,1), size(A,2), nyears); % preallocate result array

for i = 1:nyears % loop over all years
    sidx = 1 + (i-1)*365; % start index of year i
    eidx = sidx + 364; % end index of year i
    Ayri = A(:,:,sidx:eidx); % subset matrix A as only data from year i
    for lat = 1:size(Ayri,1)
        for lon = 1:size(Ayri,2)
            counter = 0;
            for day = 1:size(Ayri,3)
                if Ayri(lat,lon,day) <= thresh
                    counter = counter + 1;
                else
                    counter = 0;
                end
                if counter > CFU(lat,lon,i)
                    CFU(lat,lon,i) = counter;
                end
            end
        end
    end

end





end