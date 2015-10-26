     function [t_in,Ts,spd_in,yaw_in,h_dot,lat_in,...
                        lon_in,alt_in,the_in,phi_in] = deftraj;
%================================================================================%
%     function [t_in,Ts,spd_in,yaw_in,h_dot,lat_in,...
%                        lon_in,alt_in,the_in,phi_in] = deftraj;
%
%    The m-file deftraj (short for define trajectory) defines the simulation
%    trajectory in the form of waypoints.  At each way point, the user 
%    specifies gound speed, heading, climb rate, pitch angle and roll angle.
%    In addition, the user also specifies the position cordinates (in lattitude,
%    longitude and -altitude format) of the starting point.  Roll angle specification
%    is optional.  If not specifed, the program assmes an airplane making coordinates
%    turns and generates roll angles accordingly
%
%    Programmer:            Demoz Gebre-Egziabher
%    Last Modified:          November 15, 2002
%=================================================================================%

%==================================%
%      Define Some Constants       %
%==================================%

d2r = pi/180;
r2d = 1/d2r;
ft2m = 0.3048;
KTS2ms = 0.5144;
ms2KTS = 1/KTS2ms;

example_1 = 0;
example_2 = 0;
example_3 = 0;
example_4 = 0;
example_5 = 0;
example_6 = 0;
example_7 = 1;

if(example_1)
    %  This is an example trajectory defintion of a Missle that:
    %  (1) Starts at the Equator at an altitude of 1000 ft.
    %      Then it flies west at 999 Knots for  five minutes.  
    %      The nice thing about this trajecotry is that Earth 
    %      Rate almost cancels out the transport rate
    %      such that there should be a very small coriolis accelerations.
    
    lat = 0;             %(deg. North (+); South (-))
    lon = 0;             %(deg. West (+); East (-))
    alt = 0;             %(ft. Down (+); Up (-))
    
    Ts = 1;                  % 100 Hz Sampling Rate
    
    t = [0;60];
    
    spd =[-999;-999];
    
    yaw = [-90;-90];
    vspeed = [0;0];
    pitch = [0;0];
    roll = [0;0];
    
elseif (example_2)
    %  This is an example trajectory defintion of an airplane that:
    %  (1) Starts close to the U of M in Minneapolis at an altitude of 
    %      1000 ft and for 1 minute flies north at a speed of 
    %      120 Knots
    %  (2) It executes a standard rate turn (3 deg/sec) to a 
    %      heading of 270 and flies for another minute at 120 Knots
    %  (3) It executes another standard rate turn to a heading of 030
    %      at 120 Knots.
    %  (4) Pitches down to 5 degrees in 5 Seconds
    %  (5) It descends at 500 ft/min for 1 minute
    %  (6) It continues to decsend for another minute while slowing to
    %      90 Knots.
    
    lat = 44.981562;             %(deg. North (+); South (-))
    lon = -93.23928;             %(deg. West (+); East (-))
    alt = -1000;                 %(ft. Down (+); Up (-))
    
    Ts = 1/20;                   % 20 Hz Sampling Rate (4/21/2003)
    
    t   =  [  0;...              % Starting Time
             60;...              % Begin the Standard Rate Turn
             90;...              % End the Standard Rate Turn
            120;...              % Begin the Second Standard Rate Trun
            170;...              % End Standard Rate Turn. Start Decsent
            175;...              % Pitch over to a 5 Nose down attitude
            230;...              % Start Slowing Down
            300];                % End Simulation  (Note: Original end time is 290)
    
    spd  =  [120;...             % 1st Leg Speed
             120;...             % 2nd Leg Speed (Turning)
             120;...             % 3rd Leg Speed
             120;...             % 4th Leg Speed (Turning)
             120;...             % 5th Leg Speed (Start Descent)
             120;...             % Pitch-Over Complete
             120;...             % 6th Leg Speed (Begin Slowing)
              90];               % Terminal Speed
      
    yaw  =  [  0;...             % 1st Leg Heading
               0;...             % Heading at Start of 1st Turn
             -90;...             % Heading at End of 1st Trun
             -90;...             % Heading at Start of 2nd Turn
              30;...             % Heading at End of 2nd Turn
              30;...             % Pitch-Over Complete
              30;...             % Heading on 6th Leg
              30];               % Final Heading.
      
   vspeed  =  [  0;...             % Vertical Speed on 1st leg
                 0;...             % Vertical Speed at Start of 1st Turn
                 0;...             % Vertical Speed at End of 1st Trun
                 0;...             % Vertical Speed at Start of 2nd Turn
              +500;...             % Start of Decent (note the "+" sign)
              +500;...             % Vertical Speed when Pitch-Over Complete
              +500;...             % Vertical Speed on 6th Leg
              +500];               % Final Vertical Speed
      
    pitch  =  [  0;...             % Pitch on 1st leg
                 0;...             % Pitch at Start of 1st Turn
                 0;...             % Pitch at End of 1st Trun
                 0;...             % Pitch at Start of 2nd Turn
                 0;...             % Start Pitch-Over
                -5;...             % Pitch Angle when Pitch-Over Complete
                -5;...             % Pitch on 6th Leg
                -5];               % Final Pitch
        
    roll = [ ];                     % Assuming Coordinated Turns

    
