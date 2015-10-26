                function C = rotan2dcm(rotan);
%----------------------------------------------------------------------
%               function C = rotan2dcm(rotan);
%
%   rotan2dcm takes a rotation angle vector and converts it to an
%   equivalent direction cosine matrix. The direction cosine matrix C
%   that transforms a vector in a reference axis system at time k
%   to one the same axis sytem at time k+1
%
%   Demoz Gebre 8/8/98
%---------------------------------------------------------------------

phi = norm(rotan);

if (phi < eps)
    dcm = eye(3);
    return;
end

C = (eye(3) + (sin(phi)/phi)*sk(rotan) + ...
         ((1-cos(phi))/(phi*phi))*sk(rotan)*sk(rotan))';

