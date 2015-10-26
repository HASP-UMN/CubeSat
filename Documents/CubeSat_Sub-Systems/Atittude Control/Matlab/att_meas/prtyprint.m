function prtyprint(n)

figure(n);
orient tall;
orient landscape
print -dpsc -Pdragonprt;

disp(' ');
disp(['Figure(',int2str(n),') is being printed.']);
