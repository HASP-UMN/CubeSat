%-----------------------------------------------------------------------------------------
%
%                            eul_ahrs_paper_4.m
%
%   Same as the other eul_ahrs_paper_x files but compares gain
%   maping from level to moving.
%
%   Programmer:                     Demoz Gebre-Egziabher
%   Previously Modified:            August 18, 1999
%   Last Modified:                  May 7, 2003          
%
%-------------------------------------------------------------------------------------------------  

clear all;
clc;
close all;

%   Define some constants

d2r = pi/180;
r2d = 1/d2r;
ft2m = 0.3048;
KTS2ms = 0.5144;

%------------1.0    Load the Processed Data --------------%

%load ahrs_level.mat;
%load ahrs_sinusoid.mat;
%load sinusoid_90_fast.mat; FAST = 1; FILE_FLAG = -22;
load sinusoid_90_slow.mat; FAST = 0;FILE_FLAG = -22;
%load sinusoid_flat_baseline.mat;
%load all_1Hz.mat;
%load all_centi_Hz.mat;
%load all_mili_Hz.mat;
%load all_centi_Hz_long.mat;
%load moderate_pitch.mat;

%load pitch_00_centi.mat;
%load pitch_15_centi.mat;
%load pitch_30_centi.mat;

%load pitch_00_centi_2.mat;
%load pitch_15_centi_2.mat;
%load pitch_30_centi_2.mat;

%load test_eulsim.mat;
%load pitch_eulsim.mat;   FILE_FLAG = 2;   load pitch_eulsim_att.mat
%load nopitch_eulsim.mat;  FILE_FLAG = 1; load nopitch_eulsim_att.mat;

%load eight_eulsim.mat;   FILE_FLAG = 2;   load eight_eulsim_att.mat
%load spiral_eulsim.mat;  FILE_FLAG = 3;  load spiral_eulsim_att.mat;

%-----------2.0   Define Variables  ------%

imu = imu_good;
t = imu(:,1);
drl = length(t);

eul = zeros(drl,3);

p_bias = zeros(drl,1);
q_bias = zeros(drl,1);
r_bias = zeros(drl,1);

%  Define Place Holder for the Kalman gain histories.

L11 = zeros(drl,1);     L12 = zeros(drl,1);     L13 = zeros(drl,1);
L21 = zeros(drl,1);     L22 = zeros(drl,1);     L23 = zeros(drl,1);
L31 = zeros(drl,1);     L32 = zeros(drl,1);     L33 = zeros(drl,1);
L41 = zeros(drl,1);     L42 = zeros(drl,1);     L43 = zeros(drl,1);
L51 = zeros(drl,1);     L52 = zeros(drl,1);     L53 = zeros(drl,1);
L61 = zeros(drl,1);     L62 = zeros(drl,1);     L63 = zeros(drl,1);

%  Define Place Holder for the SCHEDULED Kalman gain histories.

if(1)
    load L_euler_level.mat;
end

L11c = zeros(drl,1);     L12c = zeros(drl,1);     L13c = zeros(drl,1);
L21c = zeros(drl,1);     L22c = zeros(drl,1);     L23c = zeros(drl,1);
L31c = zeros(drl,1);     L32c = zeros(drl,1);     L33c = zeros(drl,1);
L41c = zeros(drl,1);     L42c = zeros(drl,1);     L43c = zeros(drl,1);
L51c = zeros(drl,1);     L52c = zeros(drl,1);     L53c = zeros(drl,1);
L61c = zeros(drl,1);     L62c = zeros(drl,1);     L63c = zeros(drl,1);

insQual = 'CON';        % INS Quality.  Options are
                        % 'NAV' = Navigation Grade (e.g., LN100, YG1851).
                        % 'TAC' = Tactial Grade    (e.g., LN200, HG1700).
                        % 'AUT' = Automotive Grade (e.g., DMU-F0G, DMU-AHRS, KVH)
                        % 'CON' = Consumer Grade (e.g., DMU-6X, Systron Donner, etc.,)
                        % see m-file getinsmodel.m for mode details
 
 [gyro,accel] = getinsmodel(insQual);
 
 tau_w = gyro(1);           % Markov Time Constant
 sigma_wc = gyro(2);         % Markov Bias
 sigma_wn = gyro(3);         % Wide Band Noise
 sigma_ns = gyro(4);        % Null Shift-

%-----------3.0   Establish the Initial Conditions ------%

eul(1,:) = [yaw(1) the(1) phi(1)]*d2r;

%-----------3.1   Define Filter Variables  ------%

loop_count = 0;
FILTER = 'ON';%'OFF';%
update_limit = round(1/dt);

