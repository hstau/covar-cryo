function [X PM] = get_data(amat, ind2)
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
% number of data points
good = readSPIDERdoc('covar/goodparticles.spi');
n = size(good,1);
% allocate mem for data vector
sz = zeros(size(S)); % vector of sizes
for i = 1:size(S,1)
    at = amat{i};
    sz(i) = size(at,1);
end
X = sparse(sum(sz),n);
% construct PM
PM = sparse(sum(sz),size(at,2));
os = 0;
%=for i = 1:size(S,1)
%=    PM(os+1:os+sz(i),:) = amat{i};
%=    os = os + sz(i);
%=end
clear amat
% start loop
os = 0;
ot = 0;
for i = 1:size(S,1)
    i
    % selection file for the occupied angles
    j = S(i);
    % list of particles for an angle
    string=strcat('covar/selfiles/prj_sel_',num2str(j,'%05d'),ext);
    sel = readSPIDERdoc(string);
    % get the data for one group 
    prj_head = 'covar/part_flip/ffsar';
    par = read_data(prj_head,sel, ind2, i, ext);
    %whos par 
    %sz(i)
    %ss=size(sel,1)
    X(os+1:os+sz(i),ot+1:ot+size(sel,1)) = par;
    os = os + sz(i);
    ot = ot + size(sel,1);
end
%=save PM PM -v7.3
save X X -v7.3
