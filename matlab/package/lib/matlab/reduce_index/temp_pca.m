function get_data() % type or typew % estimate the noise covariance using bootstrap method.
addpath /guam.raid.cluster.software/relion_more/matlab_lib/
addpath /guam.raid.home/liaoh/lib/matlab
addpath /guam.raid.home/liaoh/lib/matlab/extern

ext = '.spi';
% read selfile
string=strcat('covar/sel_ang.spi');
S = readSPIDERdoc(string);
% read the mas for normalization
% n of components
K = 6;
%
string=strcat('covar/mask_32',ext);
maski = readSPIDERfile(string);
% get noise cov using bootstrap
parfor i = 1:size(S,1)
    i
    % output result
    j = S(i);
    k=1;
    out_head = strcat('covar/stats/spca_',num2str(j,'%05d'),'_pca',num2str(k,'%02d'), ext);
    V=readSPIDERfile(out_head);
    for k = 1:K
        out_head = strcat('covar/stats/pca_',num2str(j,'%05d'),'_pca',num2str(k,'%02d'), ext);
        v = reshape(V(:,k),size(maski,1),size(maski,1));
        writeSPIDERfile(out_head,v);
    end
end
