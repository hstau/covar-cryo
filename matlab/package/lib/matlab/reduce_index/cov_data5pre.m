function get_data()  % estimate the noise covariance using bootstrap method.
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
    prj_head = 'covar/part_flip/fsar';
    cov_2d = get_cov1(prj_head,sel, ext);
    out_head = 'covar/stats/scovar_';
    write_image_stack(out_head,j,cov_2d);
    % test
    %dd = diag(cov_2d);
    %dd= expand_data(dd,ind2,i,[32 32]);
    %save dd
    % test
    % get the shifted particles
    prj_head_s = 'covar/part_flip/sh_fsar';
    cov_noise = get_cov_bootstrap1(prj_head,prj_head_s,maski, masko,sel,ext);
    out_head = 'covar/stats/scovar_back';
    write_image_stack(out_head,j,cov_noise);
    %
end

