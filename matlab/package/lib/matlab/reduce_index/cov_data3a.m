function get_data(ind2,type) % type or typew % estimate the noise covariance using bootstrap method.
addpath /guam.raid.cluster.software/relion_more/matlab_lib/
addpath /guam.raid.home/liaoh/lib/matlab
addpath /guam.raid.home/liaoh/lib/matlab/extern

ext = '.spi';
% read selfile
string=strcat('covar/sel_ang.spi');
S = readSPIDERdoc(string);
% read the mas for normalization
string=strcat('covar/mask_12',ext);
maski = readSPIDERfile(string);
string=strcat('covar/mask_12n',ext);
masko = readSPIDERfile(string);
% get noise cov using bootstrap
parfor i = 1:size(S,1)
    i
    % selection file for the occupied angles
    j = S(i);
    % list of particles for an angle
    string=strcat('covar/selfiles/prj_sel_',num2str(j,'%05d'),ext);
    
    sel = readSPIDERdoc(string);
    % test
    %string=strcat('covar/stats/var_',num2str(j,'%05d'),ext);
    %svar = readSPIDERfile(string);
    %string=strcat('covar/stats/var_',num2str(j,'%05d'),'.txt');
    %write_stack(string,j,svar);
    %test
    % get the 2d cov 
    prj_head = 'covar/part_flip/f1sar';
    cov_2d = get_cov(prj_head,sel, ind2, i, ext);
    % test
    %dd = diag(cov_2d);
    %dd= expand_data(dd,ind2,i,[32 32]);
    %save dd
    % test
    % get the shifted particles
    prj_head_s = 'covar/part_flip/sh_f1sar';
    cov_noise = get_cov_bootstrap(prj_head,prj_head_s,maski, masko,sel, ind2, i, ext);
    %
    % compare with neigh approach
    %cov_noise = get_cov_neigh(cov_2d, cov_noise, i, ind2, maski, masko);
    % normalize
    %cov_2d = cov_2d - cov_noise;
    % compare with neighborhood approach
    %i,i,i
    % get the shifted particles
    %prj_head = 'covar/part_flip/sh_fsar';
    % cov_sh =  get_cov(prj_head,sel, ind2, i, ext);
    % 
    %cov_noise = get_cov_neigh(cov_2d, cov_sh, i, ind2, maski, masko);
    cov_2d = cov_2d - cov_noise;
    cov_2d = cov_noise;
    cov_2d=cov_2d(:);
    % normalize
    %string=strcat('covar/stats/scovar_',type,num2str(j,'%05d'),'.txt'); % run
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
    out_head = strcat('covar/stats/f1NscovarA_',type);
    %string = strcat(out_head,num2str(j,'%05d'));
    %save(string,'cov_2d');
    write_image_stack(out_head,j,cov_2d);
end

