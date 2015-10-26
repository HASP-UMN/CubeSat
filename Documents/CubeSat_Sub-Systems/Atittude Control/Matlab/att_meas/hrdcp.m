%-------------------------------------------------------------------------
%                       batch file hrdp.m
%
%   hrdcp.m concatenates all the navigation simulation files into
%   one file for harcopy output.
%
%   Demoz Gebre 7/5/98
%--------------------------------------------------------------------------

flag1 = 0;
num_files = 0;
! ls > fnames.dat
fid = fopen('fnames.dat');
line_read = fgets(fid);
r = length(line_read);
old_line = line_read(1:r-1);

while ~flag1

    new_line = fgets(fid);

	if ~feof(fid)
        r = length(new_line);
        if ((strcp(new_line(r-1),'~')) | strcp(new_line(1:r-1),fnames.dat))
            catname = [old_line ' ' new_line(1:r-1)];
            old_line = catname;
	else
		flag1 = 1;
	end
end

fclose(fid);

evalstring = ['! cat ' catname ' > navsoftwr.txt'];
eval(evalstring);
! enscript -2r -G navsoftwr.txt;
! \rm fnames.dat
! \rm navsoftwr.txt









