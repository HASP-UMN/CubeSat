            function imu = getimu(v1,v2,eul1,eul2,h,lat,Ts)
%------------------------------------------------------------------
%           function imu = getimu(v1,v2,eul1,eul2,h,lat,Ts)
%
%   getimu generates the velocity and angular increments that an
%   inertial measurement unit generates in going from a navigation
%   state [v1,eul1] to [v2 eul2] in Ts seconds.  Velocities v1 and v2
%   are given in m/s and attitude angles eul1 and eul2 are given in 
%   radians in the order of [yaw;pitch;roll].  h is altitude in meters
%   and lat is lattitude in radians.  Note: Because a North, East, Down
%   coordinate system is assumed, h is negative for altitudes above the
%   the reference ellipsoid.  The output of the imu is a row vector 
%   containing the velocity and angular increments in that order.  
%   Angular increments are about the North, East and Down axes respectively.
%
%   Demoz Gebre 7/3/98
%--------------------------------------------------------------------------

vinc = getvinc(eul1,v1,v2,h,lat,Ts);
ainc = getainc(eul1,eul2,v1,h,lat,Ts);
imu = [ainc' vinc'];

%*************************************************************************%