P = diag([0.25*d2r*ones(1,3) sigma_wc*ones(1,3)].^2);%eye(6);
H = [eye(3) zeros(3,3)];
F = zeros(6,6);

Rwpsd = eye(6);    % Just a place holder
 
Rwpsd(1,1) = 1*sigma_wn^2;    % White Noise --> Leads to Angle Randowm Walk
Rwpsd(2,2) = 1*sigma_wn^2;
Rwpsd(3,3) = 1*sigma_wn^2;

Rwpsd(4,4) = 2*sigma_wc^2/tau_w;     % Colord Noise --> Gyro Makrov Bias
Rwpsd(5,5) = 2*sigma_wc^2/tau_w;
Rwpsd(6,6) = 2*sigma_wc^2/tau_w;

Rv = eye(3)*(0.25*d2r)^2;                       % Measurement Noise Matrix

Fe2e = zeros(3,3);
Fw2e = zeros(3,3);
Fe2w = zeros(3,3);
Fw2w = -eye(3)/tau_w;

Gn2e = zeros(3,3);   % "n" = wide band noise; "c" = colored noise.
Gc2e = zeros(3,3);
Gn2w = zeros(3,3);
Gc2w = eye(3);

aa = 1;
bb = 1;

%----------4.0   Begin the Attitude Solution -------%

wB = waitbar(0,'Propagating Attitude Solution and Covariance ...');

