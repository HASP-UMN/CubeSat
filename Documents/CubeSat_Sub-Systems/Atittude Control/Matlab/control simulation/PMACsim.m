% Simulates the settling time and behavior of a 3U cubesat with a
% passive magnetic control system in place. 
% N.Sloan 11-30-15

%% Important values
AbsTol = 1e-7; %ODE solver tolerance
RelTol = 1e-7;
k = 1:1:20;
mu0 = 1.25663706e-6;% magnetic permeability of free space m kg s-2 A-2 (from google)
%initState = [30 45 30 8 -5 7].*(pi/180); % Original starting orientation of cubesat in degrees (Earth-centered) + initial angular rate within body-centered frame(rad/sec)
% Note: [degrees]*conversion_to_Rad

%Test case from Gerhardt and Palo
initState = [0 0 0 10 5 5].*(pi/180);

t0 = 0;
tf = 6000;
tspan = t0:1:tf;
options = odeset('AbsTol', AbsTol,'RelTol',RelTol);
[time, out] = ode45(@cubesatflight,tspan,initState');

% convert back from rads to degrees
out = out.*(180/pi);

% Eventually will have results printing
plot(tspan,out(:,4),'b',tspan,out(:,5),'r',tspan,out(:,6),'g');
legend('\omega_x','\omega_y','\omega_z');
