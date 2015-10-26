function [h]=barplot(x,y,z)
%barplot(x,y,z) creates a three dimensional bar plot at 
%the specified values in x, y, z
%
%As an example, the commands
%x=rand(1,10);
%y=rand(1,10);
%z=rand(1,10);
%barplot(x,y,z);
%plots a 3-D bar plot of x, y and z

%Copyright (c) 1984-98 by The MathWorks, Inc.
%
%  Vincent Hodges 10/29/98

xdiff=min(abs(diff(x)))/2;
ydiff=min(abs(diff(y)))/2;
mindiff=min(xdiff,ydiff);
for i=1:length(x)
   xnewp=x(i)+mindiff;
   xnewn=x(i)-mindiff;
   ynewp=y(i)+mindiff;
   ynewn=y(i)-mindiff;
   
   vertices=[xnewn ynewn 0;...
      xnewn ynewp 0;...
      xnewp ynewp 0;...
      xnewp ynewn 0;...
      xnewn ynewn z(i);...
      xnewn ynewp z(i);...
      xnewp ynewp z(i);...
      xnewp ynewn z(i)];
      
      faces=[1 5 8 4
         1 5 6 2
         2 6 7 3
         4 8 7 3
         5 6 7 8
         1 2 3 4];
      
      %axes('nextplot','replacechildren');
      h(i)=patch('vertices',vertices,'faces',faces);
      %      set(h(i),'facecolor',rand(1,3));
      if (z(i) <= 10)
          set(h(i),'facecolor','r');
      elseif(z(i) > 10 & z(i) <= 20);
          set(h(i),'facecolor','b');
      elseif(z(i) > 20 & z(i) <= 30);
          set(h(i),'facecolor','g');
      elseif(z(i) > 30 & z(i) <= 40);
          set(h(i),'facecolor','c');
       elseif(z(i) > 40 & z(i) <= 50);
          set(h(i),'facecolor','m');
       elseif(z(i) > 50);
          set(h(i),'facecolor','y');
      end
      
   end
   view(3);
   grid;