for k = 2:drl
    
    
    waitbar(k/drl,wB);

    loop_count = loop_count + 1;
    
    p = imu(k-1,2);
    q = imu(k-1,3);
    r = imu(k-1,4);

    p_bias(k,1) = p_bias(k-1,1);
    q_bias(k,1) = q_bias(k-1,1);
    r_bias(k,1) = r_bias(k-1,1);
    
    if(0)
        p_use = imu_good(k-1,2); %imu_corrupt(k-1,2) + p_bias(k,1);%
        q_use = imu_good(k-1,3); %imu_corrupt(k-1,3) + q_bias(k,1);%
        r_use = imu_good(k-1,4); %imu_corrupt(k-1,4) + r_bias(k,1);%
    else
        p_use = imu_corrupt(k-1,2) + p_bias(k,1);%
        q_use = imu_corrupt(k-1,3) + q_bias(k,1);%
        r_use = imu_corrupt(k-1,4) + r_bias(k,1);%
    end
    
    if(1)
        p = p_use;
        q = q_use;
        r = r_use;
    end
    
    
     
    if(1)
        st = sin(eul(k-1,2));
        ct = cos(eul(k-1,2));
        sp = sin(eul(k-1,3));
        cp = cos(eul(k-1,3));
    else
        st = sin(d2r*the(k-1));
        ct = cos(d2r*the(k-1));
        sp = sin(d2r*phi(k-1));
        cp = cos(d2r*phi(k-1));
    end
     
     % ===== Fe2e:  Euler Angle Error to Euler Angle Error Block ==== %
     
    Fe2e(1,2) = -(st/ct^2)*(q*sp + r*cp);
    Fe2e(1,3) = (q*cp - r*sp)/ct;
    Fe2e(2,3) = -(q*sp + r*cp);
    Fe2e(3,2) = (q*sp + r*cp)/ct^2;
    Fe2e(3,3) = (st/ct)*(q*cp - r*sp);
     
     % ===== Fw2e:  Gryo Bias to Euler Angle Error Block ==== %
     
    Fw2e(1,2) = sp/ct;
    Fw2e(1,3) = cp/ct;
    Fw2e(2,2) = cp;
    Fw2e(2,3) = -sp;
    Fw2e(3,1) = 1;
    Fw2e(3,2) = sp*st/ct;
    Fw2e(3,3) = cp*st/ct;
     
     % ===== Gn2e:  Gryo wide band noise to Euler Angle Error Block ==== %
     
    Gn2e = Fw2e;
     
     % ===== Fw2e:  Assemble Dynamics Matrix ==== %
     
    F = [Fe2e    Fw2e;...
          Fe2w    Fw2w ];        % Dynamic Matirx at t = k
      
    G = [ aa*Gn2e   Gc2e;...
           Gn2w   bb*Gc2w];
  
    PHI = expm(dt*F);                          % Discrete Equivalent of F
    GQG = disrw(F,G,dt,Rwpsd);                 % Discrete Equivalent of G*Q*G'
 
    P = PHI*P*PHI' + GQG;
    
     % =====  Propagare the actual Euler Angles  ==== %
     
     
     sp_use = sin(eul(k-1,3));
     cp_use = cos(eul(k-1,3));
     st_use = sin(eul(k-1,2));
     ct_use = cos(eul(k-1,2));
     
     yaw_dot = (sp_use/ct_use)*q_use + (cp_use/ct_use)*r_use;
     pitch_dot = cp*q_use - sp_use*r_use;
     roll_dot = p_use + (sp_use*st_use/ct_use)*q_use + (cp_use*st_use/ct_use)*r_use;
     
     eul(k,:) = eul(k-1,:) + dt*[yaw_dot pitch_dot roll_dot];
     if(eul(k,1) > pi)
         eul(k,1) = eul(k,1) - 2*pi;
     elseif(eul(k,1) < -pi)
         eul(k,1) = eul(k,1) + 2*pi;
     end
     
     
    if (loop_count > update_limit & strcmp(FILTER,'ON'))

        L = P*H'*inv(H*P*H' + Rv);
        P = (eye(6) - L*H)*P;  
        
        if(FILE_FLAG == 1 | FILE_FLAG == 2 | FILE_FLAG == 3)
            att_innov = att_corrupt(k,:) - eul(k,:);
            if(att_innov(1) > pi)
                att_innov(1) = att_innov(1) - 2*pi;
            elseif(att_innov(1) < -pi)
                att_innov(1) = att_innov(1) + 2*pi;
            end
            yaw_innov(k) = att_innov(1);
            state_update = L*(att_innov)';
        else
            att_corrupt(k,:) = (att(k,:)+ 0.25*d2r*randn(1,3));
            state_update = L*(att_corrupt(k,:) - eul(k,:))';
        end

        eul(k,:) = eul(k,:) + state_update(1:3,:)';
        p_bias(k,:) = p_bias(k,:) + state_update(4,:);
        q_bias(k,:) = q_bias(k,:) + state_update(5,:);
        r_bias(k,:) = r_bias(k,:) + state_update(6,:);
        
        %  Store the Kalman Gains
        
        L11(k,1) = L(1,1);   L12(k,1) = L(1,2);   L13(k,1) = L(1,3);
        L21(k,1) = L(2,1);   L22(k,1) = L(2,2);   L23(k,1) = L(2,3);
        L31(k,1) = L(3,1);   L32(k,1) = L(3,2);   L33(k,1) = L(3,3);
        L41(k,1) = L(4,1);   L42(k,1) = L(4,2);   L43(k,1) = L(4,3);
        L51(k,1) = L(5,1);   L52(k,1) = L(5,2);   L53(k,1) = L(5,3);
        L61(k,1) = L(6,1);   L62(k,1) = L(6,2);   L63(k,1) = L(6,3);
        
        %  Compute and store gains computed from the level scenario.
        
        Ce2b = inv(Fw2e);
        Lsub = L_eul(4:6,:)*[0 0 1;0 1 0;1 0 0]*Ce2b;
        Lc = [L_eul(1:3,:);Lsub];
        
        L11c(k,1) = Lc(1,1);   L12c(k,1) = Lc(1,2);   L13c(k,1) = Lc(1,3);
        L21c(k,1) = Lc(2,1);   L22c(k,1) = Lc(2,2);   L23c(k,1) = Lc(2,3);
        L31c(k,1) = Lc(3,1);   L32c(k,1) = Lc(3,2);   L33c(k,1) = Lc(3,3);
        L41c(k,1) = Lc(4,1);   L42c(k,1) = Lc(4,2);   L43c(k,1) = Lc(4,3);
        L51c(k,1) = Lc(5,1);   L52c(k,1) = Lc(5,2);   L53c(k,1) = Lc(5,3);
        L61c(k,1) = Lc(6,1);   L62c(k,1) = Lc(6,2);   L63c(k,1) = Lc(6,3);
        
        
        
    end

     Pyaw(k,1) = r2d*sqrt(P(1,1));
     Ppitch(k,1) = r2d*sqrt(P(2,2));
     Proll(k,1) = r2d*sqrt(P(3,3));
     Pp(k,1) = r2d*sqrt(P(4,4));
     Pq(k,1) = r2d*sqrt(P(5,5));
     Pr(k,1) = r2d*sqrt(P(6,6));

end

close(wB)

%eul(:,1) = unwrapyaw(eul(:,1));
p_bias_r = p_bias;
q_bias_r = q_bias;
r_bias_r = r_bias;

if(0)
    save eul_gain_his.mat t L11 L12 L13 L21 L22 L23 L31 L32 L33 L41 L42 L43 L51 L52 L53 L61 L62 L63;
    save eul_gain_his.mat yaw the phi -append
end

