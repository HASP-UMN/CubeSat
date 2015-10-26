             function z = polyderiv(x,y,xi,N)
%-------------------------------------------------------------------------
%            function z = polyderiv(x,y,xi,N)
%
%   POLYDERIV Derivative Interpolation
%
%   Evaluates the derivative of a data set numerically.  Given a data 
%   set with independent variable x and dependent variable y, POLYDERIV 
%   fits a polynomial of order N to the data then differentiates the 
%   polynomial and evaluates it at xi.
%   
%--------------------------------------------------------------------------


[pp,ss] = polyfit(x,y,N);
ppderiv = zeros(1,N);
for k = 1:N
    ppderiv(k) = (N-k+1)*pp(k);
end 

z = polyval(ppderiv,xi);