elseif(example_3)
    %  This is the "typical" approach to a carrier type of profile.  It is
    %  based on the profile developed by Boris Pervan and used in his
    %  ION 2001 paper.
    %  The starting point is arbitrary and in this case is set to be in the 
    %  Pacific ocean south of Hawaii (N15 Lat & W150 Lon).  Other details
    %  of the profile are:
    %  (1) Starts at t = 0 with an approach speed of 250 Kts on a 
    %      northerly heading
    %  (2) After approximately 7 minutes at t = 420, it initiates 
    %      a 4000 ft/min descent at a -10 pitch angle for 15 sec.
    %  (3) At t = 435, it reduces the descent rate to 2100 ft/min and 
    %      the pitch angle to -5 degrees.  
    %  (4) It continues in the configuration until t = 543 at which point
    %      is stops the descent and commences to slow down to 140 Kts
    %  (5) At t = 573, it has slowed down to 140 Knots, is level and at
    %      an alitude of approximately of 1200 ft.
    %  (6) At t = 752, it starts its final descent at a picth angle of 
    %      -5 degrees and a sink rate of 935 ft/min
    %  (7) Lands at t = 829.
    
    lat = 15;               %(deg. North (+); South (-))
    lon = -150;             %(deg. West (+); East (-))
    alt = -6000;            %(ft. Down (+); Up (-))
    
    Ts = 1/10;                   % 10 Hz Sampling Rate
    
    t   =  [   0;...             % Starting Time
             420;...             % Begin Descent
             422;...             % Descent Rate Established
             435;...             % Long Descent Configuration.
             437;...             % Long Descent Established
             543;...             % Stop Descent. Start Slowing down to 140 Kts
             573;...             % Speed = 140 Knots and level
             752;...             % Commence Final Descent
             755;...             % Established on Final Descent
             829];               % Land and End Simulation
    
    spd  =  [250;...             % 1st Leg Speed
             250;...             % Commence Descent 
             250;...             % Established In D. Config
             250;...             % Commence Second Descent
             250;...             % Established In Second Descent
             250;...             % Commence Level-Off and Slow Down
             140;...             % Established on Level-Off/Slow Down
             140;...             % Commence Final Descent
             140;...             % Established on Final Descent
             140];               % Terminal Speed
      
    yaw  =  [  0;...             % Heading North
               0;...             % 
               0;...             % 
               0;...             % 
               0;...             % 
               0;...             % 
               0;...             % 
               0;...             %
               0;...             %
               0];               % Final Heading.
      
   vspeed  =  [  0;...             % Vertical Speed on 1st leg
                 0;...             % Vertical Speed at Beginning of 1st Descent
             +4000;...             % Vertical Speed During First Descent
             +4000;...             % Vertical Speed at Start of 2nd Descent
             +2100;...             % Vertical Speed when Established on 2nd Descent
             +2100;...             % Vertical Speed at Beginning of Level-Off
                 0;...             % Level-Off/Slow Down in Effect
                 0;...             % V-Speed during Commencement of Final Descent
              +935;...             % Final Descent Rate
              +935];               % Sink Rate at the Boat
      
      
   pitch   =  [  0;...             % Pitch Angle on 1st leg
                 0;...             % Pitch Angle at Beginning of 1st Descent
               -10;...             % Pitch Angle During First Descent
               -10;...             % Pitch Angle at Start of 2nd Descent
                -5;...             % Pitch Angle when Established on 2nd Descent
                -5;...             % Pitch Angle at Beginning of Level-Off
                 0;...             % Level-Off/Slow Down in Effect
                 0;...             % Pitch Angle during Commencement of Final Descent
                -5;...             % Final Pitch Angle
                +5];               % Pitch Attitude at the Boat
        
    roll = [ ];                     % Assuming Coordinated Turns
    
