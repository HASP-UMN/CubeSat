            function a = coriolis(v,nrate,lat);
%--------------------------------------------------------------
%            function a = coriolis(v,nrate,lat);
%
%   coriolis(v,navrate,lat) computes the coriolis acceleration
%   The inputs are velocity (v) in m/s, the navigation frame
%   rotation rate (nrate, computed using navrate.m) in rad/s and 
%   lattitude (lat) in radians.
%
%   Demoz Gebre 7/2/98.
%---------------------------------------------------------------

erate = earthrate(lat);
totalrate = 2*erate + nrate;
a = sk(totalrate)*v; 

%*************************************************************************%