if(1)
    eul_bl = eul;           % Euler Angle Base line.
    if(FILE_FLAG == 1)
        save eul_eulsim_np.mat t L11 L12 L13 L21 L22 L23 L31 L32 L33 L41 L42 L43 L51 L52 L53 L61 L62 L63 ;
        save eul_eulsim_np.mat Pyaw Ppitch Proll Pp Pq Pr -append;
        save eul_eulsim_np.mat eul_bl yaw the phi p_bias q_bias r_bias -append
    elseif(FILE_FLAG == 2)
        save eul_eulsim_f.mat t L11 L12 L13 L21 L22 L23 L31 L32 L33 L41 L42 L43 L51 L52 L53 L61 L62 L63 ;
        save eul_eulsim_f.mat Pyaw Ppitch Proll Pp Pq Pr -append; 
        save eul_eulsim_f.mat eul_bl yaw the phi p_bias_r q_bias_r r_bias_r -append
    elseif(FILE_FLAG == 3)
        save eul_eulsim_s.mat t L11 L12 L13 L21 L22 L23 L31 L32 L33 L41 L42 L43 L51 L52 L53 L61 L62 L63 ;
        save eul_eulsim_s.mat Pyaw Ppitch Proll Pp Pq Pr -append; 
        save eul_eulsim_s.mat eul_bl yaw the phi p_bias_r q_bias_r r_bias_r -append
    end
end


%----------5.0  Plot Results ----------%


figure(1)
subplot(321)
plot(t/60,r2d*eul(:,1),'g');
hold on;
plot(t/60,yaw,'r');
plot(t/60,r2d*att_corrupt(:,1),'b');
grid on;
legend('Computed','Truth');
title(['Attitude (Deg). f_s = ',num2str(1/dt),' Hz.']);
ylabel('Yaw')

subplot(323)
plot(t/60,r2d*eul(:,2),'g');
ylabel('Pitch')
hold on;
plot(t/60,the,'r');
grid on;

subplot(325)
plot(t/60,r2d*eul(:,3),'g');
ylabel('Roll');
hold on;
plot(t/60,phi,'r');
xlabel('Time (min)');
grid on;

subplot(322)
plot(t/60,-r2d*p_bias,'g');grid;ylabel('\delta_p');hold on;
plot(t/60,r2d*sensorError(:,1),'r');grid on;
title('Estimated Gyro Biases (deg/sec)');
subplot(324)
plot(t/60,-r2d*q_bias,'g');grid;ylabel('\delta_q');hold on;
plot(t/60,r2d*sensorError(:,2),'r');grid on;
subplot(326)
plot(t/60,-r2d*r_bias,'g');grid;ylabel('\delta_r');hold on;
plot(t/60,r2d*sensorError(:,3),'r');grid on;
xlabel('Time (min)');

% Figure (2) shows the yaw gains

figure(2)
h1 = plot(t/60,L11,'r-');hold on;grid on;
h2 = plot(t/60,L12,'b--');
h3 = plot(t/60,L13,'g-.');
h_len = legend('L11','L12','L13');
hx = xlabel('Time (min)');hy = ylabel('Yaw Gains');
ht = title('Yaw Channel Gains.');

%  Figure (3)  shows the pitch gains

figure(3)
h1 = plot(t/60,L21,'r');hold on;grid on;
h2 = plot(t/60,L22,'b');
h3 = plot(t/60,L23,'g');
h_len = legend('L21','L22','L23');
hx = xlabel('Time (min)');hy = ylabel('Pitch Gains');
ht = title('Pitch Channel Gains.');


%  Figure (4)  shows the roll gains

figure(4)
h1 = plot(t/60,L31,'r');hold on;grid on;
h2 = plot(t/60,L32,'b');
h3 = plot(t/60,L33,'g');
h_len = legend('L31','L32','L33');
hx = xlabel('Time (min)');hy = ylabel('Roll Gains');
ht = title('Roll Channel Gains.');


%  Figure (5) shows the roll gyro bias gains

figure(gcf+1)
subplot(211)
hr_1 = plot(t/60,phi,'c');grid on;
hr_y = ylabel('\phi (deg)');
axis([0 10 -95 95]);
subplot(212)
hp_1 = plot(t/60,L41,'r-');hold on;grid on;
hp_2 = plot(t/60,L42,'b-');
hp_3 = plot(t/60,L43,'g-');
h_len = legend('L41','L42','L43');
hp_x = xlabel('Time (min)');hp_y = ylabel('\delta p Gains');
axis([0 10 -0.01 0.01]);
ht = title('Computed Gains.');

%  Figure (6) shows the roll gyro bias gains

