clear all
% Note that it already applies the negtive 10 volts shift
% edit to where your files are stored
%this must also be in your matlab path
place_of_files = 'C:\Users\Jake\Desktop\all_files-Hotwire';

% Number of files that you have 
number_of_files = 257;

dir_help= '\lab2-';

% May have to change these numbers
X_in_dat = 32;
Y_in_dat = 33;
Z_in_dat = 34;
AOA_in_dat = 37;
V_in_dat = 72;

% The numbers above are the positions of the variables in the .dat files
% if these values are NAN or do not makes sense, 
% you have to go though the dat cell array that is imported into matlab and
% see which numbers are correct.
% use the command celldisp(dat) to easily see the data
% 

% CODE BELOW
% THIS SHOULD NOT HAVE TO BE EDITED

end_of_dir = '-1.txt'  ;
end_of_dat = '.dat';
%  text file number, x ,y ,z ,  AOA,speed, average of data - 10,
% strand devaiton of data in data readme 
% the actual data is stored in data array
for k = 1:number_of_files
    fprintf('Prossing %d of %d text files\n',k,number_of_files);
    file_name = strcat(place_of_files,dir_help,int2str(k),end_of_dir);
    fileID = fopen(file_name);
    C = textscan(fileID, '%s' );
    fclose(fileID);
    data_readme(k,1) = k;
    for i = 1:1000
        j = 2*i + 3;
        l = i;
        data_one = C{1}{j};
        data(k,l) = str2num(data_one) -10 ;
    end 
    file_name_dat = strcat(place_of_files,dir_help,int2str(k),end_of_dat);
    fileID = fopen(file_name_dat);
    dat = textscan(fileID, '%s' );
    fclose(fileID);
    commentstrings{1,k} = dat{1}{9};
    commentstrings{2,k} = k;
%     x
    temp = dat{1}{X_in_dat};
    temp2 = strsplit(temp,',');
    t = temp2{1};
    X(k) = str2double(t) ;
%     y
    temp = dat{1}{Y_in_dat};
    temp2 = strsplit(temp,',');
    t = temp2{1};
    Y(k) = str2double(t) ;
%     z
    temp = dat{1}{Z_in_dat};
    temp2 = strsplit(temp,',');
    t = temp2{1};
    Z(k) = str2double(t) ;
%     AOA
    temp = dat{1}{AOA_in_dat};
    AOA(k) = str2double(temp);   
%     speed
    temp = dat{1}{V_in_dat};
    velocity(k) = str2double(temp); 
%     average of data
    AVG(k) = mean(data(k,1:end))- 10;
%   starnd deviation  
    STD(k) = std(data(k,1:end));
    
end 

commentstrings = commentstrings';
X = X';
Y = Y';
Z = Z';
AOA = AOA';
velocity = velocity';
AVG = AVG';

if(isnan(AOA(1)||isnan(X(1)) || isnan(Y(1))|| isnan(Z(1)) || isnan(velocity(1))))
   fprintf('Warning something was Not a Number\n');
   fprintf('check which variable was (X,Y,Z,AOA,velocity)\n');
   fprintf('then use celldisp(dat) to see where the actual data is\n');
   fprintf('then edit lines 13 to 17 and try again\n');
   fprintf('Any questions let me know');
   
end
