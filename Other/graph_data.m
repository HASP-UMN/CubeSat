% convert to velocity 
velocity_data =((data.^2) - A(2));
velocity_data = velocity_data./(A(1));
velocity_data = velocity_data .^(2);
% clyinder run 1 is 9 to 65
% cylinder run 2 is 66 to 124
% AOA 0 is 125 to 142
% AOA 5 is 145 to 166
% AOA 10 is 168 to 177
% AOA 17 is 182 to 251
q = 1;
for i = 9:65
    clyinder_data_run1(q) = mean(velocity_data(i,1:1000));
   
    Z_data_cylinder_1(q) = Z(i); 
     q = q +1;
end
clyinder_data_run1 = clyinder_data_run1' /velocity(9);
Z_data_cylinder_1 = Z_data_cylinder_1';
figure
plot(Z_data_cylinder_1,clyinder_data_run1);
title('cylinder run 1');

q = 1;
for i = 66:124
    clyinder_data_run3(q) = mean(velocity_data(i,1:1000));
   
    Z_data_cylinder_3(q) = Z(i); 
     q = q +1;
end
figure
clyinder_data_run3 = clyinder_data_run3'/velocity(66);
Z_data_cylinder_3 = Z_data_cylinder_3';
plot(Z_data_cylinder_3,clyinder_data_run3);
title('cylinder run 2');

q = 1;
for i = 125:142
    AOA_0_data(q) = mean(velocity_data(i,1:1000));
   
    Z_data_AOA_0(q) = Z(i); 
     q = q +1;
end
AOA_0_data = AOA_0_data'/velocity(125);
Z_data_AOA_0 = Z_data_AOA_0';
figure
plot(Z_data_AOA_0,AOA_0_data);
title('AOA 0');

q = 1;
for i = 145:166
    AOA_5_data(q) = mean(velocity_data(i,1:1000));
   
    Z_data_AOA_5(q) = Z(i); 
     q = q +1;
end
AOA_5_data = AOA_5_data'/velocity(145);
Z_data_AOA_5 = Z_data_AOA_5';
figure
plot(Z_data_AOA_5,AOA_5_data);
title('AOA 5');

q = 1;
for i = 168:177
    AOA_10_data(q) = mean(velocity_data(i,1:1000));
   
    Z_data_AOA_10(q) = Z(i); 
     q = q +1;
end
AOA_10_data = AOA_10_data'/velocity(168);
Z_data_AOA_10 = Z_data_AOA_10';
figure
plot(Z_data_AOA_10,AOA_10_data);
title('AOA 10');


q = 1;
for i = 182:252
    AOA_17_data(q) = mean(velocity_data(i,1:1000));
   
    Z_data_AOA_17(q) = Z(i); 
     q = q +1;
end
AOA_17_data = AOA_17_data'/velocity(182);
Z_data_AOA_17 = Z_data_AOA_17';
figure
plot(Z_data_AOA_17,AOA_17_data);
title('AOA 17');