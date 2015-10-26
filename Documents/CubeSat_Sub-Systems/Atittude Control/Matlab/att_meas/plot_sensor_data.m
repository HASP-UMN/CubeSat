function plot_sensor_data(ftdate);



close all;
clc

loadpath = '/data/sba_data/ft';

eval(['load ',loadpath,ftdate,'99/sensor_data.mat']);
%load sensor_data.mat

figure(1)
plot(DMU_Out(:,1),DMU_Out(:,2),'r-');
hold on;
plot(INS_Omega_Acc(:,1),INS_Omega_Acc(:,2),'b-');
grid;
legend('X-Bow DMU','INS');
xlabel('GPS Time (sec)');
ylabel('\omega_x (deg/sec)');
title('Body Roll Axis Rate Comparison');

figure(2);
plot(DMU_Out(:,1),DMU_Out(:,3),'r-');
hold on;
plot(INS_Omega_Acc(:,1),INS_Omega_Acc(:,3),'b-');
grid;
legend('X-Bow DMU','INS');
xlabel('GPS Time (sec)');
ylabel('\omega_y (deg/sec)');
title('Body Pitch Axis Rate Comparison');

figure(3);
plot(DMU_Out(:,1),DMU_Out(:,4),'r-');
hold on;
plot(INS_Omega_Acc(:,1),INS_Omega_Acc(:,4),'b-');
grid;
legend('X-Bow DMU','INS');
xlabel('GPS Time (sec)');
ylabel('\omega_z (deg/sec)');
title('Body Yaw Axis Rate Comparison');

figure(4);
plot(DMU_Out(:,1),DMU_Out(:,5),'r-');
hold on;
plot(INS_Omega_Acc(:,1),INS_Omega_Acc(:,5),'b-');
grid;
legend('X-Bow DMU','INS');
xlabel('GPS Time (sec)');
ylabel('a_x (g)');
title('Body Longitudinal Axis Acceleration Comparison');

figure(5);
plot(DMU_Out(:,1),DMU_Out(:,6),'r-');
hold on;
plot(INS_Omega_Acc(:,1),INS_Omega_Acc(:,6),'b-');
grid;
legend('X-Bow DMU','INS');
xlabel('GPS Time (sec)');
ylabel('a_y (g)');
title('Body Lateral Axis Acceleration Comparison');

figure(6);
plot(DMU_Out(:,1),DMU_Out(:,7),'r-');
hold on;
plot(INS_Omega_Acc(:,1),INS_Omega_Acc(:,7),'b-');
grid;
legend('X-Bow DMU','INS');
xlabel('GPS Time (sec)');
ylabel('a_z (g)');
title('Body Normal Axis Acceleration Comparison');


figure(7);
plot(DMU_Out(:,1),DMU_Out(:,8),'r-');
hold on;
plot(INS_Euler_Vel_Pos(:,1),INS_Euler_Vel_Pos(:,4),'b-');
grid;
legend('X-Bow DMU','INS');
xlabel('GPS Time (sec)');
ylabel('\phi (deg)');
title('Roll Angle');

figure(8);
plot(DMU_Out(:,1),DMU_Out(:,9),'r-');
hold on;
plot(INS_Euler_Vel_Pos(:,1),INS_Euler_Vel_Pos(:,3),'b-');
grid;
legend('X-Bow DMU','INS');
xlabel('GPS Time (sec)');
ylabel('\theta (deg)');
title('Pitch Angle');