figure(gcf+1)
subplot(211)
h1 = plot(t/60,L51,'r');hold on;grid on;
h2 = plot(t/60,L52,'b');
h3 = plot(t/60,L53,'g');
h_len = legend('L51','L52','L53');
hq_y = ylabel('\delta q Gains');
axis([0 10 -0.01 0.01]);
subplot(212)
h1 = plot(t/60,L61,'r');hold on;grid on;
h2 = plot(t/60,L62,'b');
h3 = plot(t/60,L63,'g');
h_len = legend('L61','L62','L63');
hx = xlabel('Time (min)');hy = ylabel('\delta r Gains');
axis([0 10 -0.01 0.01]);
ht = title('Computed Gains.');

%break;

figure(gcf+1)
subplot(211)
hr_1 = plot(t/60,phi,'c');grid on;
hr_y = ylabel('\phi (deg)');
axis([0 10 -95 95]);
subplot(212)
hp_1 = plot(t/60,L41c,'r-');hold on;grid on;
hp_2 = plot(t/60,L42c,'b-');
hp_3 = plot(t/60,L43c,'g-');
h_len = legend('L41c','L42c','L43c');
hp_x = xlabel('Time (min)');hp_y = ylabel('\delta p Gains');
axis([0 10 -0.01 0.01]);
ht = title('Scheduled Gains.');

%  Figure (6) shows the roll gyro bias gains

figure(gcf+1)
subplot(211)
h1 = plot(t/60,L51c,'r');hold on;grid on;
h2 = plot(t/60,L52c,'b');
h3 = plot(t/60,L53c,'g');
h_len = legend('L51c','L52c','L53c');
hq_y = ylabel('\delta q Gains');
axis([0 10 -0.01 0.01]);
subplot(212)
h1 = plot(t/60,L61c,'r');hold on;grid on;
h2 = plot(t/60,L62c,'b');
h3 = plot(t/60,L63c,'g');
h_len = legend('L61c','L62c','L63c');
hx = xlabel('Time (min)');hy = ylabel('\delta r Gains');
axis([0 10 -0.01 0.01]);
ht = title('Scheduled Gains.');

idx = find(t > (t(end) - 60));

%  Plot Attitude Errors
figure(gcf+1)
subplot(311)
plot(t/60,r2d*eul(:,1)-yaw,'g');
title(['Attitude Error (Deg). f_s = ',num2str(1/dt),' Hz.']);
legend(['\sigma_{\psi} = ',num2str(std(r2d*eul(idx,1)-yaw(idx)),3),' deg.'])
grid on;
ylabel('\delta \psi')
subplot(312)
plot(t/60,r2d*eul(:,2)-the,'g');
legend(['\sigma_{\theta} = ',num2str(std(r2d*eul(idx,2)-the(idx)),3),' deg.'])
grid on;
ylabel('\delta \theta')
subplot(313)
plot(t/60,r2d*eul(:,3)-phi,'g');
ylabel('\delta \phi');
xlabel('Time (min)');
legend(['\sigma_{\phi} = ',num2str(std(r2d*eul(idx,3)-phi(idx)),3),' deg.'])
grid on;
%break;

figure(gcf+1)
subplot(311)
h1 = plot(t/60,L41,'k--');hold on;grid on;
h2 = plot(t/60,L42,'b-');
h3 = plot(t/60,L43,'r--');
h_len = legend('L41','L42','L43');
hy = ylabel('\delta p Gains');
ht = title('Euler Angle Filter');
axis([0 10 -0.010 0.010]);

set(h1,'LineWidth',2);
set(h2,'LineWidth',2);
set(h3,'LineWidth',2.5);
set(hy,'FontSize',16,'FontWeight','bold');
set(h_len,'FontSize',12,'FontName','Times','FontWeight','bold');
set(gca,'FontName','Times','FontWeight','bold','FontSize',16);
set(ht,'FontSize',16,'FontName','Times','FontWeight','bold');

subplot(312)
h1 = plot(t/60,L51,'k--');hold on;grid on;
h2 = plot(t/60,L52,'b-');
h3 = plot(t/60,L53,'r--');
h_len = legend('L51','L52','L53');
hy = ylabel('\delta q Gains');
axis([0 10 -0.010 0.010]);

set(h1,'LineWidth',2);
set(h2,'LineWidth',2);
set(h3,'LineWidth',2.5);
set(hy,'FontSize',16,'FontWeight','bold');
set(h_len,'FontSize',12,'FontName','Times','FontWeight','bold');
set(gca,'FontName','Times','FontWeight','bold','FontSize',16);

subplot(313)
h1 = plot(t/60,L61,'k--');hold on;grid on;
h2 = plot(t/60,L62,'b-');
h3 = plot(t/60,L63,'r--');
h_len = legend('L61','L62','L63');
hy = ylabel('\delta r Gains');
hx = xlabel('Time (min)');
axis([0 10 -0.010 0.010]);

