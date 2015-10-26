                function v2 = quatrans(v1,q12);
%----------------------------------------------------------------------
%               function v2 = quatmult(v1,q1);
%
%   Transforms a 3 x 1 vector v1 expressed in coordinate frame 1 to 
%   a 3 x 1 vector v2 expressed in coordinate frame 2.  q12 is the 
%   quaternion for the coordinate frame 1 to 2 transformation.
%
%   Demoz Gebre 8/28/01
%---------------------------------------------------------------------

% --- Check for appropriate number of arguments ---- %

if(nargin < 2)
    error('Insufficient Aruguments');
end

% --- Check for correct vector dimensions --- %

[r,c] = size(v1);
if (r < c)
    v1q = [0;v1'];
else
    v1q = [0;v1];
end

v2q = quatmult(quatinv(q12),quatmult(v1q,q12));

v2 = v2q(2:4);
