function write_image_stack(head,j,data)
%addpath /home/liaoh/lib/matlab

string = strcat(head,num2str(j,'%05d'),'.txt');
fid=fopen(string,'w');
fprintf(fid, '%f \n', data(:));
fclose(fid);