set(h1,'LineWidth',2);
set(h2,'LineWidth',2);
set(h3,'LineWidth',2.5);
set(hy,'FontSize',16,'FontWeight','bold');
set(hx,'FontSize',16,'FontName','Times','FontWeight','bold');
set(h_len,'FontSize',12,'FontName','Times','FontWeight','bold');
set(gca,'FontName','Times','FontWeight','bold','FontSize',16);


if(FAST)
    orient tall;orient landscape;print -depsc fast_euler_gain.eps
else
    orient tall;orient landscape;print -depsc slow_euler_gain.eps
end

break;



%  Figure (7) shows the roll gyro bias gains

break;

figure(7)
h1 = plot(t/60,L61,'r');hold on;grid on;
h2 = plot(t/60,L62,'b');
h3 = plot(t/60,L63,'g');
h_len = legend('L61','L62','L63');
hx = xlabel('Time (min)');hy = ylabel('\delta r Gains');
ht = title('Yaw Gyro Bias Channel Gains.');

%  


break;


break;
%===================================%

subplot(322)
plot(imu_time/60,vel(:,1),'g');
title(['Velocity (m/s). f_s = ',num2str(1/dt),' Hz.'])
hold on;
plot(imu(:,1)/60,KTS2ms*Vn,'r');
grid on;
ylabel('North')

subplot(324)
plot(imu_time/60,vel(:,2),'g');
ylabel('East')
hold on;
plot(imu(:,1)/60,KTS2ms*Ve,'r');
grid on;

subplot(326)
plot(imu_time/60,vel(:,3),'g');
ylabel('Down');
hold on;
plot(imu(:,1)/60,KTS2ms*Vd,'r');
grid on;
xlabel('Time (min)');

%===================================%

figure(2)
subplot(321)
plot(imu_time/60,r2d*pos(:,1),'g');
hold on;
plot(imu(:,1)/60,lat,'r');
title('Position (deg)');
ylabel('Lat')
grid on;

subplot(323)
plot(imu_time/60,r2d*pos(:,2),'g');
ylabel('Lon (deg)')
hold on;
plot(imu(:,1)/60,lon,'r');
grid on;

subplot(325)
plot(imu_time/60,pos(:,3),'g');
hold on;
plot(imu(:,1)/60,h,'r');
grid on;
ylabel('Alt (m)');
xlabel('Time (min)');

%===================================%

subplot(322)
plot(imu_time/60,pos_ecef(:,1)-act_ecef(:,1),'r');
title('Position Error (ECEF in m)');
ylabel('X')
grid on;

subplot(324)
plot(imu_time/60,pos_ecef(:,2)-act_ecef(:,2),'r');
ylabel('Y')
grid on;

subplot(326)
plot(imu_time/60,pos_ecef(:,3)-act_ecef(:,3),'r');
ylabel('Z')
xlabel('Time (min)');
grid on


figure(3)
subplot(421)
plot(imu_time/60,qcomp(:,1),'r-');grid;ylabel('q_0');
title('Estimated Quaternions');
subplot(423)
plot(imu_time/60,qcomp(:,2),'g-');grid;ylabel('q_1');
subplot(425)
plot(imu_time/60,qcomp(:,3),'b-');grid;ylabel('q_2');
subplot(427)
plot(imu_time/60,qcomp(:,4),'c-');grid;ylabel('q_3');
xlabel('Time (min)');

subplot(422)
plot(imu_time/60,qref(:,1),'r--');grid;ylabel('q_0');
title('Actual Quaternions');
subplot(424)
plot(imu_time/60,qref(:,2),'g--');grid;ylabel('q_1');
subplot(426)
plot(imu_time/60,qref(:,3),'b--');grid;ylabel('q_2');
subplot(428)
plot(imu_time/60,qref(:,4),'c--');grid;ylabel('q_3');
xlabel('Time (min)');

figure(4)
subplot(321)
plot(imu_time/60,r2d*xhat(:,4),'r');grid;ylabel('\omega_x');
title('Estimated Gyro Biases (deg/sec)');
subplot(323)
plot(imu_time/60,r2d*xhat(:,5),'g');grid;ylabel('\omega_y');
subplot(325)
plot(imu_time/60,r2d*xhat(:,6),'b');grid;ylabel('\omega_z');
xlabel('Time (min)');

subplot(322)
plot(imu(:,1)/60,ppe,'r');grid;ylabel('\omega_x');
title('Actual Gyro Biases (deg/sec)');
subplot(324)
plot(imu(:,1)/60,qe,'g');grid;ylabel('\omega_y');
subplot(326)
plot(imu(:,1)/60,re,'b');grid;ylabel('\omega_z');
xlabel('Time (min)');

