%-----------------------------------------------------------------------
%
%                            twovect_ahrs.m
%
%   twovect_ahrs.m is a simulation of an Attitude Heading Reference
%   System (AHRS) mechanized using quaternions.  Aiding for the
%   AHRS is in the form of periodic vector measurements from a
%   magnetometer and accelerometer 
%
%   Programmers:     Demoz Gebre-Egziabher, 
%                    Gabriel H. Elkaim
%
%   Last Modified:  September 13, 1999
%
%------------------------------------------------------------------------  

clear all;
clc; 
close all;
more off;

llimit = 2400;         % lower limit to average gains
ulimit = 2701;         % upper limit to average gains

gains_fixed = 'OFF';
realData = 1;

%   Define some constants

d2r = pi/180;
r2d = 1/d2r;
ft2m = 0.3048;
KTS2ms = 0.5144;
g = glocal(d2r*37.5,0);

%------------1.0    Load the Processed Data --------------%
disp(' ');
disp('******************* TV-AHRS *******************');
disp(' ');
disp('Loading Data ...');
disp(' ');

cd old_data
load IMU.mat;
load IMU_c.mat;
load GPS_c.mat
cd ..

if (realData)
    disp('Replay Real Data...')
    cd old_data
    load realdata.mat;
    imu = TimeBase;
    cd ..
end


%-----------2.0   Define Variables  ------%

qTrue = zeros(length(imu),4);

eul = zeros(length(imu),3);
qhat = zeros(length(imu),4);
qe = zeros(length(imu),3);
Lstore = zeros(length(imu),18);

eulm = zeros(length(imu),3);
qhatm = zeros(length(imu),4);
qem = zeros(length(imu),3);
Lstorem = zeros(length(imu),9);

eula = zeros(length(imu),3);
qhata = zeros(length(imu),4);
qea = zeros(length(imu),3);
Lstorea = zeros(length(imu),9);

if (strcmp(gains_fixed,'OFF')),
    Lconst = zeros(3,6);
    Lconsta = zeros(3,3);
    Lconstm = zeros(3,3);
else
    load /home/gebre/inertial/m_files/simulated_data/TWOVEC_GAIN.mat ...
    Lconst Lconsta Lconstm;
end

eulT = zeros(length(imu),3);


%-----------3.0   Establish the Initial Conditions ------%

eul(1,:) = [0 0 0]*d2r;
qhat(1,:) = [1 0 0 0]; %eul2quat(eul(1,:))';

eulm(1,:) = [0 0 0]*d2r;
qhatm(1,:) = [1 0 0 0]; %eul2quat(eul(1,:))';

eula(1,:) = [0 0 0]*d2r;
qhata(1,:) = [1 0 0 0]; %eul2quat(eul(1,:))';

qTrue(1,:) = eul2quat(d2r*[psi(1);the(1);phi(1)])';

%-----------3.1   Define Filter Variables  ------%


P = 1*eye(3);
Pm = 1*eye(3);
Pa = 1*eye(3);

tau = 10;
F = (-1/tau)*eye(3);

rw = 10;
Gw = eye(3);
Rw = diag(rw*[1 1 1].^2);


Rv = 1*(nA^2)*diag([1 1 1 1 1 1]);
Rva = 1*(nA^2)*eye(3);
Rvm = 1*(nA^2)*eye(3);

%----------4.0   Begin the Navigation Solution -------%

disp(' ');
disp('Performing the Attitude Solution ...');
disp(' ');


mI = H_nav;
aIg = [0 0 -1]';

