                         function genImuErr1(datafile,loadpath,savepath)
%-------------------------------------------------------------------------%
%
%                         function genImuErr1(datfile,loadpath,savepath)
%
%   This m-file takes as input error free IMU outputs and corrupts them
%   with error.  The errors that corrupt the measurments are:
%
%   (1)  Constant Bias
%   (2)  Wide-Band ("White") Noise
%   (3)  Correlated Noise
%   (4)  Scale Factor Errors
%
%   Any combinations of these errors can be applied to the IMU outputs.
%   Furthermore, one also selects which sensors get what kind of error.
%   That is, accelerometers and gyros don't have to have the same type of
%   errors.  Neither do each gyro have to have the same type of error.
%
%
%   Programmer:     Demoz Gebre-Egziabher
%   Created:        November 19,2001
%   Last Modified:  March 25, 2001
%
%------------------------------------------------------------------------ %

%==================================================================================%
% (a)                          Clear Up Work Space                                 %
%==================================================================================%

close all; clc;

%==================================================================================%
% (b)            Define Conversion Factors and Constants                           %
%==================================================================================%

d2r = pi/180;               %  Degrees to radians 
r2d = 1/d2r;                %  Radians to degrees
ft2m = 0.3048;              %  Feet to meters
KTS2ms = 0.5144;            %  Knots to meters/sec
ms2KTS = 1/KTS2ms;          %  Meters/sec to Knots
s2hr = 1/3600;              % Seconds to hours

omegaE = 7.292115e-5;       %  = 15.041 deg/hr.  Rotation Rate of Earth in Inertial Space
rE = 6378137;               %  Semi-major Axis of Earth (WGS-84)

mag_bln = 1e-3;             % Magnetometer base line noise in Gauss.  See note below.

%==================================================================================%
%      Note (November 7, 2002)                                                     %
%                                                                                  %
%      Except for the number associated with the wide band noise, all of the       %
%      magnetometer error model numbers are fictitious.  The wide band noise       %
%      is what I remember from the Honeywell HMC 2300 magnetometer triad.          %
%      The consumer grade INS will have a magnetometer wide band noise             %
%      corresponding to this number.  The other sensor grades will have            %
%      half of the noise of the previous grade. The time constant on the markov    %
%      bias is set to be equal to the accelerometer's markov bias time             %
%      constant.  Once again, this is purely arbitrary.                            %                                                                  %
%                                                                                  %
%==================================================================================%

cgo = 9.780373;             %  Constants for a simple gravity model (pp. 53 Titterton)
cg1 = 0.0052891;
cg2 = 0.0000059;

%=======================================================================================%
% (c)   Load IMU and GPS Data                                                           %
%                                                                                       %
%   (1) imu_good = (nx7) = [   t      p      q        r      fx      fy      fz   ]     %
%                          [ (sec) (rad/s) (rad/s) (rad/s) (m/s/s) (m/s/s) (m/s/s)]     % 
%                                                                                       %
%   (2) gps = (nx10) = [   t    yaw  theta  phi   Vn    Ve    Vd    X   Y   Z   ];      %
%                      [ (sec) (rad) (rad) (rad) (m/s) (m/s) (m/s) (m) (m) (m)];        %                                                                %
%=======================================================================================%

eval(['load ',loadpath,datafile]);

%==================================================================================%
% (d)   Determine the error model to be used by turning on/off appropriate         %
%       error model switches.  A switch value of "1" means that that error         %
%       will be applied to the sensor.  The notation used for the switches         %
%       defined as follows:                                                        %
%                                                                                  %
%       Kg = 3 X 3 Matrix of Gyro Error Switches                                   %
%       Ka = 3 X 3 Matrix of Accelerometer Swithces                                %
%       Km = 3 X 3 Matrix of Magnetometer Swithces                                 %
%                                                                                  %
%       Each row maps to the x, y or z body axis respectively                      %
%       Each column corrosponds to the type of error.  That is,                    %
%                                                                                  %
%       Column 1 = Wide-Band Error Switch for sensors                              %
%       Column 2 = Markov Error Switch for sensor                                  %
%       Column 3 = Null-Shift Error Switch for sensor                              %
%                                                                                  %
%       Graphically, the Kg, Ka or Km matrix looks like this:                      %
%                                                                                  %
%               Wide-Band Noise     Markov Bias    Null-Shift                      %
%       x-axis         #                 #             #                           %
%       y-axis         #                 #             #                           %
%       z-axis         #                 #             #                           %
%                                                                                  %
%==================================================================================%