nz = length(estim_poles_z);

figure(5);
subplot(321)
plot(real(estim_poles_z(2:500:nz,1)),imag(estim_poles_z(2:500:nz,1)),'r*');
ylabel('Imaginary');zgrid;grid;axis([-1 1 -1 1]);axis('square');
title('z-plane Estimator Poles');

subplot(322)
plot(real(estim_poles_z(2:500:nz,2)),imag(estim_poles_z(2:500:nz,2)),'r*');
ylabel('Imaginary');zgrid;grid;axis([-1 1 -1 1]);axis('square');

subplot(323)
plot(real(estim_poles_z(2:500:nz,3)),imag(estim_poles_z(2:500:nz,3)),'r*');
ylabel('Imaginary');zgrid;grid;axis([-1 1 -1 1]);axis('square');

subplot(324)
plot(real(estim_poles_z(2:500:nz,4)),imag(estim_poles_z(2:500:nz,4)),'r*');
ylabel('Imaginary');zgrid;grid;axis([-1 1 -1 1]);axis('square');

subplot(325)
plot(real(estim_poles_z(2:500:nz,5)),imag(estim_poles_z(2:500:nz,5)),'r*');
xlabel('Real');ylabel('Imaginary');zgrid;grid;axis([-1 1 -1 1]);axis('square');

subplot(326)
plot(real(estim_poles_z(2:500:nz,6)),imag(estim_poles_z(2:500:nz,6)),'r*');
ylabel('Imaginary');zgrid;grid;axis([-1 1 -1 1]);axis('square');
xlabel('Real');


figure(6)
subplot(321)
plot(real(estim_poles_s(2:500:nz,1)),imag(estim_poles_s(2:500:nz,1)),'r*');
ylabel('Imaginary');sgrid;grid;axis('square');
title('s-plane Estimator Poles');

subplot(322)
plot(real(estim_poles_s(2:500:nz,2)),imag(estim_poles_s(2:500:nz,2)),'r*');
ylabel('Imaginary');sgrid;grid;axis('square');

subplot(323)
plot(real(estim_poles_s(2:500:nz,3)),imag(estim_poles_s(2:500:nz,3)),'r*');
ylabel('Imaginary');sgrid;grid;axis('square');

subplot(324)
plot(real(estim_poles_s(2:500:nz,4)),imag(estim_poles_s(2:500:nz,4)),'r*');
ylabel('Imaginary');sgrid;grid;axis('square');

subplot(325)
plot(real(estim_poles_s(2:500:nz,5)),imag(estim_poles_s(2:500:nz,5)),'r*');
xlabel('Real');ylabel('Imaginary');sgrid;grid;axis('square');

subplot(326)
plot(real(estim_poles_s(2:500:nz,6)),imag(estim_poles_s(2:500:nz,6)),'r*');
xlabel('Real');ylabel('Imaginary');sgrid;grid;axis('square');

nz = length(estim_poles_z);

figure(5);
subplot(321)
plot(real(estim_poles_z(2:500:nz,1)),imag(estim_poles_z(2:500:nz,1)),'r*');
ylabel('Imaginary');zgrid;grid;axis([-1 1 -1 1]);axis('square');
title('z-plane Estimator Poles');

subplot(322)
plot(real(estim_poles_z(2:500:nz,2)),imag(estim_poles_z(2:500:nz,2)),'r*');
ylabel('Imaginary');zgrid;grid;axis([-1 1 -1 1]);axis('square');

subplot(323)
plot(real(estim_poles_z(2:500:nz,3)),imag(estim_poles_z(2:500:nz,3)),'r*');
ylabel('Imaginary');zgrid;grid;axis([-1 1 -1 1]);axis('square');

subplot(324)
plot(real(estim_poles_z(2:500:nz,4)),imag(estim_poles_z(2:500:nz,4)),'r*');
ylabel('Imaginary');zgrid;grid;axis([-1 1 -1 1]);axis('square');

subplot(325)
plot(real(estim_poles_z(2:500:nz,5)),imag(estim_poles_z(2:500:nz,5)),'r*');
xlabel('Real');ylabel('Imaginary');zgrid;grid;axis([-1 1 -1 1]);axis('square');

subplot(326)
plot(real(estim_poles_z(2:500:nz,6)),imag(estim_poles_z(2:500:nz,6)),'r*');
ylabel('Imaginary');zgrid;grid;axis([-1 1 -1 1]);axis('square');
xlabel('Real');


figure(6)
subplot(321)
plot(real(estim_poles_s(2:500:nz,1)),imag(estim_poles_s(2:500:nz,1)),'r*');
ylabel('Imaginary');sgrid;grid;axis('square');
title('s-plane Estimator Poles');

