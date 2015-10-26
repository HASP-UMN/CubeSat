                function ned = ecef2ned2(ecef,ecef_ref)
%----------------------------------------------------------------------
%               function ned = ecef2ned2(ecef,ecef_ref)
%
%   converts a vector (other than a position vector) given in ECEF 
%   coordinates to a vector in North East Down coordinates centered
%   at the coordinates given by ecef_ref.
%
%   Demoz Gebre 12/31/98
%---------------------------------------------------------------------

lla_ref = ecef2lla(ecef_ref);
lat = lla_ref(1);
lon = lla_ref(2);
lla_ref(3) = 0;

enu(3,1)= cos(lat)*cos(lon)*ecef(1)+cos(lat)*sin(lon)*ecef(2)+sin(lat)*ecef(3);
enu(1,1)=-sin(lon)*ecef(1) + cos(lon)*ecef(2);
enu(2,1)=-sin(lat)*cos(lon)*ecef(1)-sin(lat)*sin(lon)*ecef(2)+cos(lat)*ecef(3);

C = eul2dcm([pi/2 0 pi]);
ned = C*enu;
