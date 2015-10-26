            function x = getmarkov(sigma,tau,Ts,Tf)
%----------------------------------------------------------------
%           function x = getmarkov(sigma,tau,Ts,Tf)
%
%   getmarkov generates a vector containing the output sequence of 
%   a discrete time first order Gauss-Markov process with variance 
%   sigma*sigma, and a time constant tau.  The sampling time for the 
%   discrete process is Ts and the output generated is for a time period 
%   0 <= t <= Tf.
%
%   Demoz Gebre 9/3/98
%---------------------------------------------------------------------

a = -1/tau;;b = 1;c = 1;d = 0;
Q = 2*sigma*sigma/tau;      %   Driving Noise White Power Spectral Density
Qd = disrw(a,b,Ts,Q);
%u = sqrt(tau*Qd/2)*randn(length([0:Ts:Tf]),1);
Csystem = ss(a,b,c,d);
Dsystem = c2d(Csystem,Ts);
[ad,bd,cdd,dd] = ssdata(Dsystem);
%sigmaU = sigma*(1-ad*ad)/bd;
sigmaU = sqrt(Qd);
u = sigmaU*randn(length([0:Ts:Tf]),1);
x = zeros(length(u),1);

for k=2:length(u)
    %    x(k,1) = ad*x(k-1,1) + bd*u(k-1);
    x(k,1) = ad*x(k-1,1) + u(k-1);    
end;

%*****************************************************************************