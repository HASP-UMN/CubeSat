            function x = randomwalk(sigma,Ts,Tf)
%----------------------------------------------------------------
%           function x = randomwalk(sigma,Ts,Tf)
%
%   randomwalk generates a vector containing the output sequence of 
%   a discrete random walk process driven by white noise with variance 
%   sigma*sigma.  The sampling time for the discrete process is Ts and
%   the output generated is for a time period 0 <= t <= Tf.  The variance
%   or the resulting process is unbounded and will be sigma*t.
%
%   Demoz Gebre 9/3/98
%---------------------------------------------------------------------

a = 0; b = 1; c = 1; d = 0;
Q = sigma*sigma;      %   Driving Noise White Power Spectral Density
Qd = disrw(a,b,Ts,Q);
u = sqrt(Qd)*randn(length([0:Ts:Tf]),1);
Csystem = ss(a,b,c,d);
Dsystem = c2d(Csystem,Ts);
[ad,bd,cd,dd] = ssdata(Dsystem);
x = zeros(length(u),1);
for k=2:length(u)
    x(k,1) = ad*x(k-1,1) + bd*u(k-1);
end;
%*****************************************************************************
