function [ps] = SurfacePressureElev(tas, elevation)
    %temperature should be given in celsius, elevation given in meters
    %this function assumes ideal gases

    Lb = 0.0065 %Kelvin/m, lapse rate of temperature with altitude
    R = 8.3144598 %J/mol K, ideal gas constant
    g_acc = 9.80665 %m/s^2, gravitational acceleration
    M = 0.0289644 %kg/mol, molar mass of air on earth
    Pstandard = 101.29 %kPa, from NASA earth atmosphere model
    Tstandard = 288.08 %Kelvin, from NASA earth atmosphere model

    %air surface temperature is typically measured 2 m above the surface
    h = elevation + 2 %meters
    %convert to what ref pressure would be on that day at 0 m elevation
    Tref = tas + (h*Lb) + 273.15 %Kelvin

    %obtain corresponding ref pressure based on Gay-Lussac's law 
    Pref = (Pstandard/Tstandard)*Tref

    %obtain altitude corrected surface pressure (ps) based on temperature with
    %barometric formula
    ps = Pref*[(tas+273.15)/Tref]^((g_acc*M)/(R*Lb))

    %pressure returned in kilopascals 
end