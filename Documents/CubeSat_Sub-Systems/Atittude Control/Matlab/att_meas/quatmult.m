                function quat = quatmult(q1,q2);
%----------------------------------------------------------------------
%               function quat = quatmult(q1,q2);
%
%   Multiplies two quaternions.
%
%   Demoz Gebre 7/14/98
%---------------------------------------------------------------------


qv1 = q1(2:4);
qs1 = q1(1);
qv2 = q2(2:4);
qs2 = q2(1);

quatv = cross(qv1,qv2) + qs1*qv2 + qs2*qv1;
quats = qs1*qs2 - dot(qv1,qv2);

quat = [quats;quatv];
