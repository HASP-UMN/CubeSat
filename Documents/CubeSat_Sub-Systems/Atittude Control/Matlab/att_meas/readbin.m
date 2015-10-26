function [X,M,N] = readbin(filename,M)
%
% function used to read in binary data streams
%   function [X,M,N] = readbin(filename,M)
% where M is the number of rows in the stored array
%
%  Programmer:    J. Tony Rios
%
[fid,msg] = fopen(filename,'r','native') ;  % Open file.
if (~isempty(msg)),
  error('Invalid filename.')
end
[X,count] = fread(fid,[M,inf],'float64');
X=X';
N=count/M;
fclose(fid);
