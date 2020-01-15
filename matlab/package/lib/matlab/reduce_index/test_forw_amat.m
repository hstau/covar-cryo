function test_forw(ind2,ind3,amat)
addpath /guam.raid.cluster.software/relion_more/matlab_lib/
addpath /guam.raid.home/liaoh/lib/matlab

ext = '.spi';

% read angle sel file 
sel = readSPIDERdoc('covar/sel_ang.spi');
I = size(sel,1);

% read one image for the sizes
string=strcat('covar/stats_filt02/stats/rep_mask03',num2str(sel(1),'%05d'),ext);

image = readSPIDERfile(string);
p_dim(1) = size(image,1);
p_dim(2) = size(image,2);
v_dim(1) = size(image,1);
v_dim(2) = size(image,2);
v_dim(3) = size(image,2);

% read data for comparison against forward proj
prj = zeros(size(image,1),size(image,2),size(sel,1));
% read the images
for i = 1:I
    j = sel(i);
    %string=strcat('dif/sreprem_',num2str(j,'%05d'),'.spi'); % run with mask
    %string=strcat('covar/stats/ave_',num2str(j,'%05d'),ext);% run wo mask
    string=strcat('covar/stats_filt02/stats/rep_mask075',num2str(j,'%05d'),ext);
    prj(:,:,i) = readSPIDERfile(string);
end
save prj
% initial volume
string = '/guam.raid.home/liaoh/2D_var_DHX/new_with_covar_reduce_index_DHX/sfvol_var_perc030_mask.spi';
init = readSPIDERfile(string);
init = permute(init,[2 1 3]);
whos init
array = compress_volume(init, ind3, v_dim);
array = ones(size(array));

% loop
for i = 1:I % for each view (block-ART)
    j = i;
    A = amat{j};
    proj =  A*array;
    %proj = expand_data(proj,ind2,j,p_dim);
    string=strcat('forw_mix_',num2str(sel(j),'%05d'),ext);
    writeSPIDERfile(string,proj);
    % compare with data
    data = prj(:,:,j);
    %da = compress_data(data, ind2, j);
    %date = expand_data(da,ind2,j,p_dim);
    date = data;
    string=strcat('exp_data_mix_',num2str(sel(j),'%05d'),ext);
    writeSPIDERfile(string,date);
end

  