elseif(example_4)
    %  This is an example discussed in a paper by Donald O. Benson
    %  "A Comparison of Two Approaches to Pure-Inertial and Doppler-
    %  Inertial Error Analysis," IEEE-AES, Vol. 11, No. 4, July 1975.
    %  It is recreated here as a check of the psi-angle mechanization.
    
    lat = 75;             %(deg. North (+); South (-))
    lon = 0;              %(deg. West (+); East (-))
    alt = 0;              %(ft. Down (+); Up (-))
    
    Ts = 1/100;                 % 100 Hz Sampling Rate
    
    t = [0;3600];           % 1 hr.Crusing   
    
%    spd = [1000;1000]*ft2m/KTS2ms;   % 1000 ft/sec converted to Knots
    spd = -[1000;1000]*ft2m/KTS2ms;   % 1000 ft/sec converted to Knots
    
    yaw = [90;90];
    vspeed = [0;0];
    pitch = [0;0];
    roll = [0;0];
    
elseif(example_5)
    %  This is simulates a simple "U" trajectory for the ION-NTM 2003
    %  paper by Santiago Alban and myself titled "Performance Analysis
    %  and Estimator Architectures for INS Aided GPS Tracking Loops,"
    %  The trajector begins by a north acceleration to 2 m/s in 1 sec,
    %  a cruise for 9 sec, a 180 degree turn in 10 sec, another cruise
    %  south for 9 sec, and a final decelleration to a stop in 1 sec.
    %  The objective is to see how well the Doppler can be estimated
    %  using inertial sensors and a combined GPS-inertial system.
    %
    
    lat = 37;             %(Start Location is Stanford, CA)
    lon = -122;             
    alt = 0;                 
    
    Ts = 1/100;                     % 100 Hz Sampling Rate
    
    t_turn = [10:0.1:20]';          %  Find-time-grid for turn
    dt_turn = t_turn - t_turn(1);
    t_drl = length(t_turn);
    yaw_turn = 18*dt_turn;
    
    t = [    0      ;...                   %  Starting Time
             1      ;...                   %  End of 1st acceleration
             t_turn ;...                   %  Find-time-grid for turn
             29     ;...                   %  Begin Deceleration
             30]    ;                      %  Stop
            
    spd  =  [  0              ;...         % Start from Rest
               2              ;...         % Terminal Speed 
               2*ones(t_drl,1);...         %  Find-time-grid for turn
               2              ;...         % Begin Deceleration
               0]             ;            % Stop
               
    yaw  =  [  0              ;...         % Start from Rest
               0              ;...         % Terminal Speed 
               yaw_turn       ;...         %  Find-time-grid for turn
               yaw_turn(end)  ;...         % Begin Deceleration
               yaw_turn(end)] ;            % Stop
   
    vspeed = zeros(length(t),1);
    pitch = vspeed;
    roll = vspeed;
    
