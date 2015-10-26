function [eul]=quat2eul(q);
% function [eul]=quat2eul(q);
%
% this function converts a quaternion into
% an euler angle vector, defined as [yaw pitch roll]'
% Angles are in radians

qo = q(1);
q1 = -q(2);
q2 = -q(3);
q3 = -q(4);

theta = asin(-2*(q1*q3 + qo*q2));				% extract pitch

if (abs(cos(theta))>1e-4),
	psi = asin((2*(q1*q2 - qo*q3))/cos(theta));	% extract yaw
	phi = asin((2*(q2*q3 - qo*q1))/cos(theta));	% extract roll
else
   psi = atan((-2*(q1*q2+qo*q3))/(qo^2-q1^2+q2^2-q3^2));
   phi = acos((-2*(q1*q2+qo*q3))/sin(psi));
end

eul = [psi theta phi]';
