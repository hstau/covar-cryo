function get_data(ind2,type) % type or typew % estimate the noise covariance using bootstrap method.
addpath /guam.raid.cluster.software/relion_more/matlab_lib/
addpath /guam.raid.home/liaoh/lib/matlab
addpath /guam.raid.home/liaoh/lib/matlab/extern

ext = '.spi';
% read selfile
string=strcat('covar/sel_ang.spi');
S = readSPIDERdoc(string);
% get 200 noise only particles
sel_head = 'covar/selfiles/prj_sel_';
prj_head_s = 'covar/part_flip/sh_f1sar';
part = get_noise_part(S,sel_head,prj_head_s,ext);
whos part
% read the mas for normalization
%string=strcat('covar/mask_12',ext);
%maski = readSPIDERfile(string);
%string=strcat('covar/mask_12n',ext);
%masko = readSPIDERfile(string);
% main loop
parfor i = 1:size(S,1)
    i
    % selection file for the occupied angles
    j = S(i);
    % list of particles for an angle
    string=strcat('covar/selfiles/prj_sel_',num2str(j,'%05d'),ext);
    sel = readSPIDERdoc(string);
    % get the 2d cov 
    prj_head = 'covar/part_flip/f1sar';
    cov_2d = get_cov(prj_head,sel, ind2, i, ext);
    % noise
    cov_noise = get_covn(part,ind2, i, ext);
    cov_2d = cov_2d - diag(diag(cov_noise));
    %cov_2d = cov_noise;
    cov_2d=cov_2d(:);
    % normalize
    %string=strcat('covar/stats/norm_scovar_',type,num2str(j,'%05d'),'.txt'); % run
    %ll = load(string);
    %
    %ss = sqrt(size(ll,1))
    %ll = reshape(ll,ss,ss);
    %var=get_diag2(ll,ind2,i);
    %writeSPIDERfile('var_norm.spi',var);
    %ll = ll(:);
    %
    %cov_2d = cov_2d.*ll;
    % output result
    %out_head = 'covar/stats_fine/scovar_';
    out_head = strcat('covar/stats/zcovar_',type);
    %string = strcat(out_head,num2str(j,'%05d'));
    %save(string,'cov_2d');
    write_image_stack(out_head,j,cov_2d);
end

