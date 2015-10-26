            function maghdg = getheading(H,eul)
%------------------------------------------------------------------
%           function maghdg = getheading(H,eul)
%
%   getheading returns the magnetic heading given magnetic field 
%   measurements (H) in the body coordinated system and euler angles
%   (eul) describing the orientation of the vehicle with respect to
%   north east down geographic frame.
%
%   Demoz Gebre 8/21/00
%--------------------------------------------------------------------------

Cb2n = eul2dcm(eul)';
Hbr = Cb2n*H;

if (Hbr(1) > 0 & Hbr(2) <= 0)
    maghdg = -atan(Hbr(2)/Hbr(1));
elseif(Hbr(1) > 0 & Hbr(2) > 0)
    maghdg = 2*pi - atan(Hbr(2)/Hbr(1));
elseif(Hbr(1) < 0)
    maghdg = pi - atan(Hbr(2)/Hbr(1));
end    

%*************************************************************************%
