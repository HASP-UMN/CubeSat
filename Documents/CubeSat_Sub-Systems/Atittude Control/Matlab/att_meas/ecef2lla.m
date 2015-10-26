                    function [lla] = ecef2lla(ecef) 
%    
%    Convert X,Y,Z ECEF to Lat,Lon,Alt  
%
%
    E_WGS84 = 0.0818191908426;   % Earth ellipse ecc - unitless
    E2_WGS84 = E_WGS84*E_WGS84;  % Earth's ellipse ecc^2 - unitless
    ONE_MIN_E2 = 1.0 - E2_WGS84;
    A_WGS84 = 6378137.0;    % Earth's ellipse semi-major axis - meters

    x = ecef(1);
    y = ecef(2);
    z = ecef(3);

    lla(2) = atan2(y, x);           %  /*  Longitude  */

    p = sqrt((x * x) + (y * y));    %  /*  Latitude and Altitude  */
    if (p < 0.1)  
       p = 0.1;
    end;
    q = z / p;
    alt = 0.0;
    lat = atan(q * (1.0 / ONE_MIN_E2));
    a = 1.0;
    i = 0;
    while ((a > 0.2) & (i < 20))
        sinlat = sin(lat);
        sinlat2 = sinlat * sinlat;
        radius = A_WGS84 / sqrt(abs(1.0 - (E2_WGS84 * sinlat2)));
        d = alt;
        alt = (p / cos(lat)) - radius;
        a = q * (radius + alt);
        b = (ONE_MIN_E2 * radius) + alt;
        lat = atan2(a, b);
        a = abs(alt - d);
        i = i+ 1;
    end;
    lla(1) = lat;
    lla(3) = -alt;
