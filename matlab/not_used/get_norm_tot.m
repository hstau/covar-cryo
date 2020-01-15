function get_data(type)  
addpath /guam.raid.cluster.software/relion_more/matlab_lib/
addpath /guam.raid.home/liaoh/lib/matlab
%
ext = '.spi';
% read selfile
string=strcat('covar/sel_ang.spi');
S = readSPIDERdoc(string);
% 
parfor i = 1:size(S,1)
    i
    get_norm_toti(type,S,i);
end  
