function yawU = unwrapyaw(yaw)
%%------------------------------------------------------%
%%               function yawU = unwrapyaw(yaw)         %
%%                                                      %
%% Unwraps yaw to be between -pi and +pi radians        %
%% (i.e, the input 'yaw' must be in radians)            %
%% Programmer:       Demoz Gebre-Egziabher              %
%% Last Modified:    31 August, 2000                    %
%%------------------------------------------------------%
d2r = pi/180;
r2d = 1/d2r;

yaw_temp = r2d*yaw;
nwrap = yaw_temp/360;
idx = find(abs(nwrap) >= 1);
yaw_temp(idx) = yaw_temp(idx) - fix(nwrap(idx))*360;
idx1 = find(yaw_temp > 180);
idx2 = find(yaw_temp <= -180);
yaw_temp(idx1) = yaw_temp(idx1) - 360;
yaw_temp(idx2) = yaw_temp(idx2) + 360;
yawU = d2r*yaw_temp;