%   Rate Gyro Error Matrix

Kg = [      0       0       5;...
            0       0       -5;...
            0       0       10];

%   Accelerometer Error Matrix

Ka = [      0       0       3;...
            0       0       2;...
            0       0       -1];
    
%   Magnetometer Error Matrix

Km = [      1       0       0;...
            1       0       0;...
            1       0       0];
    
%==================================================================================%
% (e)   Select INS Quality                                                         %
%                                                                                  %
%                                                                                  %
%     The variable INSQualFlag is used to set the quality of the INS in            % 
%     the simulation to one of the following options:                              %
%                                                                                  %
%       1. 'NAV' - Navigation Grade INS                                            %
%       2. 'TAC' - Tactical Grade INS                                              %
%       3. 'AUT' - Automotive Grade INS                                            %
%       4. 'CON' - Consumer Grade INS                                              %
%                                                                                  %
%      Note (November 7, 2002)                                                     %
%                                                                                  %
%      Except for the number associated with the wide band noise, all of the       %
%      magnetometer error model numbers are fictitious.  The wide band noise       %
%      is what I remember from the Honeywell HMC 2300 magnetometer triad.          %
%      The consumer grade INS will have a magnetometer wide band noise             %
%      corresponding to this number.  The other sensor grades will have            %
%      half of the noise of the previous grade. Once again, this is purely         %
%      arbitrary.                                                                  %
%==================================================================================%

%INSQualFlag = 'NAV';
%INSQualFlag = 'TAC';
INSQualFlag = 'CON';
%INSQualFlag = 'PERFECT';

%  Selet the appropriate INS model

if(strcmp(INSQualFlag,'NAV'))
     %  Navigation Grade Rate Gyro Error Parameters
     %  Obtained from Ph.D. thesis by Ping Ya Ko titled
     %  "GPS-Based Precision Approach and Landing", Stanford University 2000,pp.34
     
     tau_g = 3600;                    %  Time Constant on Gyro Markov Bias
     sigma_c_g = 0.003*d2r*s2hr;      %  Standard Deviation of Gyro Markov Bias
     sigma_w_g = 0.0008*d2r;          %  Standard Deviation of Gyro Wide Band Noise
     sigma_n_g = sigma_w_g;           %  Null Shift

     tau_f = 3600;                    %  Time Constant on Accelerometer Markov Bias
     sigma_c_f = (25e-6)*cgo;         %  Standard Deviation of Accelerometer Markov Bias
     sigma_w_f = (5e-6)*cgo;          %  Standard Deviation of Accelerometer Wide Band Noise
     sigma_n_f = sigma_w_f;           %  Null Shift
     
     tau_m = tau_f;                   %  Time Constant on Magnetometer Markov Bias
     sigma_c_m = mag_bln/1000;        %  Standard Deviation of Magnetometer Markov Bias
     sigma_w_m = mag_bln/1000;        %  Standard Deviation of Magnetometer Wide Band Noise
     sigma_n_m = sigma_w_m;           %  Null Shift
     
