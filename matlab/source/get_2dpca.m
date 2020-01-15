function get_data() % type or typew % estimate the noise covariance using bootstrap method.
addpath /guam.raid.cluster.software/relion_more/matlab_lib/
addpath /guam.raid.home/liaoh/lib/matlab
addpath /guam.raid.home/liaoh/lib/matlab/extern

% threshold
th = 99;
ext = '.spi';
% read selfile
string=strcat('covar/sel_ang_pca288.spi');
S = readSPIDERdoc(string);
% read the mas for normalization
string=strcat('covar/mask_32',ext);
maski = readSPIDERfile(string);
% n of components
K = 6;
d = zeros(K,size(S,1));
v = zeros(size(maski(:),1),K,size(S,1));
%
% get noise cov using bootstrap
A = [];
parfor i = 1:size(S,1)
    i
    % selection file for the occupied angles
    j = S(i);
    % list of particles for an angle
    string=strcat('covar/selfiles_pca288/prj_sel_',num2str(j,'%05d'),ext);
    sel = readSPIDERdoc(string);
    if size(sel,1) > th
        A = [A; j];
        % get the 2d cov 
        prj_head = 'covar/part_flip_pca288/fsar';
        cov_2d = get_cov2(prj_head, maski, sel, ext);
        % get the shifted particles
        prj_head_s = 'covar/part_flip_pca288/sh_fsar';
        cov_noise = get_cov2(prj_head_s, maski, sel, ext);
        %
        cov_2d = cov_2d - cov_noise;
        %   pca
        [V D]=eig(cov_2d);
        DD = diag(D);
        d(:,i) = DD(end-K+1:end);
        v(:,:,i) = V(:,end-K+1:end);
        %
        % output result
        for k = 1:K
            out_head = strcat('covar/stats_pca288/pca_',num2str(j,'%05d'),'_pca',num2str(k,'%02d'), ext);
            writeSPIDERfile(out_head,reshape(V(:,k),size(maski,1),size(maski,2)));
        end
    end
end
save A A
save eigen_values d
save eigen_vectors v
%string=strcat('covar/sel_pca.spi');
%writeSPIDERdoc(string,A);


