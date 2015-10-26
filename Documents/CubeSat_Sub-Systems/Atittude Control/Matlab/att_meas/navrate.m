            function rho = navrate(v,h,lat);
%--------------------------------------------------------
%            function rho = navrate(v,h,lat)
%
%   navrate(v,lat): returns the rotation rate of a 
%   locally level North, East, Down coordinate system
%   with respect to an earth fixed coordinate system.
%   The inputs are velocity (v) in m/s, altitude h in meters
%   and lattitude(lat) in radians.  In a NED coordinate system
%   h is negative for heights above the reference ellipsoid.
%
%   Demoz Gebre 7/2/98
%---------------------------------------------------------

[Rew,Rns] = earthrad(lat);

rho(1,1) = v(2)/(Rew - h);
rho(2,1) = -v(1)/(Rns - h);
rho(3,1) = -v(2)*tan(lat)/(Rew - h);

%*************************************************************************%
