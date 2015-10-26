            function g = glocal(lat,h)
%-----------------------------------------------------
%           function g = glocal(lat,h)
%
%   glocal(lat,h) computes the magnitude of the local
%   gravitational acceleration.  lat is lattitude in
%   radians and h is altitude in meter.Note: Because a 
%   North, East, Down coordinate system is assumed, h is
%   negative for altitude above the reference ellipsoid.
%
%   Demoz Gebre 7/3/98
%---------------------------------------------------------

go = 9.780373;
c1 = 0.0052891;
c2 = 0.0000059;
R = 6378137;

mg = go*(1+c1*sin(lat)*sin(lat) - c2*sin(2*lat)*sin(2*lat));

%g = [0;0;mg/(1+(h/R)*(h/R))];
g = [0;0;mg/((1+(h/R))*(1+(h/R)))];

%*************************************************************************%