subplot(322)
plot(real(estim_poles_s(2:500:nz,2)),imag(estim_poles_s(2:500:nz,2)),'r*');
ylabel('Imaginary');sgrid;grid;axis('square');

subplot(323)
plot(real(estim_poles_s(2:500:nz,3)),imag(estim_poles_s(2:500:nz,3)),'r*');
ylabel('Imaginary');sgrid;grid;axis('square');

subplot(324)
plot(real(estim_poles_s(2:500:nz,4)),imag(estim_poles_s(2:500:nz,4)),'r*');
ylabel('Imaginary');sgrid;grid;axis('square');

subplot(325)
plot(real(estim_poles_s(2:500:nz,5)),imag(estim_poles_s(2:500:nz,5)),'r*');
xlabel('Real');ylabel('Imaginary');sgrid;grid;axis('square');

subplot(326)
plot(real(estim_poles_s(2:500:nz,6)),imag(estim_poles_s(2:500:nz,6)),'r*');
xlabel('Real');ylabel('Imaginary');sgrid;grid;axis('square');


nstart = 2*flimit;
figure(7)
subplot(321)
plot(real(estim_poles_s(nstart,1)),imag(estim_poles_s(nstart,1)),'g*');
hold on;
plot(real(estim_poles_s(nz,1)),imag(estim_poles_s(nz,1)),'r*');
ylabel('Imaginary');sgrid;grid;axis('square');
title('s-plane Estimator Poles');

subplot(322)
plot(real(estim_poles_s(nstart,2)),imag(estim_poles_s(nstart,2)),'g*');
hold on;
plot(real(estim_poles_s(nz,2)),imag(estim_poles_s(nz,2)),'r*');
ylabel('Imaginary');sgrid;grid;axis('square');

subplot(323)
plot(real(estim_poles_s(nstart,3)),imag(estim_poles_s(nstart,3)),'g*');
hold on;
plot(real(estim_poles_s(nz,3)),imag(estim_poles_s(nz,3)),'r*');
ylabel('Imaginary');sgrid;grid;axis('square');

subplot(324)
plot(real(estim_poles_s(nstart,4)),imag(estim_poles_s(nstart,4)),'g*');
hold on;
plot(real(estim_poles_s(nz,4)),imag(estim_poles_s(nz,4)),'r*');
ylabel('Imaginary');sgrid;grid;axis('square');

subplot(325)
plot(real(estim_poles_s(nstart,5)),imag(estim_poles_s(nstart,5)),'g*');
hold on;
plot(real(estim_poles_s(nz,5)),imag(estim_poles_s(nz,5)),'r*');
xlabel('Real');ylabel('Imaginary');sgrid;grid;axis('square');

subplot(326)
plot(real(estim_poles_s(nstart,6)),imag(estim_poles_s(nstart,6)),'g*');
hold on;
plot(real(estim_poles_s(nz,6)),imag(estim_poles_s(nz,6)),'r*');
xlabel('Real');ylabel('Imaginary');sgrid;grid;axis('square');


figure(8)
subplot(321)
plot(imu_time/60,L11,'r-');grid;ylabel('L_{11}, L_{12}, L_{13}');
hold on; plot(imu_time/60,L12,'b-'); plot(imu_time/60,L13,'g-');
title('Estimator Gains');

subplot(323)
plot(imu_time/60,L21,'r-');grid;ylabel('L_{21}, L_{22}, L_{23}');
hold on; plot(imu_time/60,L22,'b-'); plot(imu_time/60,L23,'g-');

subplot(325)
plot(imu_time/60,L31,'r-');grid;ylabel('L_{31}, L_{32}, L_{33}');
hold on; plot(imu_time/60,L32,'b-'); plot(imu_time/60,L33,'g-');
xlabel('Time (min)');

subplot(322)
plot(imu_time/60,L41,'r-');grid;ylabel('L_{41}, L_{42}, L_{43}');
hold on; plot(imu_time/60,L42,'b-'); plot(imu_time/60,L43,'g-');
title('Red = 1^{st}, Blue = 2^{nd}, Green = 3^{rd} Column.');

subplot(324)
plot(imu_time/60,L51,'r-');grid;ylabel('L_{51}, L_{52}, L_{53}');
hold on; plot(imu_time/60,L52,'b-'); plot(imu_time/60,L53,'g-');

subplot(326)
plot(imu_time/60,L61,'r-');grid;ylabel('L_{61}, L_{62}, L_{63}');
hold on; plot(imu_time/60,L62,'b-'); plot(imu_time/60,L63,'g-');
xlabel('Time (min)');
%*************************************************************************%










