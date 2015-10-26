%-----------------------------------------------------------------------
%
%                             genImuData2.m
%
%   This m-file generates error free IMU outputs that correspond to a
%   particular velocity, position and attitude history.  The imu outputs 
%   Unlike genImuData.m, this m-file is not self contained and requires 
%   that way points be defined in accordance with the m-file deftraj.m.
%   Other m-files called on are preptraj.m (trajectory preparation), 
%   getimu.m (get imu data), getvinc.m (accelerometer data), and
%   getainc.m (rate gyro data).  The sensor outputs are in units of 
%   rad/sec for gyros and meters per second/second for the 
%   accelerometers.  The generated IMU outputs are used to check the 
%   validity of INS algorithms.
%
%   Programmer:             Demoz Gebre-Egziabher
%   Last Modified:          November 12, 2002 
%
%------------------------------------------------------------------------  

clear all;
clc;
close all;

%------------ 1.0   Define some constants ------------%

d2r = pi/180;
r2d = 1/d2r;
ft2m = 0.3048;
KTS2ms = 0.5144;
ms2KTS = 1/KTS2ms;
savepath = 'D:\USERS\scratch\';   %'/home/gebre/inertial/m_files/simulated_data/'; %savepath = 'D:\USERS\student_research\shao\';

%-------- 2.0  Define skeletal time, velocity, position and attitude vectors ---------%

[t_in,Ts,spd_in,yaw_in,h_dot,lat_in,lon_in,alt_in,the_in,phi_in] = deftraj;

%-------- 3.0  Prepare a "dense" velocity, position and attitude history ------%

[t_out,att,vel,pos] = preptraj(t_in,Ts,spd_in,yaw_in,h_dot,lat_in,lon_in,alt_in,the_in);

%------- 4.0  Generate IMU Outputs ------%

drl = length(t_out);        % Data Record Length
imu = zeros(drl,7);         % Place Holder for DELTA Angle and Velocity outputs
ecef = zeros(drl,3);
H_body = zeros(drl,3);

mpos = mean(pos);
[H_nav,dipA,decA] = emagfield(mpos(1),mpos(2),mpos(3));
H_nav = H_nav*1e4;

psi = r2d*att(:,1);     the = r2d*att(:,2);     phi = r2d*att(:,3);
Vn = vel(:,1)/KTS2ms;   Ve = vel(:,2)/KTS2ms;   Vd = vel(:,3)/KTS2ms;
lat = r2d*pos(:,1);     lon = r2d*pos(:,2);     h = pos(:,3);

imu(:,1) = t_out;

wB = waitbar(0,'Wait While Generating IMU Outputs ...');

for k = 1:drl-1
    
    waitbar(k/drl,wB);                  %  Update Wait Bar
    
    v2 = vel(k+1,:)';            % Velocity Vector at time step k+1
    v1 = vel(k,:)';              % Velocity Vector at time step k
    
    e2 = att(k+1,:)';            % Euler Angles at time step k+1
    e1 = att(k,:)';              % Euler Angles at time step k
    
    imu(k,2:7) = getimu(v1,v2,e1,e2,pos(k,3),pos(k,1),Ts);
    
    Cn2b = eul2dcm(e1);
    ecef(k,:) = lla2ecef([pos(k,1:2) pos(k,3)])';
    H_body(k,:) = (Cn2b*H_nav)';
    
end

imu(drl,:) = imu(drl-1,:);
ecef(drl,:) = ecef(drl-1,:);
H_body(drl,:) = H_body(drl-1,:);

close(wB);                          %  Close Wait Bar

%------------ 4.0  Prepare Data for Saving and Plotting --------------%

t = imu(:,1);
p = imu(:,2)/Ts;
q = imu(:,3)/Ts; 
r = imu(:,4)/Ts;

fspx = imu(:,5)/Ts;
fspy = imu(:,6)/Ts;
fspz = imu(:,7)/Ts;


    %   ---------- 4.1  Save the Data ------------%
if(1)
    gps = [t  d2r*[psi the phi] KTS2ms*[Vn Ve Vd] ecef];
    imu_good = [t p q r fspx fspy fspz];
    H_good = H_body;
    dt = Ts;

    eval(['save ',savepath,...
           'uav_imu_data.mat pos att vel psi the phi Vn Ve Vd lat lon h ecef dt imu_good H_good H_nav dipA decA']);
    eval(['save ',savepath,'uav_gps_data.mat gps']);

end

    %   ---------- 4.2 Plot the Data --------------%

    %  -------- Figure (1):  Euler Angle and Velocity History -----%

figure(1)
subplot(321);
plot(t,psi,'r');grid;ylabel('\psi (deg)');title('Euler Angle History');
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







