            function dll = latlonrate(v,h,lat);
%---------------------------------------------------------
%           function dll = latlonrate(v,h,lat)
%
%   latlonrate computes the latitude and longitude rates.
%   dll(1) = lattitude rate
%   dll(2) = longitude rate
%
%   Demoz Gebre 7/3/98
%---------------------------------------------------------

[Rew,Rns] = earthrad(lat);

latrate = v(1)/(Rns - h);
lonrate = v(2)/((Rew - h)*cos(lat));

dll = [latrate;lonrate];

%*************************************************************************%
