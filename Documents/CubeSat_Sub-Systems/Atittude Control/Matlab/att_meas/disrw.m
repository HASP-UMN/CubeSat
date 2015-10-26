                 function [Cd]=disrw(F,G,Ts,Rwpsd)
%----------------------------------------------------------------
%               function [Cd]=disrw(F,G,T,Rwpsd)
%
%   disrw computes the discrete equivalent of continous noise for the
%   dynamic system described by
%
%                            x_dot = Fx + Gw
%
%   w is the driving noise.  Ts is the sampling time and Rwpsd
%   is the power spectral density of the driving noise.
%
%   J. D. Powell
%---------------------------------------------------------------------

ZF=zeros(size(F));
[n,m]=size(G);
ME=[-F G*Rwpsd*G';
ZF F'];
phi=expm(ME*Ts);
phi12=phi(1:n,n+1:2*n);
phi22=phi(n+1:2*n,n+1:2*n);
Cd=phi22'*phi12;