elseif(example_6)

    %  This is simulates a static user at Minneapolis-St. Paul International
    %  airport over a 24 hr period.  This example is being used to generate
    %  data for a homework set in AEM 8459, Spring 2003 Semester.
    %
    
    lat = 44.8805469;             %(Location is Minneapolis-St. Paul International)
    lon = -93.216922537;             
    alt = 841;                 
    
    Ts = 60;                                      % 1/60  Hz Sampling
        
    t = [    0      ;...                               %  Starting Time
             5*60*60]    ;                      %  Stop
            
    spd  =  [   0              ;...         % Start
                     0 ]             ;            % Stop
               
    yaw  =  [   0              ;...         % Start from Rest
                     0             ] ;            % Stop
   
    vspeed = zeros(length(t),1);
    pitch = vspeed;
    roll = vspeed;
    
elseif (example_7)
    %  This is an example very similar to example 1.  Instead of starting by
    %  flying north, the vehicle starts by flying east.  Furthermore, the flight
    %  starts at MSP International airport.
    
    lat = 44.981562;             %(deg. North (+); South (-))
    lon = -93.23928;             %(deg. West (+); East (-))
    alt = -256.3;                 %(ft. Down (+); Up (-))
    
    Ts = 1/20;                   % 20 Hz Sampling Rate (4/21/2003)
    
    t   =  [  0;...              % Starting Time
             60;...              % Begin the Standard Rate Turn
             90;...              % End the Standard Rate Turn
            120;...              % Begin the Second Standard Rate Trun
            170;...              % End Standard Rate Turn. Start Decsent
            175;...              % Pitch over to a 5 Nose down attitude
            230;...              % Start Slowing Down
            300];                % End Simulation 
    
    spd  =  [120;...             % 1st Leg Speed
             120;...             % 2nd Leg Speed (Turning)
             120;...             % 3rd Leg Speed
             120;...             % 4th Leg Speed (Turning)
             120;...             % 5th Leg Speed (Start Descent)
             120;...             % Pitch-Over Complete
             120;...             % 6th Leg Speed (Begin Slowing)
              90];               % Terminal Speed
      
    yaw  =  [  90;...             % 1st Leg Heading
               90;...             % Heading at Start of 1st Turn
               45;...             % Heading at End of 1st Trun
               45;...             % Heading at Start of 2nd Turn
              45;...             % Heading at End of 2nd Turn
              45;...             % Pitch-Over Complete
              45;...             % Heading on 6th Leg
              90];               % Final Heading.
      
   vspeed  =  [ -500;...             % Vertical Speed on 1st leg
                -500;...             % Vertical Speed at Start of 1st Turn
                -500;...             % Vertical Speed at End of 1st Trun
                 0;...             % Vertical Speed at Start of 2nd Turn
                 0;...             % Start of Decent (note the "+" sign)
                 0;...             % Vertical Speed when Pitch-Over Complete
                 0;...             % Vertical Speed on 6th Leg
                 0];               % Final Vertical Speed
      
    pitch  =  [  5;...             % Pitch on 1st leg
                 5;...             % Pitch at Start of 1st Turn
                 5;...             % Pitch at End of 1st Trun
                 0;...             % Pitch at Start of 2nd Turn
                 0;...             % Start Pitch-Over
                 0;...             % Pitch Angle when Pitch-Over Complete
                 0;...             % Pitch on 6th Leg
                 0];               % Final Pitch
        
    roll = [ ];                     % Assuming Coordinated Turns
        
end
        

%  Rename Variables and Convert from Flying Standards to Metric Units
   
t_in = t;
lat_in = lat*d2r;
lon_in = lon*d2r;
alt_in = alt*ft2m;
spd_in = spd*KTS2ms;
yaw_in = yaw*d2r;
h_dot = vspeed*(ft2m/60);
the_in = pitch*d2r;
phi_in = roll*d2r;                     
   