elseif(strcmp(INSQualFlag,'TAC'))
     %  Tactical Grade Rate Gyro Error Parameters (LN200 Numbers)
     tau_g = 100;                     %  Time constant on gyro bias
     sigma_c_g = 0.35*d2r*s2hr;       %  Standard Deviation of Gyro Markov Bias
     sigma_w_g = 0.0017*d2r;          %  Standard Deviation of Gyro Wide Band Noise
     sigma_n_g = sigma_w_g;           %  Null Shift 
     
     tau_f = 60;                      %  Time Constant on Accelerometer Markov Bias
     sigma_c_f = (50e-6)*cgo;         %  Standard Deviation of Accelerometer Markov Bias
     sigma_w_f = (50e-5)*cgo;         %  Standard Deviation of Accelerometer Wide Band Noise
     sigma_n_f = sigma_w_f;           %  Null Shift
     
     tau_m = tau_f;                   %  Time Constant on Magnetometer Markov Bias
     sigma_c_m = mag_bln/100;         %  Standard Deviation of Magnetometer Markov Bias
     sigma_w_m = mag_bln/100;         %  Standard Deviation of Magnetometer Wide Band Noise
     sigma_n_m = sigma_w_m;           %  Null Shift
     
 elseif(strcmp(INSQualFlag,'CON'))
     %  Automotive Grade Gyro Error Parameters
     tau_g = 300;                     %  Time constant on Gyro Bias
     sigma_c_g = 180*d2r*s2hr;        %  Standard Deviation of Gyro Markov Bias
     sigma_w_g = 0.05*d2r;            %  Standard Deviation of Gyro Wide Band Noise
     sigma_n_g = sigma_w_g;           %  Null Shift    
  
     tau_f = 100;                     %  Time Constant on Accelerometer Markov Bias
     sigma_c_f = (1.2e-3)*cgo;        %  Standard Deviation of Accelerometer Markov Bias
     sigma_w_f = (1.0e-3)*cgo;        %  Standard Deviation of Accelerometer Wide Band Noise
     sigma_n_f = sigma_w_f;           %  Null Shift
     
     tau_m = tau_f;                   %  Time Constant on Magnetometer Markov Bias
     sigma_c_m = mag_bln/10;          %  Standard Deviation of Magnetometer Markov Bias
     sigma_w_m = mag_bln/10;          %  Standard Deviation of Magnetometer Wide Band Noise
     sigma_n_m = sigma_w_m;           %  Null Shift
     
  elseif(strcmp(INSQualFlag,'PERFECT'))
     %  Perfect Sensor
     tau_g = 1/eps;                   %  Time constant on Gyro Bias
     sigma_c_g = 0;                   %  Standard Deviation of Gyro Markov Bias
     sigma_w_g = 0;                   %  Standard Deviation of Gyro Wide Band Noise
     sigma_n_g = 0;                   %  Null Shift  
     
     tau_f = 3600;                    %  Time Constant on Accelerometer Markov Bias
     sigma_c_f = 0*cgo;               %  Standard Deviation of Accelerometer Markov Bias
     sigma_w_f = 0*cgo;               %  Standard Deviation of Accelerometer Wide Band Noise
     sigma_n_f = sigma_w_f;           %  Null Shift
     
     tau_m = tau_f;                   %  Time Constant on Magnetometer Markov Bias
     sigma_c_m = mag_bln;             %  Standard Deviation of Magnetometer Markov Bias
     sigma_w_m = mag_bln;             %  Standard Deviation of Magnetometer Wide Band Noise
     sigma_n_m = sigma_w_m;           %  Null Shift
     
 end
 
%==================================================================================%
% (d)                       Generate Wide Band Errors                              %
%==================================================================================%

t = imu_good(:,1);
drl = length(t);

xg_w = sigma_w_g*randn(drl,3);
xf_w = sigma_w_f*randn(drl,3);
xm_w = sigma_w_m*randn(drl,3);

%==================================================================================%
% (e)                       Generate Markov Errors                                 %
%==================================================================================%

Ts = mean(diff(imu_good(:,1)));
Tf = imu_good(end,1);

%   Rate Gyro Markov Errors

a_gyro = -1/tau_g; ;b_gyro = 1;     c_gyro = 1;     d_gyro = 0;

Q = 2*sigma_c_g*sigma_c_g/tau_g;              %   Driving Noise White Power Spectral Density
Qd = disrw(a_gyro,b_gyro,Ts,Q);

SS_gyro = ss(a_gyro,b_gyro,c_gyro,d_gyro);
SS_gyro_dis = c2d(SS_gyro,Ts);
[ad,bd,cdd,dd] = ssdata(SS_gyro_dis);

sigmaU = sqrt(Qd);
ug = sigmaU*randn(length([0:Ts:Tf]),3);
xg_c = zeros(length(ug),3);
adg = ad*eye(3);

%   Accelerometer Markov Errors

a_accl = -1/tau_f; ;b_accl = 1;     c_accl = 1;     d_accl = 0;

Q = 2*sigma_c_f*sigma_c_f/tau_f;              %   Driving Noise White Power Spectral Density
Qd = disrw(a_accl,b_accl,Ts,Q);

