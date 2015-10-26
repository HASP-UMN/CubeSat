             function genImuData1(T_end,f,datafile,savepath)
%-----------------------------------------------------------------------
%
%           function genImuData1(T_end,f,fileName,savepath)
%
%   This m-file generates error free IMU outputs that correspond to a
%   particular attitude and velocity history.  The imu outputs are in
%   units of rad/sec for gyros and meters per second/second for the 
%   accelerometers.  The generated IMU outputs are used to check the 
%   validity of INS algorithms.
%
%   The only difference between this m-script and genImuData.m is that
%   the length of simulation (T_end), the sampling rate (f), are inputs in
%   genImuData
%
%   Programmer:             Demoz Gebre-Egziabher
%   Previously Modified:    July 16, 1999
%   Last Modified:          February 20, 2003 
%
%------------------------------------------------------------------------  

clc;
close all;

%------------ 1.0   Define some constants ------------%

d2r = pi/180;
r2d = 1/d2r;
ft2m = 0.3048;
KTS2ms = 0.5144;
ms2KTS = 1/KTS2ms;

%------------ 1.1 Check Input Arguments ----------- %

if(nargin < 3)
    datafile = [];    
    savepath = [];
elseif(nargin < 4)
    savepath = [];
end

if (isempty(savepath))
    error('No Path Specified.');
elseif(isempty(datafile))
    error('No File Name Specified.');
end

%savepath = 'D:\USERS\scratch\';   %'/home/gebre/inertial/m_files/simulated_data/';

%------------ 2.0  Define time, euler angle and velocity --------------%

%===================================%
%   t = time vector;
%   T_end = end time (in minutes);
%   f = sampling frequency;
%   dt = sampling period = 1/f;
%===================================%

dt = 1/f;
t = [0:dt:60*T_end]';

%=================================================%
%   yaw = heading/yaw; yaw_m = max yaw angle (deg);
%   the = pitch;     the_m = max pitch angle (deg);
%   phi = roll       phi_m = max roll angle (deg);
%-------------------------------------------------%
%   f_yaw_1 = yaw frequency (Hz);
%   f_the_1 = pitch frequency (Hz);
%   f_phi_1 = roll frequency (Hz);
%-----------------------------------------------%
%   w_yaw_o = initial yaw phase (deg)
%   w_the_o = initlal pitch phase (deg)
%   w_phi_o = initial roll phase (deg)
%================================================%

disp(' ');
disp('Generating Euler Angle History')

%yaw_m = 30;             f_yaw_1 = 1.0e-3;     w_yaw_o = pi/4;
%the_m = 60;             f_the_1 = 5.0e-3;     w_the_o = pi/4;
%phi_m = 90;             f_phi_1 = 1.0e-3;     w_phi_o = pi/4;

yaw_m = 30;             f_yaw_1 = 1e-2;     w_yaw_o = 0;
the_m = 30;             f_the_1 = 1e-2;     w_the_o = pi/2;
phi_m = 90;             f_phi_1 = 1e-2;     w_phi_o = pi/4;

yaw = yaw_m*sin(2*pi*f_yaw_1*t + w_yaw_o);
the = the_m*sin(2*pi*f_the_1*t + w_the_o);
phi = phi_m*sin(2*pi*f_phi_1*t + w_phi_o);

%======================================================%
%   Vn = North Velocity (KTS);   Vn_m = max Vn (KTS);
%   Ve = East Velocity (KTS);    Ve_m = max Ve (KTS);
%   Vd = Down Velocity (KTS);    Vd_m = max Vd (KTS);
%------------------------------------------------------%
%   f_Vn_1 = Vn frequency (Hz);
%   f_Ve_1 = Ve frequency (Hz);
%   f_Vd_1 = Vd frequency (Hz);
%-----------------------------------------------%
%   w_Vn_o = initial Vn phase (KTS)
%   w_Ve_o = initlal Ve phase (KTS)
%   w_Vd_o = initial Vd phase (KTS)
%================================================%

disp(' ')
disp('Generating Velocity History');

Vn_m = 0;       f_Vn_1 = 1e-15;       w_Vn_o = pi/2;
Ve_m = 0;       f_Ve_1 = 1e-15;       w_Ve_o = pi/2;
Vd_m = 0;       f_Vd_1 = 1e-15;       w_Vd_o = 0;

Vn = Vn_m*sin(2*pi*f_Vn_1*t + w_Vn_o);
Ve = Ve_m*sin(2*pi*f_Ve_1*t + w_Ve_o);
Vd = Vd_m*sin(2*pi*f_Vd_1*t + w_Vd_o);

%------------ 3.0    Generate Position, fsp, and dA  Data --------------%

        %---- 3.1 Position Generation ----%

