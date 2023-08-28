function FD = frost_days(A)

% IN:  A  - (lat, lon, ndays) 3d array of model data
% OUT: FD - (lat, lon, nyears) 3d array of indices computed over each year
%           number of frost days (0C or lower tasmin) per year 
ndays = size(A,3); % number of days along 3rd dimension of matrix A
nyears = floor(ndays/365); % number of years, assuming 365 days per year
thresh = 0 + 273.15; % 0 Celcius to Kelvin

FD = zeros(size(A,1), size(A,2), nyears); % preallocate result array

for i = 1:nyears % loop over all years
    sidx = 1 + (i-1)*365; % start index of year i
    eidx = sidx + 364; % end index of year i
    Ayri = A(:,:,sidx:eidx); % subset matrix A as only data from year i
    FD(:,:,i) = sum(Ayri <= thresh, 3); % compute FD index
end

end