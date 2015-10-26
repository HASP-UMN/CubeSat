       function [gyro,accel] = getinsmodel(INSQualFlag)
%-----------------------------------------------------------%
%
%      function [gyro,accel] = getinsmodel(INS_QualFlag)
%
%  This returns the error model of an INS.  INSQualFlag is 
%  the INS quality flag that is set to the following options:
%  
%  1. 'NAV' - Navigation Grade INS
%  2. 'TAC' - Tactical Grade INS
%  3. 'CON' - Consumer Grade INS
%  4. 'PERFECT' - A Perfect INS
%
%  Also provided are the two test cases of 'BENSON' and
%  'FARRELL' which are based on a paper by Benson (c.f.
%   "A Comparison of Two Approaches to Pure-Inertial and 
%   Doppler-Inertial Error Analysis," IEEE-AES, Vol. 11, 
%   No. 4, July 1975) and the text book by Farrell and 
%   Barth (c.f. "The Global Positioning System and Inertial
%   Navigation," McGraw-Hill, 1999).
%  
%  The returned variable gyro is a 1 x 4 vector containing the
%  the following information:
%
%  gyro = [tau sigma noise null-shift];
%
%  tau = Time Constant (sec)
%  sigma = Standard deviation (radians/sec)
%  noise = Wide-band noise  (radians/sec)
%
%  A similar information is contained in the variable accel.
%
%  Not to myself:
%
%  This is the first in a serier of tools that I am 
%  re-developing as part of the JPALS work.  It is a repeat of
%  work in my ins tool box that was developed in July 1998.
%  I want to ensure that all the pieces to be used in the inertial
%  aiding covariance anlaysis is sound.
%
%  Programmer:        Demoz Gebre-Egziabher
%  Last Modified:     September 7, 2001
%
%-----------------------------------------------------------
%
%  First Created      September 7, 2001 (ION 2001 papaer)
%
%----------------------------------------------------------%

%  Argument Check

if (nargin < 1)
    error('An INS quality descriptor has not been entered.');
end

%  Define Constants

d2r = pi/180;           % Degrees to radians
r2d = 1/d2r;            % Radians to degrees
s2hr = 1/3600;          % Seconds to hours
g = 9.81;               % Nominal Magnitude of Graviational Acceleration

%  Selet the appropriate Gyro model

if(strcmp(INSQualFlag,'NAV'))
     %  Navigation Grade Rate Gyro Error Parameters
     %  Obtained from Ph.D. thesis by Ping Ya Ko titled
     %  "GPS-Based Precision Approach and Landing", Stanford University 2000,pp.34
     tau = 3600;                    %  Time constant on gyro bias
     sigma_wc = 0.003*d2r*s2hr;     %  Standard Deviation of Gyro Markov Bias
     sigma_wn = 0.0008*d2r/60;      %  Standard Deviation of Gyro Wide Band Noise
     sigma_ns = sigma_wc;           %  Null Shift
elseif(strcmp(INSQualFlag,'TAC'))
     %  Tactical Grade Rate Gyro Error Parameters (LN200 Numbers)
     tau = 100;                     %  Time constant on gyro bias
     sigma_wc = 0.35*d2r*s2hr;      %  Standard Deviation of Gyro Markov Bias
     sigma_wn = 0.0017*d2r;         %  Standard Deviation of Gyro Wide Band Noise
     sigma_ns = sigma_wc;           %  Null Shift    
 elseif(strcmp(INSQualFlag,'CON'))
     %  Automotive Grade Gyro Error Parameters
     tau = 300;                     %  Time constant on gyro bias
     sigma_wc = 180*d2r*s2hr;       %  Standard Deviation of Gyro Markov Bias
     sigma_wn = 0.05*d2r;           %  Standard Deviation of Gyro Wide Band Noise
     sigma_ns = sigma_wc;           %  Null Shift    
  elseif(strcmp(INSQualFlag,'PERFECT'))
     %  Perfect Sensor
     tau = 1/eps;                   %  Time constant on gyro bias
     sigma_wc = 0;                  %  Standard Deviation of Gyro Markov Bias
     sigma_wn = 0;                  %  Standard Deviation of Gyro Wide Band Noise
     sigma_ns = 0;                  %  Null Shift    
  elseif(strcmp(INSQualFlag,'BENSON'))
     %  Example in Benson's Paper
     tau = 1/eps;                   %  Time constant on gyro bias
     sigma_wc = 0;                  %  Standard Deviation of Gyro Markov Bias
     sigma_wn = 0;                  %  Standard Deviation of Gyro Wide Band Noise
     sigma_ns = d2r*(0.01/3600);    %  Null Shift    
 end

 gyro = [tau sigma_wc sigma_wn sigma_ns];
 
 %  Selet the appropriate Accelerometer model
 
 if(strcmp(INSQualFlag,'NAV'))
     %  Navigation Grade Rate accelerometer Error Parameters
     %  Obtained from Ph.D. thesis by Ping Ya Ko titled
     %  "GPS-Based Precision Approach and Landing", Stanford University 2000,pp.34
     tau = 3600;                   %  Time constant on accelerometer bias
     sigma_wc = (25e-6)*g;         %  Standard Deviation of accelerometer Markov Bias
     sigma_wn = (5e-6)*g;          %  Standard Deviation of accelerometer Wide Band Noise
     sigma_ns = sigma_wc;          %  Null Shift
elseif(strcmp(INSQualFlag,'TAC'))
     %  Tactical Grade Rate accelerometer Error Parameters (LN200 Numbers)
     tau = 60;                     %  Time constant on accelerometer bias
     sigma_wc = (50e-6)*g;         %  Standard Deviation of accelerometer Markov Bias
     sigma_wn = (50e-5)*g;         %  Standard Deviation of accelerometer Wide Band Noise
     sigma_ns = sigma_wc;          %  Null Shift    
 elseif(strcmp(INSQualFlag,'CON'))
     %  Automotive Grade accelerometer Error Parameters
     tau = 100;                    %  Time constant on accelerometer bias
     sigma_wc = g*(1.2e-3);        %  Standard Deviation of accelerometer Markov Bias
     sigma_wn = g*(1e-3);          %  Standard Deviation of accelerometer Wide Band Noise
     sigma_ns = sigma_wc;          %  Null Shift    
  elseif(strcmp(INSQualFlag,'PERFECT'))
     %  Perfect Sensor
     tau = 1/eps;                  %  Time constant on accelerometer bias
     sigma_wc = 0;                 %  Standard Deviation of accelerometer Markov Bias
     sigma_wn = 0;                 %  Standard Deviation of accelerometer Wide Band Noise
     sigma_ns = 0;                 %  Null Shift    
  elseif(strcmp(INSQualFlag,'BENSON'))
     %  Example in Benson's Paper
     tau = 1/eps;                   %  Time constant on gyro bias
     sigma_wc = 0;                  %  Standard Deviation of Gyro Markov Bias
     sigma_wn = 0;                  %  Standard Deviation of Gyro Wide Band Noise
     sigma_ns = g*(1e-4);           %  Null Shift    
  end

 accel = [tau sigma_wc sigma_wn sigma_ns];