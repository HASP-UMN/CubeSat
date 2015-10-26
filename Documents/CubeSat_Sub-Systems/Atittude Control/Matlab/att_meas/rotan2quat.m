                function quat = rotan2quat(rotan);
%----------------------------------------------------------------------
%               function quat = rotan2quat(rotan);
%
%   rotan2quat takes a rotation angle vector and converts it to an
%   equivalent quaternion.
%
%   Demoz Gebre 7/14/98
%---------------------------------------------------------------------

MagRotan = norm(rotan);
ScaleFactor = sin(MagRotan/2);
RotAxis = rotan/MagRotan;

q0 = cos(MagRotan/2);
q1 = RotAxis(1)*ScaleFactor;
q2 = RotAxis(2)*ScaleFactor;
q3 = RotAxis(3)*ScaleFactor;

quat = [q0 q1 q2 q3]';
