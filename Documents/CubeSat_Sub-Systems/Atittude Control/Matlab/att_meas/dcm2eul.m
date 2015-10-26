            function eul = dcm2eul(C);
%---------------------------------------------------
%           function eul = dcm2eul(C)
%
%   dcm2eul computes the euler angles (in radians) 
%   given the direction cosine matrix C.  The 
%   directin cosine matrix is the one that takes a
%   vector at time t=k to t+dt.
%
%   Demoz Gebre 7/3/98
%---------------------------------------------------------------------

eul(1,1) = atan2(C(1,2),C(1,1));  %     yaw
eul(2,1) = -asin(C(1,3));         %     pitch
eul(3,1) = atan2(C(2,3),C(3,3));  %     roll


%*************************************************************************%
