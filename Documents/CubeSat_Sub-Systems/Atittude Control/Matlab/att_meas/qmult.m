function [qout]=qmult(q,p);
% function [qout]=qmult(q,p);
%
% multiplies the quaternions: q x p
% in order to do coordinate transformations,
% ri = q x rb x q*, implemented in another m-file.
qo  = q(1);
q1  = q(2);
q2  = q(3);
q3  = q(4);

Qplus= [qo -q1 -q2 -q3;
        q1  qo -q3  q2;
        q2  q3  qo -q1;
        q3 -q2  q1  qo];
        
qout = Qplus*p;

