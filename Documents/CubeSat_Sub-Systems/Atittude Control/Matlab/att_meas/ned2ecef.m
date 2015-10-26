                function ecef = ned2ecef(ned,lla)
%----------------------------------------------------------------------
%               function ecef = ned2ecef(ned,lla)
%
%   converts a vector given in NED coordinates to a vector in North East 
%   Down coordinates centered at the coordinates given by lla (in radians
%   and meters.
%
%   Demoz Gebre 12/31/2002
%---------------------------------------------------------------------

pitch = abs(lla(1)) + pi/2;

if (lla(1) >= 0)
    eul = [lla(2);-pitch;0];
else
    eul = [lla(2);pitch;0];
end

C_ecef2ned = eul2dcm(eul);

ecef = (C_ecef2ned)'*ned;