for k = 2:length(imu)
    
    Cd = disrw(F,Gw,dt,Rw);
    Phi = expm(dt*F);
    P = Phi*P*Phi' + Cd;
    Pm = Phi*Pm*Phi' + Cd;
    Pa = Phi*Pa*Phi' + Cd;
    
    qTrue(k,:)=eul2quat(d2r*[psi(k);the(k);phi(k)])';
    
    mB = H_meas(k,:)';

    if (realData)
        fB = [ax(k) ay(k) az(k)]';
    else
        fB = imu(k,5:7)'/norm(g)/dt;
    end

   qe_plus = Phi*qe(k-1,:)';
   qhat_plus = qmult([1;qe_plus],qhat(k-1,:)');
   mIhat = qtrans(qhat_plus,mB);		% transform mB into mI using q-hat
   fIhat = qtrans(qhat_plus,fB);		% transform aB into aI using q-hat

    if (realData)
        dt = gps(k,1) - gps(k-1,1);
    end
 
    gI = aIg;
    gIhat = fIhat - ((1/dt)*[gps(k,5:7) - gps(k-1,5:7)]/norm(g))';
   
    dmI = mI - mIhat;					    % form the error in measurements of m
    dgI = gI - gIhat;					    % form the error in measurements of a
    H = -2*[sk(mIhat);sk(gIhat)];	        % form the skew symetric
%    H = -2*[sk(mI);sk(gI)];	        % form the skew symetric  % Added on 10/9/2005 DGE
    
    L = P*H'*inv(H*P*H' + Rv);
    
    Lt = L';
    Lstore(k-1,:) = (Lt(:)');

    P = (eye(3) - L*H)*P;

    qe(k,:) = qe_plus' + (L*([dmI;dgI]-H*qe_plus))';   % calculate the error quaternion
    
    qhat(k,:) = qmult([1;qe(k,:)'],qhat_plus)';	    % rotate q-hat
    if (qhat(k,1)<0)
        qhat(k,:)=-qhat(k,:);
    end
    qhat(k,:) = qhat(k,:)/norm(qhat(k,:));				% renormalize
%    eul(k-1,:) = quat2eul(qhat(k-1,:)')';
    qqcomp = qcomp(qhat(k,:)');
    eul(k,:) = dcm2eul(quat2dcm(qqcomp)')';

    eulT(k-1,:) = quat2eul(qTrue(k-1,:)')';

end

%--------  4.1  Save the Results ------%

%save TWOVEC.mat
%save TWOVEC_GAIN.mat Lconst Lconsta Lconstm;
%save TWOVEC_GAIN.txt Lconst Lconsta Lconstm -ascii;

%----------5.0  Plot Results ----------%

t = (imu(:,1)-imu(1,1))/60;

clf;
figure(gcf)
subplot(311)
plot(t,r2d*eul(:,1),'g',t,psi,'r--');
     legend('Vector Matching','Truth')
     
grid on;
title(['Attitude (Deg). f_s = ',num2str(1/dt),' Hz.']);
ylabel('Yaw')

subplot(312)
plot(t,r2d*eul(:,2),'g',t,the,'r--');
     legend('Vector Matching','Truth');
ylabel('Pitch')
grid on;

subplot(313)
plot(t,r2d*eul(:,3),'g',t,phi,'r--');
     legend('Vector Matching','Truth');
ylabel('Roll');
xlabel('Time (min)');
grid on;



figure(gcf+1)
subplot(311)
plot(t,r2d*eul(:,1),'g',t,r2d*eulm(:,1),'b',t,r2d*eula(:,1),'c',...
     t,psi,'r--');
     legend('both','mag','accel','true');
     
grid on;
title(['Attitude (Deg). f_s = ',num2str(1/dt),' Hz.']);
ylabel('Yaw')

subplot(312)
plot(t,r2d*eul(:,2),'g',t,r2d*eulm(:,2),'b',t,r2d*eula(:,2),'c',...
     t,the,'r--');
     legend('both','mag','accel','true');
ylabel('Pitch')
grid on;


subplot(313)
plot(t,r2d*eul(:,3),'g',t,r2d*eulm(:,3),'b',t,r2d*eula(:,3),'c',...
     t,phi,'r--');
     legend('both','mag','accel','true');
ylabel('Roll');
xlabel('Time (min)');
grid on;

%===================================%

figure(gcf+1)
subplot(111);
title('Gains for Both Measurements');
Lt = L';
Lstore(k,:)=Lt(:)';
Ax = [0 0 0 0];

for k=1:18,
    subplot(3,6,k);
    plot(t,Lstore(:,k));
    grid;
    x1 = floor(k/6) + sign(mod(k,6));
    y1 = mod(k,6)+1 - sign(mod(k,6));
    ylabel(['L_{',int2str(x1),int2str(y1),'}']);
    
end

for k=13:18,
    subplot(3,6,k);
    xlabel('time (min)');
end

figure(gcf+1)
subplot(111);
title('Gains for Mag Only Measurements');
Lt = Lm';
Lstorem(k,:)=Lt(:)';

for k=1:9,
    subplot(3,3,k);
    plot(t,Lstorem(:,k));
    grid;
    x1 = floor(k/3) + sign(mod(k,3));
    y1 = mod(k,3)+1 - sign(mod(k,3));
    ylabel(['L_{',int2str(x1),int2str(y1),'}']);
    
end

for k=7:9,
    subplot(3,3,k);
    xlabel('time (min)');
end

figure(gcf+1)

subplot(111);
title('Gains for Accel Only Measurements');
Lt = La';
Lstorea(k,:)=Lt(:)';

for k=1:9,
    subplot(3,3,k);
    plot(t,Lstorea(:,k));
    grid;
    x1 = floor(k/3) + sign(mod(k,3));
    y1 = mod(k,3)+1 - sign(mod(k,3));
    ylabel(['L_{',int2str(x1),int2str(y1),'}']);
    
end

for k=7:9,
    subplot(3,3,k);
    xlabel('time (min)');
end

figure(gcf+1);
for k=1:4,
    subplot(2,2,k);
    plot(t,qTrue(:,k),'r',t,qhat(:,k),'g--',t,qhatm(:,k),'b',t,qhata(:,k),'c');
    grid on
    zoom on
end

figure(gcf+1);
subplot(311)
plot(t,r2d*eul(:,1),'g',t,r2d*eulm(:,1),'b',t,r2d*eula(:,1),'c',...
     t,r2d*eulT(:,1),'r--');
     legend('both','mag','accel','true');
     
grid on;
title(['Attitude (Deg). f_s = ',num2str(1/dt),' Hz.']);
ylabel('Yaw')

subplot(312)
plot(t,r2d*eul(:,2),'g',t,r2d*eulm(:,2),'b',t,r2d*eula(:,2),'c',...
     t,r2d*eulT(:,2),'r--');
     legend('both','mag','accel','true');
ylabel('Pitch')
grid on;

subplot(313)
plot(t,r2d*eul(:,3),'g',t,r2d*eulm(:,3),'b',t,r2d*eula(:,3),'c',...
     t,r2d*eulT(:,3),'r--');
     legend('both','mag','accel','true');
ylabel('Roll');
xlabel('Time (min)');
grid on;
    











