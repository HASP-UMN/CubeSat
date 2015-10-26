            function [at,tow] = utc2gps(m,d,y,h,mi,s)
%------------------------------------------------------------------------
%           function [at, tow] = utc2gps(m,d,y,h,mi,s)
%
%   Given the month, day, year, hour, minute and second, the function
%   returns the gps absolute time (at) measured from week zero and the
%   gps time of the week (tow) in seconds from the start of the gps week.
%
%   (Based on the TMS c-file Find_Abs_Gps_Time.c by Todd Walter.)
%
%   Last Modified by Demoz Gebre on 9/11/99
%------------------------------------------------------------------------

temp_year = 1995;
abs_time = 0.0;
num_day_month = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];

while(temp_year < y)
    if(((mod(temp_year,4)==0) & (mod(temp_year,100) ~= 0)) |(mod(temp_year,400) == 0))
        abs_time = abs_time + (86400*366);  % Leap Year
    else
        abs_time = abs_time + (86400*365);
    end
    temp_year = temp_year + 1;
end
temp_year;


for k=1:(m-1)
    if (k == 2 & ((((mod(temp_year,4) == 0) & (mod(temp_year,100) ~= 0)) | (mod(temp_year,400) == 0)))) 
        abs_time = abs_time + (29*86400);  % Leap Year
    else
        abs_time = abs_time + num_day_month(k)*86400;
    end
    
end

abs_time = abs_time + ((d-1)*86400);
abs_time = abs_time + (h*3600);
abs_time = abs_time + (mi*60);
abs_time = abs_time + s;

abs_time = abs_time + 472953600;

at = abs_time;
tow = mod(abs_time,86400*7);
