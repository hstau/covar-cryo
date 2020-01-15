function [prj,array]=trace(ind2,ind3,lambda,amat)
addpath /guam.raid.home/liaoh/lib/matlab
addpath /guam.raid.cluster.software/relion_more/matlab_lib/
ext = '.spi';

% read angle sel file 
sel = readSPIDERdoc('covar/sel_ang.spi');
I = size(sel,1);
% read one resized image and its size
% string=strcat('dif/sreprem_',num2str(sel(1),'%05d'),'.spi');% run with mask
string=strcat('covar/stats/var_',num2str(sel(1),'%05d'),ext); % run wo mask
image = readSPIDERfile(string);
% allocate projection data array
prj = zeros(size(image,1),size(image,2),size(sel,1));
% read the images
for i = 1:I
    j = sel(i);
    %string=strcat('dif/sreprem_',num2str(j,'%05d'),'.spi'); % run with mask
    string=strcat('covar/stats/ave_',num2str(j,'%05d'),ext);% run wo mask
    prj(:,:,i) = readSPIDERfile(string);
end
save prj
p_dim(1) = size(image,1);
p_dim(2) = size(image,2);
v_dim(1) = size(image,1);
v_dim(2) = size(image,2);
v_dim(3) = size(image,2);
%
M = size(amat{1},1);
N = size(amat{1},2);
% initial array
array = zeros(N,1);
% iterate
rng(1);
report = zeros(100,1);
for n = 1:20
    n
    resid = 0;
    J = randperm(I);
    for i = 1:I % for each view (block-ART)
        j = J(i);
        data = prj(:,:,j);
        da = compress_data(data, ind2, j);
        %test
        %p_dim(1)=size(data,1);
        %p_dim(2)=size(data,2);
        %date = expand_data(da,ind2,j,p_dim);
        %string=strcat('exp_data_',num2str(sel(j),'%05d'),ext);
        %writeSPIDERfile(string,date);
        %
        A = amat{j};
        array = array + lambda*A'*(da - A*array);
        resid = resid + norm(da - A*array);
    end
    resid
    report(n) = resid;
end
string = strcat('report_amat_040');
save(string,'report','-ascii');
array = expand_volume(array,ind3,v_dim);
writeSPIDERfile('matlab_result_amat_040.spi',array);

