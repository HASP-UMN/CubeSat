            function q = eul2quat(eul)
%------------------------------------------------
%
%   eul2quat.m : Converts euler angle attitude
%   representation into quaternion representation.
%
%   Usage: q = eul2quat([yaw;pitch,roll]).  Inputs
%   are in radians.
%
%   Demoz Gebre 7/2/98.
%------------------------------------------------

eul = eul/2;

q0 = cos(eul(1))*cos(eul(2))*cos(eul(3)) + ...
        sin(eul(1))*sin(eul(2))*sin(eul(3));  % [z = t]

q1 = cos(eul(1))*cos(eul(2))*sin(eul(3)) - ... % [z = t]
        sin(eul(1))*sin(eul(2))*cos(eul(3));

q2 = cos(eul(1))*sin(eul(2))*cos(eul(3)) + ...
        sin(eul(1))*cos(eul(2))*sin(eul(3));  % [z = t];

q3 = sin(eul(1))*cos(eul(2))*cos(eul(3)) - ...
        cos(eul(1))*sin(eul(2))*sin(eul(3));

q = [q0;q1;q2;q3];

%*************************************************************************%
