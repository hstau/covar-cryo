function X = get_data(ind2)
addpath /guam.raid.cluster.software/relion_more/matlab_lib/
addpath /guam.raid.home/liaoh/lib/matlab
addpath /guam.raid.home/liaoh/lib/matlab/PCAMV

ext = '.spi';
% read selfile
string=strcat('covar/sel_ang.spi');
S = readSPIDERdoc(string);
% pull out one group for noise estimation
j = S(1);
% list of particles for a group
string=strcat('covar/selfiles/prj_sel_',num2str(j,'%05d'),ext);
sel = readSPIDERdoc(string);
prj_head_s = 'covar/part_flip/sh_ffsar';
cov_noise = get_cov(prj_head_s,sel, ind2, 1, ext);
V = trace(cov_noise)/size(cov_noise,1)
for i = 1:size(S,1)
    j = S(i);
    % list of particles for an angle
    string=strcat('covar/selfiles/prj_sel_',num2str(j,'%05d'),ext);
    sel = readSPIDERdoc(string);
    % get the data for one group 
    prj_head = 'covar/part_flip/ffsar';
    par = read_data(prj_head,sel, ind2, i, ext);
    X{i} = par;
end
% start loop
save X X -v7.3
