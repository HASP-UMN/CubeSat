		            function as=sk(a)
%-----------------------------------------------------------
%		            function as=sk(a)
%
%
% This function determines the skew-symmetric matrix
% corresponding to a given vector a with three elements.

	as=[0 -a(3) a(2); a(3) 0 -a(1); -a(2) a(1) 0];

%*************************************************************%
