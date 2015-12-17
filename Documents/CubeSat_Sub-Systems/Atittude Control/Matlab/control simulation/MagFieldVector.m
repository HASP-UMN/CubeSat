function [H] = MagFieldVector(t)
% Returns the three components of the earth's magnetic field(EMF) intensity
% experienced by a cubesat flying at an assigned altitude
% Note: Components are in a earth-centered frame of reference and need to
% be tranformed with direction matrix to cubesat's F.O.R.

%% prep work and constants
G = 6.67408e-11;%universal gravitational constant
Mearth = 5.972e24;% Mass of the earth in Kg
a = (6371+600)*(10^3);%orbit semi-major axis (Earth-radius + alt.)
i = 55*pi/180;% orbit inclination in radians(55 test case, 60 for SOCRATES)
w = 0;% argument of periapsis;



T = 2*pi*sqrt(a^3/(G*Mearth)); %Orbital period in seconds
t = mod (t,T);% removes previous orbits in time to determine position
if t>=0
    trueanomaly = (2*pi*t/T);%true anomaly of cubesat in orbit 
elseif t<0
    trueanonmaly = (2*pi)+(2*pi*t/T);
end
u = w+trueanomaly;% argument of latitude in radians

H600 = 18.3;%EMFIntensity in A/m at a 600km altitude
H410 = 12.6;%???? EMF Intensity in A/m at a 410km altitude

Heq = H600;%Magnetic field strength at equator

H=ones(1,3);

H(1) = 3*Heq*sin(i)*cos(i)*sin(u)*sin(u);%Hx
H(2) = -3*Heq*sin(i)*sin(u)*cos(u);%Hy
H(3) = Heq*(1-(3*sin(i)*sin(i)*sin(u)*sin(u)));%Hz
end

