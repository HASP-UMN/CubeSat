            function e = earthrate(lat);
%--------------------------------------------------------------
%            function e = earthrate(lat);
%
%   earthrate(lat) computes the earth rate vector in North, East 
%   Down coordinates as a function of latttitude (lat) given in 
%   radians.
%
%   Demoz Gebre 7/2/98.
%---------------------------------------------------------------

omega = 7.292115e-5; %  = 15.041 deg/hr.

e = omega*[cos(lat);0;-sin(lat)];

%*************************************************************************%
