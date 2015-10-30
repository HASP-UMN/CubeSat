data_squared = data.^2;
power_array = [.45,.5,.55];
cal_data = [1,2,3,5,6,8,252,253,254,255,256,257];
for q = 1:1
    power = power_array(q);
    power = .5;
    velocity_n = velocity.^(power);
    for i = 1:257
        for k = 2:1000
            velocity_n(i,k) = velocity_n(i,1);
        end
    end


    for i = 1:12
        cal_spot = cal_data(i);
         for k = 1:1000
            velocity_n_new(i,k) = velocity_n(cal_spot,1);
            data_squared_new(i,k) = data_squared(cal_spot,k);
        end
    end

%      figure
%      plot(velocity_n_new,data_squared_new)
%      temp_str = strcat('seperate n = ',num2str(power));
%      title(temp_str);


    for i = 1:6
        cal_spot = cal_data(i);
        cal_spot_2 = cal_data(i+6);
         velocity_temp(i) = velocity_n(cal_spot,1) + velocity_n(cal_spot_2,1);
         for k = 1:1000
            velocity_n_new_2(i,k) = velocity_temp(i)/2;
            temp(i,k) = data_squared(cal_spot,k) + data_squared(cal_spot_2,k);
            data_squared_new_2(i,k) = temp(i,k)/2;
         end
    end

%      figure
%      plot(velocity_n_new_2,data_squared_new_2)
%       temp_str = strcat('same n = ',num2str(power));
%      title(temp_str);


    for i = 1:6
       velocity_n_new_3(q,i) =  mean(velocity_n_new_2(i,1:end));
       data_squared_new_3(q,i) =  mean(data_squared_new_2(i,1:end));
    end

%      figure
%      plot(velocity_n_new_3(q,1:5),data_squared_new_3(q,1:5))
%      hold on
%     temp_str = strcat('Least squares fit of n= ',num2str(power));
%      title(temp_str);
end
[A,B]= polyfit(velocity_n_new_3(1,(1:6)),data_squared_new_3(1,1:6),1);
X1 = 2:.1:6;
Y1 = A(2) + A(1)*X1;

Y2 = linspace(100,250,150);
Y2_1 =((Y2.^2) - A(2));
Y2_2 = Y2_1./(A(1));
X2 = Y2_2 .^(1/power);
fprintf('Equation is: E^2= %d + %d * U^%d\n', A(2),A(1),power);
fprintf('Equation is also U= (((E^2)-%d)/%d)^%d\n' , A(2),A(1),(1/power))
plot(X1,Y1,'r',velocity_n_new_3(q,1:5),data_squared_new_3(q,1:5) , 'b');

temp_str = strcat('Least squares fit of n= ',num2str(power));
     title(temp_str);


