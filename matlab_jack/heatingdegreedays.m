function HDD = heatingdegreedays(tas,tasmin,tasmax)
%heating degree days

HDD = zeros(size(tas,1),size(tas,2),size(tas,3));
thresh = 22 + 273.15;
for lati = 1:size(tas,1)
    for loni = 1:size(tas,2)
        for dayi = 1:size(tas,3)
            if tasmax(lati,loni,dayi) <= thresh
                HDD(lati,loni,dayi) = thresh - tas(lati,loni,dayi);
            elseif tas(lati,loni,dayi) <= thresh && tasmax(lati,loni,dayi) > thresh
                HDD(lati,loni,dayi) = (thresh - tasmin(lati,loni,dayi))/2 - (tasmin(lati,loni,dayi - thresh))/4;
            elseif tasmin(lati,loni,dayi) <= thresh && tas(lati,loni,dayi) > thresh
                HDD(lati,loni,dayi) = (thresh - tasmax(lati,loni,dayi))/4;
            else %B(lat,lon,day) >= thresh
                HDD(lati,loni,dayi) = 0;
            end
        end
    end
end
end