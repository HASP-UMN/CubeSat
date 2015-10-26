            function C = quat2dcm(q);
%---------------------------------------------
%   quat2dcm : Forms a direction cosine matrix
%   from an attitude representation given in
%   quaternions.
%   Usage : C = quat2dcm([q0,q1,q2,q3])
%
%   Demoz Gebre 7/2/98
%----------------------------------------------

q0 = q(1); q1 = q(2); q2 = q(3); q3 = q(4);

C(1,1) = 1 - 2*(q2*q2 + q3*q3);
C(2,2) = 1 - 2*(q3*q3 + q1*q1);
C(3,3) = 1 - 2*(q1*q1 + q2*q2);

C(2,1) = 2*(q1*q2 - q3*q0);
C(3,1) = 2*(q3*q1 + q2*q0);

C(1,2) = 2*(q3*q0 + q1*q2);
C(3,2) = 2*(q2*q3 - q0*q1);

C(1,3) = 2*(q3*q1 - q2*q0);
C(2,3) = 2*(q2*q3 + q0*q1);

%*************************************************************************%