SS_accl = ss(a_accl,b_accl,c_accl,d_accl);
SS_accl_dis = c2d(SS_accl,Ts);
[ad,bd,cdd,dd] = ssdata(SS_accl_dis);

sigmaU = sqrt(Qd);
uf = sigmaU*randn(length([0:Ts:Tf]),3);
xf_c = zeros(length(uf),3);
adf = ad*eye(3);

%   Magnetometer Markov Errors

a_mag = -1/tau_m; ;b_mag = 1;     c_mag = 1;     d_mag = 0;

Q = 2*sigma_c_m*sigma_c_m/tau_m;              %   Driving Noise White Power Spectral Density
Qd = disrw(a_mag,b_mag,Ts,Q);

SS_mag = ss(a_mag,b_mag,c_mag,d_mag);
SS_mag_dis = c2d(SS_mag,Ts);
[ad,bd,cdd,dd] = ssdata(SS_mag_dis);

sigmaU = sqrt(Qd);
um = sigmaU*randn(length([0:Ts:Tf]),3);
xm_c = zeros(length(uf),3);
adm = ad*eye(3);

for k=2:drl
    xg_c(k,:) = (adg*xg_c(k-1,:)' + ug(k-1,:)')';    
    xf_c(k,:) = (adf*xf_c(k-1,:)' + uf(k-1,:)')';
    xm_c(k,:) = (adm*xm_c(k-1,:)' + um(k-1,:)')';    
end


%==================================================================================%
% (f)                       Generate Null-Shift Errors                             %
%==================================================================================%

xg_n = sigma_n_g*ones(drl,3);
xf_n = sigma_n_f*ones(drl,3);
xm_n = sigma_n_m*ones(drl,3);

%==================================================================================%
% (g)         Combine All the Errors Using Switches in Kg and Ka                   %
%==================================================================================%

