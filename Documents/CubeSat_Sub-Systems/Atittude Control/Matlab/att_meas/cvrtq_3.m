function [W,Phi]=cvrtq_3(A,Gw,Q,Ts) 
%
% FUNCTION:
%   SIMPLIFIED cvrtq.m, USE 3nd-ORDER APPROXIMATION.
%
%   Determines covariance W of full-rank random sequence wd(k) that is 
%   equivalent to white noise w(t) having spectral density Q and 
%   distribution matrix Gw, with sampling time Ts, i.e. xdot = Ax + Gwùw 
%   is equivalent to x(k+1) = Phiùx(k) + wd(k) at t = kùTs.  
%   W=integral[Phi(t)ùGwùQùGw'ùPhi'(t)dt] over 0 to Ts; 
%
% SYNTAX:
%	[W,Phi]=cvrtq_3(A,Gw,Q,Ts);
%
% INPUT:
%	A	SYSTEM MATRIX
%	Gw	PROCESS NOISE MATRIX
%	Q	PROCESS NOISE POWER SPECTRUM DENSITY (PSD)
%	Ts	SAMPLING TIME (SEC.)
%
% OUTPUT:
%	W	DISCRETE EQUIVALENT PROCESS NOISE PSD.
%	Phi	DISCRETE EQUIVALENT SYSTEM MATRIX.
%

[ns,nd]=size(Gw); 

A2=A*A;
Phi=eye(ns)+A*Ts+A2*Ts*Ts/2;

BQ=Gw*Q*Gw';
ABQ=A*BQ;
ABA=(-ABQ+ABQ');
B3=(Ts*BQ+Ts^2*ABA/2)+Ts^3/6*(-A*ABA+BQ*A2');

W1=Phi*B3;
W=(W1+W1')/2;

