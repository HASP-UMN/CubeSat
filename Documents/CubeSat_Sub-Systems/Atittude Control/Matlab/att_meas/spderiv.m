             function z = spderiv(x,y,xi)
%-------------------------------------------------------------------------
%            function z = spderiv(x,y,xi)
%
%   SPDERIV Cubic Spline Derivative Interpolation
%   
%   YI = SPDERIV(X,Y,XI) uses cubic spline interpolation to fit the
%   data in X and Y, differentiates the spline and returns values of
%   the spline derivatives evaluated at the points in XI
%
%   PPD = SPDERIV(PP) returns the piecewise polynomial vector PPD 
%   describing the cubic spline derivative of the curve described by
%   the piecewise polynomial in PP.  PP is returned by the function
%   SPLINE and is a data vector containing all information to evaluate
%   and manipulate a spline
%
%   YI = SPDERIV(PP,XI) differentiates the cubic spline given by the
%   piecewise polynomial PP, and returns the values of the spline
%   derivatives evaluated at the pointss in XI.
%
%   See also SPLINE, PPVAL, MKPP, UNMKPP, SPINTGL
%
%   Copyright (c) 1996 by Prentice-Hall, Inc.
%--------------------------------------------------------------------------

if nargin == 3
    pp = spline(x,y);
else
    pp = x;
end

[br,co,npy,nco] = unmkpp(pp);   % take apart pp;
if (nco ==1 | pp(1)~=10)
    error('Spline data does not have the correct PP form.');
end
sf = nco-1:-1:1;                % scale factors for differentiation
dco = sf(ones(npy,1),:).*co(:,1:nco-1); % derivative coefficients
ppd = mkpp(br,dco); % build pp form for derivative

if (nargin ==1)
    z = ppd;
elseif (nargin == 2)
    z = ppval(ppd,y);
else
    z = ppval(ppd,xi);
end
