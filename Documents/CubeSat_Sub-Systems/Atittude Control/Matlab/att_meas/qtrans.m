function [ri]=qtrans(q,rb);
% function [ri]=qtrans(q,rb);
%
% this function transforms the vector rb
% into the coordinate frame represented by
% the quaternion, q, by applying the rotation
% as defined as: ri = q x rb x q*

qstar = [q(1);-q(2:4)];
Rb = [0;rb];

Ri = qmult(q,qmult(Rb,qstar));
ri = Ri(2:4);
