            function [Rew, Rns] = earthrad(lat);
%---------------------------------------------------------------
%            function [Rew, Rns] = earthrad(lat);
%
%   earthrad(lat) computes the radius of curvature of the
%   earth at the given lattitude lat.  The returned argument
%   Rew is the radius of curvature in the east-west direction
%   (along parallels) in meters and Rns is the radius of 
%   curvature in the north-south direction (along meridians) in meters.  
%
%   Demoz Gebre, 7/2/98.
%----------------------------------------------------------------

R = 6378137;
f = 1/298.257223563;
Rew = R*(1 + f*sin(lat)*sin(lat));
Rns = R*(1 + f*(3*sin(lat)*sin(lat) - 2));

%*************************************************************************%
