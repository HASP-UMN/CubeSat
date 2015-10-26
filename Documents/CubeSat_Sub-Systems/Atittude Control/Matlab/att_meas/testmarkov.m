% Script to test the getmarkov function and also
% see if I have got my head screwed on right
% regarding Markov processes.
%
% Last Modified: 1/17/00
%

clear all;
close all;
clc

tau = 45;
sigma = pi;
Ts = 1/25;
Tf = 500;
t = [0:Ts:Tf];
n = length(t);

%% Case #1 ---> x_dot = (-1/tau)*x + (1/tau)*w

%F = -1/tau;
%G = 1/tau;
%Rw = tau*tau*sigma;%
%
%
%Phi = expm(F*Ts);
%Cd  = disrw(F,G,Ts,Rw);%
%
%P1 = zeros(n,1);
%p1 = P1;

%for k=2:n

 %   P1(k) = Phi*P1(k-1)*Phi' + Cd;
 %   p1(k) = sqrt(P1(k));

%end

%disp('First Case Monte-Carlo Simulation');

lp = 1000;

%x1 = zeros(n,lp);

%for k=1:lp
%    x1(:,k) = getmarkov(sigma,tau,Ts,Tf);
%end

% Case #2 ---> x_dot = (-1/tau)*x + w;

F = -1/tau;
G = 1;
Rw = 2*sigma*sigma/tau;

Phi = expm(F*Ts);
Cd  = disrw(F,G,Ts,Rw);

P2 = zeros(n,1);
p2 = P2;

for k=2:n

    P2(k) = Phi*P2(k-1)*Phi' + Cd;
    p2(k) = sqrt(P2(k));

end

disp('Second Case Monte-Carlo Simulation');


x2 = zeros(n,lp);

for k=1:lp
    x2(:,k) = getmarkov(sigma,tau,Ts,Tf);
    if (mod(k,100) == 0)
        clc;
        disp(' ');
        disp(['  Case #2',num2str(k),' Loops Completed.']);
    end    
end


% Case #3 ---> x_dot = (-1/tau)*x + w but use disrw


%figure(gcf)
%subplot(121)
%plot(t,p1,'r-',t,-p1,'r-');
%hold on;

%for k = 1:lp
%    plot(t,x1(:,k),'b-');
%    hold on;
%end

%title('x-dot = -x/tau + w/tau');
%ylabel('\sigma');
%xlabel('Time (sec)');
%grid;

%subplot(122)


for k = 1:lp
    plot(t,x2(:,k),'b-');
    hold on;
end
plot(t,p2,'r-',t,-p2,'r-');
hold on;
title('x-dot = -x/tau + w');
ylabel('\sigma');
xlabel('Time (sec)');
grid














