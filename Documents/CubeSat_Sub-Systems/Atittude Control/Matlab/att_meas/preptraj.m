function [t_out,att,vel,pos] = preptraj(t_in,Ts,spd_in,yaw_in,h_dot,lat_in,...
                                        lon_in,alt_in,the_in,phi_in)
%================================================================================%
%    function [t_out,att,vel,pos] = preptraj(t_in,Ts,spd_in,yaw_in,h_dot,lat_in,...
%                                        lon_in,alt_in,the_in,phi_in)
%
%    The m-file preptraj (short for "prepare trajectory") provides
%    a means for establishing speed and heading based waypoints.  That is,
%    the user specifies the speed and heading of a vehicle at certain time
%    steps and preptraj generates a time history of velocity, attitude and
%    position.  If roll is not specified, it is assumed that the vehicle is an
%    airplane executing a coordinated turn.  Thus, the roll angle will be a
%    function of the yaw rate.
%
%    Programmer:            Demoz Gebre
%    Las Modified:          November 15, 2002
%=================================================================================%

PLOT_FLAG = 1;          %  Set to 1 if you want to see a plot of the trajectory.
SRGPS = 1;              %  JPALS Simulations

%==================================%
% (0.0)    Argument Checking       %
%==================================%

if (nargin < 10)
    phi_in = [];
end

%==================================%
% (0.5)  Define Some Constants     %
%==================================%

d2r = pi/180;
r2d = 1/d2r;
ft2m = 0.3048;
KTS2ms = 0.5144;
ms2KTS = 1/KTS2ms;
norm_g = 9.81;

%==================================%
% (1)  Establish the time Vector   %
%==================================%

t_out = [0:Ts:t_in(end)]';

%============================================%
% (2) Fill in the heading and speed history  %
%============================================%

psi = interp1q(t_in,yaw_in,t_out);
spd = interp1q(t_in,spd_in,t_out);

%==================================%
% (3)      Generate Vn and Ve      %
%==================================%

Vn = spd.*cos(psi);
Ve = spd.*sin(psi);
Vd = interp1q(t_in,h_dot,t_out);

%========================================%
% (4) Generate pitch and roll histories  %
%========================================%

the = interp1q(t_in,the_in,t_out);
if (~isempty(phi_in))
    phi = interp1q(t_in,phi_in,t_out);
else
    psi_dot = myderiv(t_out,psi,t_out);
 %   psi_dot = [diff(psi);0];
    fun_arg = (spd.*psi_dot)/norm_g;
    phi = atan(fun_arg);
end

%========================================%
% (4)      Generate Position History     %
%========================================%

drl = length(t_out);
lat = zeros(drl,1); lat(1,1) = lat_in;
lon = zeros(drl,1); lon(1,1) = lon_in;
alt = zeros(drl,1); alt(1,1) = alt_in;

for k = 2:drl;
    velvec = [Vn(k-1);Ve(k-1);Vd(k-1)];
    dll = latlonrate(velvec,alt(k-1),lat(k-1));
    lat(k,1) = lat(k-1) + Ts*dll(1);
    lon(k,1) = lon(k-1) + Ts*dll(2);
    alt(k,1) = alt(k-1) + Ts*Vd(k-1,1);
end
%========================================%
% (5)      Filter the Final Data         %
%========================================%

fc = 1;             %  Filter Cutoff Frequency
fs = 1/Ts;          %  Sampling Frequency
fn = fs/2;          %  Nyquist Frequency
Wc = fc/fn;         %  Discrete Cutoff
nf = 3;             %  Butterworth Filter Order
if (Wc >= 1)
    Wc = 0.99;
end

[filNum,filDen] = butter(nf,Wc);

%---- (5.1) filter velocity ----%

vel = zeros(drl,1);
vel(:,1) = filtfilt(filNum,filDen,Vn);
vel(:,2) = filtfilt(filNum,filDen,Ve);
vel(:,3) = filtfilt(filNum,filDen,Vd);

%---- (5.2) filter velocity ----%

