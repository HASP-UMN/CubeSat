
function [qs]=qcomp(q);
% function [qs]=qcomp(q);
%
% this function returns the complement of the
% quaternion, q* = [qo | -qbar]'
%
qs = [q(1);-q(2:4)];
