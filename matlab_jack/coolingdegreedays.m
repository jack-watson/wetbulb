function CDD = coolingdegreedays(tas,tasmin,tasmax)
%cooling degree days
CDD = zeros(size(tas));
thresh = 22 + 273.15; 
for lati = 1:size(tas,1)
    for loni = 1:size(tas,2)
        for dayi = 1:size(tas,3)
            if tasmax(lati,loni,dayi) <= thresh
                CDD(lati,loni,dayi) = 0;
            elseif tas(lati,loni,dayi) <= thresh && tasmax(lati,loni,dayi) > thresh
                CDD(lati,loni,dayi) = (tasmax(lati,loni,dayi) - thresh)/4;
            elseif tasmin(lati,loni,dayi) <= thresh && tas(lati,loni,dayi) > thresh
                CDD(lati,loni,dayi) = (tasmax(lati,loni,dayi) - thresh)/2 - (thresh - tasmin(lati,loni,dayi))/4;
            else %B(lat,lon,day) >= thresh
                CDD(lati,loni,dayi) = tas(lati,loni,dayi) - thresh;
            end
        end
    end
end
end
