function get_data(ind2,type)  % estimate the noise covariance using bootstrap method.
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
    %string=strcat('covar/stats_fine/norm_scovar_',num2str(j,'%05d'),'.txt'); % run
    string=strcat('covar/stats/scovar_',num2str(j,'%05d'),'.txt'); % run
    cov = load(string);
    %
    %get_diag_full(cov,'var_sig.spi');
    %
    string=strcat('covar/stats/scovar_back',num2str(j,'%05d'),'.txt'); % run
    cov_noise = load(string);
    %
    %get_extra_diag_full(cov_noise,300,'var_extra_back.spi');
    %get_diag_full(cov_noise,'var_back.spi');
    %
    % correct for the background
    cov = cov - cov_noise;% ones(size(cov)); %
    % compress
    cov = compress_cov1(cov,ind2, i);
    % correct for the tot
    %string=strcat('covar/stats_fine/norm_scovar_',num2str(j,'%05d'),'.txt'); % run
    string=strcat('covar/stats/norm_scovar_',type,num2str(j,'%05d'),'.txt'); % run
    ll = load(string);
    %
    %ss = sqrt(size(ll,1))
    %ll = reshape(ll,ss,ss);
    %var=get_diag2(ll,ind2,i);
    %writeSPIDERfile('var_norm.spi',var);
    %ll = ll(:);
    %
    cov = cov.*ll;
    %
    %ss = sqrt(size(ll,1))
    %cov = reshape(cov,ss,ss);
    %var=get_diag2(cov,ind2,i);
    %writeSPIDERfile('var_sig_weighted.spi',var);
    %
    % output result
    %out_head = 'covar/stats_fine/scovar_';
    out_head = strcat('covar/stats/scovar_',type);
    %string = strcat(out_head,num2str(j,'%05d'));
    %save(string,'cov_2d');
    write_image_stack(out_head,j,cov);
end

