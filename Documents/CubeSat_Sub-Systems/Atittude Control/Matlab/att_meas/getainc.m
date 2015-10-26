             function ainc = getainc(eul1,eul2,v,h,lat,Ts)
%-------------------------------------------------------------------------
%            function ainc = getainc(eul1,eul2,v,h,lat,Ts)
%
%   getainc calculates the angular increments that will be generated
%   by an inertial measurement unit in the time interval from t = k to
%   t = Ts + k if at t = k velocity was v, attitude was eul1 and 
%   lattitude was lat.  eul2 is the attitude at t = Ts + k.  eul1 and eul2
%   must be in radians given in [yaw;pitch;roll] order. v is in m/s, 
%   lat is in radians and Ts is in seconds. h is altitude given in meter.
%   Note: Because a North, East, Down coordinate system is assumed, h is 
%   negative for altitude above the reference ellipsoid.
%
%   Demoz Gebre 7/3/98
%--------------------------------------------------------------------------

quatON = 0;


%   Determine the navigation frame rate

rho = navrate(v,h,lat);
erate = earthrate(lat);

%   Determine change in quaternions between t = k and t = Ts + k

if (quatON)
    q_current = eul2quat(eul1);
    q_future = eul2quat(eul2);
    delta_q = q_future - q_current;
    %delta_q = quatmult(quatinv(q_current),q_future);

%   Define new matrices Q and R and vector w;
%   (see pp.25 of research notes)

    Q = 0.5*(q_current(1)*eye(3)-sk(q_current(2:4)));
    R = 0.5*(q_current(1)*eye(3)+sk(q_current(2:4)));

    w = delta_q(2:4) + Ts*Q*(rho+erate);

    %   Compute ainc

    ainc = pinv(R)*w;
%    condR = cond(R);

else
    
    Cb2n_1 = eul2dcm(eul1)';
    Cb2n_2 = eul2dcm(eul2)';
    Omega = Ts*sk(rho+erate)*Cb2n_1;
    dCb2n = Cb2n_1'*(Cb2n_2 + Omega) - eye(3);
    ainc = [-dCb2n(2,3);dCb2n(1,3);-dCb2n(1,2)];
%    condR = 1;
end

    
    

%keyboard
%*************************************************************************%