%=====================================================================%
%   lat = Lattitude (deg);      lat_o = Initial Latitude (deg);
%   lon = Longitude (deg);      lon_o = Initial Longitude (deg);
%   h = -Altitude (m);          h_o = Initial -Altitude (m);
%
%   ecef = position in ECEF coordinates (m)
%
%   Vn_int = Integral of Vn (NM)
%   Ve_int = Integral of Ve (NM)
%   Vd_int = Integral of Vd (NM)
%
%   Rns = Earth's Radius of Curvature in the North-South Direction (m)
%   Rew = Earth's Radius of Curvature in the East-West  Direction (m)
%=====================================================================%

disp(' ')
disp('Generating Position History');

lat_o = 0*(44.981562);
lon_o = 0*(-93.23928);
h_o = 0;

lat = zeros(length(t),1);       lat(1) = lat_o;
lon = zeros(length(t),1);       lon(1) = lon_o;
h = zeros(length(t),1);         h(1) = h_o;
ecef = zeros(length(t),3);      ecef(1,:) = lla2ecef([d2r*[lat_o lon_o] h_o])';

Vn_int_o = -(Vn_m/(2*pi*f_Vn_1))*(cos(2*pi*f_Vn_1*t(1) + w_Vn_o));
Ve_int_o = -(Ve_m/(2*pi*f_Ve_1))*(cos(2*pi*f_Ve_1*t(1) + w_Ve_o));
Vd_int_o = -(Vd_m/(2*pi*f_Vd_1))*(cos(2*pi*f_Vd_1*t(1) + w_Vd_o));

Vn_int = -(Vn_m/(2*pi*f_Vn_1))*(cos(2*pi*f_Vn_1*t + w_Vn_o)) - Vn_int_o; 
Ve_int = -(Ve_m/(2*pi*f_Ve_1))*(cos(2*pi*f_Ve_1*t + w_Ve_o)) - Ve_int_o;
Vd_int = -(Vd_m/(2*pi*f_Vd_1))*(cos(2*pi*f_Vd_1*t + w_Vd_o)) - Vd_int_o;

for k = 2:length(t)

    [Rew,Rns] = earthrad(d2r*lat(k-1));

    lat(k) = KTS2ms*r2d*Vn_int(k)/(Rns-h(k-1)) + lat_o;
    lon(k) = KTS2ms*r2d*Ve_int(k)/(Rew-h(k-1)) + lon_o;
    h(k) = KTS2ms*Vd_int(k) + h_o;

    ecef(k,:) = lla2ecef([d2r*[lat(k) lon(k)] h(k)])';

end

        %---- 3.2 Angular Rate and Specific Force Generation ----%

%=====================================================================%
%   pe = body x rotation rate minus transport and earth rates (deg/s);
%   qe = body y rotation rate minus transport and earth rates (deg/s);
%   re = body z rotation rate minus transport and earth rates (deg/s);
%----------------------------------------------------------------------%
%   p = body x rotation rate sensed my the IMU (deg/s);
%   q = body y rotation rate sensed my the IMU (deg/s);
%   r = body z rotation rate sensed my the IMU (deg/s);
%-----------------------------------------------------------------------%
%   yaw_dot = yaw rate (deg/sec);
%   the_dot = pitch rate (deg/sec);
%   phi_dot = roll rate (deg/sec);
%-----------------------------------------------------------------------%
%   ct = cosine of pitch angle
%   st = sine of pitch angle
%   cp = cosine of roll angle
%   sp = sine of roll angle
%-----------------------------------------------------------------------%
%   imu = matrix of time and IMU outputs [t delta_theta delta_v];
%=======================================================================%

disp(' ');
disp('Generating Angular Velocity & Linear Acceleration History');

yaw_dot = (yaw_m*(2*pi*f_yaw_1))*(cos(2*pi*f_yaw_1*t + w_yaw_o));
the_dot = (the_m*(2*pi*f_the_1))*(cos(2*pi*f_the_1*t + w_the_o));
phi_dot = (phi_m*(2*pi*f_phi_1))*(cos(2*pi*f_phi_1*t + w_phi_o));

ct = cos(the*d2r);
st = sin(the*d2r);
cp = cos(phi*d2r);
sp = sin(phi*d2r);

pe = phi_dot + - st.*yaw_dot;
qe = cp.*the_dot + (ct.*sp).*yaw_dot;
re = -sp.*the_dot + (ct.*cp).*yaw_dot;

Vn_dot = (Vn_m*(2*pi*f_Vn_1))*(cos(2*pi*f_Vn_1*t + w_Vn_o)); 
Ve_dot = (Ve_m*(2*pi*f_Ve_1))*(cos(2*pi*f_Ve_1*t + w_Ve_o));
Vd_dot = (Vd_m*(2*pi*f_Vd_1))*(cos(2*pi*f_Vd_1*t + w_Vd_o));

imu = zeros(length(t),7);
H_body = zeros(length(t),3);