xAxisError_g = [xg_w(:,1)';xg_c(:,1)';xg_n(:,1)'];
yAxisError_g = [xg_w(:,2)';xg_c(:,2)';xg_n(:,2)'];
zAxisError_g = [xg_w(:,3)';xg_c(:,3)';xg_n(:,3)'];

xAxisError_f = [xf_w(:,1)';xf_c(:,1)';xf_n(:,1)'];
yAxisError_f = [xf_w(:,2)';xf_c(:,2)';xf_n(:,2)'];
zAxisError_f = [xf_w(:,3)';xf_c(:,3)';xf_n(:,3)'];

xAxisError_m = [xm_w(:,1)';xm_c(:,1)';xm_n(:,1)'];
yAxisError_m = [xm_w(:,2)';xm_c(:,2)';xm_n(:,2)'];
zAxisError_m = [xm_w(:,3)';xm_c(:,3)';xm_n(:,3)'];

sensorError = zeros(drl,9);

    %  Rate Gyro Errors
    
sensorError(:,1) = (Kg(1,:)*xAxisError_g)';
sensorError(:,2) = (Kg(2,:)*yAxisError_g)';
sensorError(:,3) = (Kg(3,:)*zAxisError_g)';

    %  Accelerometer Errors
    
sensorError(:,4) = (Ka(1,:)*xAxisError_f)';
sensorError(:,5) = (Ka(2,:)*yAxisError_f)';
sensorError(:,6) = (Ka(3,:)*zAxisError_f)';

    %  Magnetometer Errors
    
sensorError(:,7) = (Km(1,:)*xAxisError_m)';
sensorError(:,8) = (Km(2,:)*yAxisError_m)';
sensorError(:,9) = (Km(3,:)*zAxisError_m)';

%==================================================================================%
% (h)         Add Errors to IMU Output and Save Data to File                       %
%==================================================================================%

imu_corrupt(:,1) = imu_good(:,1);
imu_corrupt(:,2:7) = imu_good(:,2:7) + sensorError(:,1:6);
H_corrupt = H_good + sensorError(:,7:9);

eval(['save ',savepath,datafile,'.mat imu_corrupt H_corrupt sensorError -append']);
eval(['save ',savepath,datafile,'.mat Kg Ka INSQualFlag tau_f tau_g -append']);
eval(['save ',savepath,datafile,'.mat sigma_c_g sigma_w_g sigma_c_f sigma_w_f -append']);     

%==================================================================================%
% (j)         Plot the Output                                                      %
%==================================================================================%


figure(gcf)
subplot(321);
plot(t,r2d*imu_good(:,2),'r');
grid;ylabel('\omega_x (deg/s)');title('Error Free \omega')
subplot(322);
plot(t,r2d*imu_corrupt(:,2),'g');
grid;ylabel('\omega_x (deg/s)');title('Corrupted \omega')
subplot(323);
plot(t,r2d*imu_good(:,3),'r');grid;ylabel('\omega_y (deg/s)');
subplot(324);
plot(t,r2d*imu_corrupt(:,3),'g');grid;ylabel('\omega_y (deg/s)');
subplot(325);
plot(t,r2d*imu_good(:,4),'r');
grid;ylabel('\omega_z (deg/s)');xlabel('time (sec)');
subplot(326)
plot(t,r2d*imu_corrupt(:,4),'g');
grid;ylabel('\omega_z (deg/s)');xlabel('time (sec)');

figure(gcf+1)
subplot(321);
plot(t,imu_good(:,4),'r');
grid;ylabel('f_x (m/s/s)');title('Error Free f')
subplot(322);
plot(t,imu_corrupt(:,4),'g');
grid;ylabel('f_x (m/s/s)');title('Corrupted f')
subplot(323);
plot(t,imu_good(:,5),'r');grid;ylabel('f_y (m/s/s)');
subplot(324);
plot(t,imu_corrupt(:,5),'g');grid;ylabel('f_y (m/s/s)');
subplot(325);
plot(t,imu_good(:,6),'r');
grid;ylabel('f_z (m/s/s)');xlabel('time (sec)');
subplot(326)
plot(t,imu_corrupt(:,6),'g');
grid;ylabel('f_z (m/s/s)');xlabel('time (sec)');

figure(gcf+1)
subplot(321);
plot(t,r2d*gps(:,2),'g');hold on;
plot(t,yaw,'r-');
%keyboard;
plot(t,yaw,'r-');grid;ylabel('\psi (deg)');title('Euler Angle History');
subplot(323);
plot(t,r2d*gps(:,3),'g');hold on;
plot(t,the,'r');grid;ylabel('\theta (deg)');
subplot(325);
plot(t,r2d*gps(:,4),'g');hold on;
plot(t,phi,'r');grid;ylabel('\phi (deg)');xlabel('time (sec)');
subplot(322);
plot(t,gps(:,5)/KTS2ms,'g');hold on;
plot(t,Vn,'r');grid;ylabel('V_n (KTS)');title('Velocity History');
subplot(324);
plot(t,gps(:,6)/KTS2ms,'g');hold on;
plot(t,Ve,'r');grid;ylabel('V_e (KTS)');
subplot(326)
plot(t,gps(:,7)/KTS2ms,'g');hold on;
plot(t,Vd,'r');grid;ylabel('V_d (KTS)');xlabel('time (sec)');


figure(gcf+1)
subplot(321);
plot(t,lat,'r');grid;ylabel('Lat (deg)');title('Postion History (lat,lon alt)');
subplot(323);
plot(t,lon,'r');grid;ylabel('Lon (deg)');
subplot(325);
plot(t,-h,'r');grid;ylabel('Alt (m)');xlabel('time (sec)');
subplot(322);
plot(t,gps(:,8)/1e6,'g');hold on;
plot(t,ecef(:,1)/1e6,'r');grid;ylabel('x (m)');title('Position History (ECEF)');
subplot(324);
plot(t,gps(:,9)/1e6,'g');hold on;
plot(t,ecef(:,2)/1e6,'r');grid;ylabel('y (m)');
subplot(326)
plot(t,gps(:,10)/1e6,'g');hold on;
plot(t,ecef(:,3)/1e6,'r');grid;ylabel('z (m)');xlabel('time (sec)');


figure(6)
subplot(311)
plot(t,H_corrupt(:,1),'r');
grid;
ylabel('H_x (Gauss)');
title('Earth Magnetic Field Strength');
subplot(312)
plot(t,H_corrupt(:,2),'r');
grid;
ylabel('H_y (Gauss)');
subplot(313)
plot(t,H_corrupt(:,3),'r');
grid;
ylabel('H_z (Gauss)');
xlabel('time (sec)');

%*****************************************************************************

