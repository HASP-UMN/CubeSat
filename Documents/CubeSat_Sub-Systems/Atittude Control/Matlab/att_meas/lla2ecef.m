                function ECEF = lla2ecef(lla)
%----------------------------------------------------------------------
%               function ECEF = lla2ecef(lla)
%
%   converts lattitude, longtitude and altitude coordinates (given in
%   radians and meters) into ECEF coordinates (given in meters).
%
%   Demoz Gebre 8/18/98 
%---------------------------------------------------------------------


EarthRad = 6378137.0;
ecc = 0.0818191908426;
ecc2 = ecc*ecc;
        
sinlat = sin(lla(1));
coslat = cos(lla(1));
Rn = EarthRad / sqrt(abs(1.0 - (ecc2 * sinlat * sinlat)));
ECEF(1,1) = (Rn - lla(3)) * coslat * cos(lla(2));
ECEF(2,1) = (Rn - lla(3)) * coslat * sin(lla(2));
ECEF(3,1) = (Rn * (1.0 - ecc2) - lla(3)) * sinlat;
