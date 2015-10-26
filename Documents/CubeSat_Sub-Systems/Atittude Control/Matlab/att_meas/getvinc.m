            function vinc = getvinc(eul,v1,v2,h,lat,Ts)
%-------------------------------------------------------------------------
%           function vinc = getvinc(eul,v1,v2,h,lat,Ts)
%
%   getvinc calculates the velocity increments that will be generated
%   by an inertial measurement unit in the time interval from t = k to
%   t = Ts + k if at t = k velocity was v1, attitude was eul and 
%   lattitude was lat.  v2 is the velocity at t = Ts + k.  eul must 
%   be in radians given in [yaw;pitch;roll] order. v1 and v2 are in
%   m/s, lat is in radians and Ts is in seconds. h is altitude given
%   in meters.  Note: Because a North, East, Down coordinate system is 
%   assumed, h is negative for altitude above the reference ellipsoid.
%
%   Demoz Gebre 7/3/98
%--------------------------------------------------------------------------

%   Compute the Local Gravity Vector
 
g = glocal(lat,h);

%   Change in velocity

dv = v2 - v1;

%   Determine the navigation frame rate

rho = navrate(v1,h,lat);

%   Determine the coriolis acceleration

coraccel = coriolis(v1,rho,lat);

%   Compute the navigation frame to body direction
%   cosine matrix.

Cnav2body = (eul2dcm(eul));

%   Compute vinc

vinc = Cnav2body*(dv + Ts*(coraccel - g));

%*************************************************************************%