%H_nav = [0.23199 0.06361 0.43497]';     % Magnetic Field Vector in SF Bay
[H_nav,dipA,decA] = emagfield(d2r*mean(lat),d2r*mean(lon),mean(h));
H_nav = H_nav*1e4;

for k = 1:length(t)

    l = d2r*lat(k);
    g = glocal(l,h(k));
    eul = d2r*[yaw(k);the(k);phi(k)];
    v = KTS2ms*[Vn(k);Ve(k);Vd(k)];
    v_dot = KTS2ms*[Vn_dot(k);Ve_dot(k);Vd_dot(k)];
    rho = navrate(v,h(k),l);
%    cor = coriolis(rho,v,l);
    cor = coriolis(v,rho,l);
    erate = earthrate(l);
    Cn2b = eul2dcm(eul);

    imu(k,1) = t(k);
    imu(k,2:4) = (d2r*[pe(k);qe(k);re(k)] + Cn2b*(rho + erate))';
    imu(k,5:7) = (Cn2b*(v_dot - g + cor))';
    H_body(k,:) = (Cn2b*H_nav)';
    
end

%------------ 4.0  Prepare Data for Saving and Plotting --------------%

p = r2d*imu(:,2);
q = r2d*imu(:,3); 
r = r2d*imu(:,4);

fspx = imu(:,5);
fspy = imu(:,6);
fspz = imu(:,7);

pos = [d2r*lat d2r*lon h];
vel = KTS2ms*[Vn Ve Vd];
att = d2r*[yaw the phi];


    %   ---------- 4.1  Save the Data ------------%
if(1)
    gps = [t  d2r*[yaw the phi] KTS2ms*[Vn Ve Vd] ecef];
    imu_good = imu;
    H_good = H_body;

    datafile = [datafile,'.mat'];
    eval(['save ',savepath,datafile,' ',...
           'pos att vel yaw the phi Vn Ve Vd lat lon h ecef dt imu_good H_good H_nav dipA decA']);
    eval(['save ',savepath,datafile,' gps','  -append ']);

end

    %   ---------- 4.2 Plot the Data --------------%

    %  -------- Figure (1):  Euler Angle and Velocity History -----%

figure(1)
subplot(321);
plot(t,yaw,'r');grid;ylabel('\psi (deg)');title('Euler Angle History');
subplot(323);
plot(t,the,'r');grid;ylabel('\theta (deg)');
subplot(325);
plot(t,phi,'r');grid;ylabel('\phi (deg)');xlabel('time (sec)');
subplot(322);
plot(t,Vn,'r');grid;ylabel('V_n (KTS)');title('Velocity History');
subplot(324);
plot(t,Ve,'r');grid;ylabel('V_e (KTS)');
subplot(326)
plot(t,Vd,'r');grid;ylabel('V_d (KTS)');xlabel('time (sec)');

    %  -------- Figure (2):  Position History  -----%

figure(2)
subplot(321);
plot(t,lat,'r');grid;ylabel('Lat (deg)');title('Postion History (lat,lon alt)');
subplot(323);
plot(t,lon,'r');grid;ylabel('Lon (deg)');
subplot(325);
plot(t,-h,'r');grid;ylabel('Alt (m)');xlabel('time (sec)');
subplot(322);
plot(t,ecef(:,1)/1e6,'r');grid;ylabel('x (m)');title('Position History (ECEF)');
subplot(324);
plot(t,ecef(:,2)/1e6,'r');grid;ylabel('y (m)');
subplot(326)
plot(t,ecef(:,3)/1e6,'r');grid;ylabel('z (m)');xlabel('time (sec)');

    %  -------- Figure (3):  Sensor Output History  -----%

figure(3)
subplot(321);
plot(t,p,'r');grid;ylabel('\omega_x (deg/s)');title('Angular Rate History')
subplot(323);
plot(t,q,'r');grid;ylabel('\omega_y (deg/s)');
subplot(325);
plot(t,r,'r');grid;ylabel('\omega_z (deg/s)');xlabel('time (sec)');
subplot(322);
plot(t,fspx,'r');grid;ylabel('f_x (m/s/s)');title('Acceleration History')
subplot(324);
plot(t,fspy,'r');grid;ylabel('f_y (m/s/s)');
subplot(326)
plot(t,fspz,'r');grid;ylabel('f_z (m/s/s)');xlabel('time (sec)');


    %  -------- Figure (4):  Magnetometer Output History  -----%

figure(4)
subplot(311)
plot(t,H_body(:,1),'r');
grid;
ylabel('H_x (Gauss)');
title('Earth Magnetic Field Strength');
subplot(312)
plot(t,H_body(:,2),'r');
grid;
ylabel('H_y (Gauss)');
subplot(313)
plot(t,H_body(:,3),'r');
grid;
ylabel('H_z (Gauss)');
xlabel('time (sec)');