pos = zeros(drl,1);
pos(:,1) = filtfilt(filNum,filDen,lat);
pos(:,2) = filtfilt(filNum,filDen,lon);
pos(:,3) = filtfilt(filNum,filDen,alt);

%---- (5.3) filter attitude ----%

att = zeros(drl,1);
att(:,1) = filtfilt(filNum,filDen,psi);
att(:,2) = filtfilt(filNum,filDen,the);
att(:,3) = filtfilt(filNum,filDen,phi);


%att = [psi the phi];
%vel = [Vn Ve Vd];
%pos = [lat lon alt];

%========================================%
% (5)      Plot the Data (if Required)   %
%========================================%

if (PLOT_FLAG)
    close all;
    figure(gcf)
    plot(r2d*pos(:,2),r2d*pos(:,1),'r-');grid on
    xlabel('Longitude (deg)');ylabel('Latitude (deg)');
    title('Ground Track');axis('equal');
    
    if (SRGPS)
        ecef_ref = lla2ecef(pos(end,:)');
        for k=1:drl
            ecef_local = lla2ecef(pos(k,:)');
            pos_ned(k,:) = (ecef2ned(ecef_local,ecef_ref))';
        end
      
        figure(gcf+1)
        plot(pos_ned(:,1)/1000/1.8520,-pos(:,3)/ft2m,'r-');grid on;
        xlabel('Distance From Ship (NM)');ylabel('Altitude (ft)');
        title('Vertical Profile');
        
    end
    
    figure(gcf+1)
    subplot(311)
    plot(t_out,vel(:,1),'r-');grid on;ylabel('V_n (m/s)');
    subplot(312)
    plot(t_out,vel(:,2),'r-');grid on;ylabel('V_e (m/s)');
    subplot(313)
    plot(t_out,vel(:,3),'r-');grid on;ylabel('V_d (m/s)');
    xlabel('Time (sec)');
    title('Velocity History')
    
    figure(gcf+1)
    subplot(311)
    plot(t_out,r2d*pos(:,1),'r-');grid on;ylabel('\Lambda (deg)');
    subplot(312)
    plot(t_out,r2d*pos(:,2),'r-');grid on;ylabel('\lambda (deg)');
    subplot(313)
    plot(t_out,pos(:,3)/ft2m,'r-');grid on;ylabel('h (ft)');
    xlabel('Time (sec)');
    title('Position History')
    
    figure(gcf+1)
    subplot(311)
    plot(t_out,r2d*att(:,1),'r-');grid on;ylabel('\psi (deg)');
    subplot(312)
    plot(t_out,r2d*att(:,2),'r-');grid on;ylabel('\theta (deg)');
    subplot(313)
    plot(t_out,r2d*att(:,3),'r-');grid on;ylabel('\phi (deg)');
    xlabel('Time (sec)');
    title('Attitude History');
    
end

%=======================================================================
%***********************************************************************
%=======================================================================

function z = myderiv(x,y,xi)

%=======================================================================
%
%            function z = myderiv(x,y,xi)
%
%   MYDERIV Cubic Spline Derivative Interpolation
%   
%   YI = MYDERIV(X,Y,XI) uses cubic spline interpolation to fit the
%   data in X and Y, differentiates the spline and returns values of
%   the spline derivatives evaluated at the points in XI
%
%
%   See also SPLINE, PPVAL, MKPP, UNMKPP, SPINTGL
%
%   Copyright (c) 1996 by Prentice-Hall, Inc.
%
%   Hacked again by Demoz Gebre on 11/12/2002
%--------------------------------------------------------------------------

if nargin < 3
    error('Incorrect Number of Arguments in myderiv.m');
elseif(nargin == 3)
    pp = spline(x,y);
end

[br,co,npy,nco] = unmkpp(pp);   % take apart pp;

%  Section commented out on 11/12/2002 by DG.
%if (nco ==1 | pp(1)~=10)
%    error('Spline data does not have the correct PP form.');
%end

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










