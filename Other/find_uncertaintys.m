cal_data = [1,2,3,5,6,8,252,253,254,255,256,257];
random_uncertainy = 1.96 * STD / sqrt(1000);
for i = 1:12
     cal_spot = cal_data(i);
     velocity_cal(i) = velocity(cal_spot);
     random_uncertainy_cal(i) = random_uncertainy(cal_spot);
     AVG_cal(i) = AVG(cal_spot);
end 
velocity_cal = velocity_cal';
random_uncertainy_cal = random_uncertainy_cal';
AVG_cal = AVG_cal';

% web base for un_A and un_B
un_A = 0.443822068604752;
B = A(2);
A_ = A(1);
un_B = 0.0190799644724173;

for i = 1:257 
    for j = 1:1000
        dUdA(i,j) = (data(i,j)^2 * 2 + 2*A_)/(B^2);
        dUdB(i,j) = -2*(data(i,j)^4 + 2*A_ + A_^2) / (B^3);
        dUdE(i,j) = (4*data(i,j)^3 + 4*A_*data(i,j))/(B^2);
        Wr_A(i,j) = dUdA(i,j) *un_A;
        Wr_B(i,j) = dUdB(i,j) *un_B;
        Wr_E(i,j) = dUdE(i,j) *random_uncertainy(i);
        Wr_U(i,j) = sqrt(Wr_A(i,j)^2 + Wr_B(i,j)^2 + Wr_E(i,j)^2);
    end
    Wr_U_rms(i,1) = rms(Wr_U(i,1:1000));
    Wr_U_rms(i,1) = Wr_U_rms(i,1)/velocity(i);
    Wr_U_mean(i,1) = mean(Wr_U(i,1:1000));
    Wr_U_mean(i,1) =  Wr_U_mean(i,1)/velocity(i);
end 