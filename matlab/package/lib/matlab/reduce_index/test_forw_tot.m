function test_forw(ind2,type)
addpath /guam.raid.cluster.software/relion_more/matlab_lib/
addpath /guam.raid.home/liaoh/lib/matlab

ext = '.spi';

% read angle sel file 
sel = readSPIDERdoc('covar/sel_ang.spi');
I = size(sel,1);

% read one image for the sizes
string=strcat('covar/stats_filt02/stats/rep_mask075',num2str(sel(1),'%05d'),ext);

image = readSPIDERfile(string);
p_dim(1) = size(image,1);
p_dim(2) = size(image,2);
v_dim(1) = size(image,1);
v_dim(2) = size(image,2);
v_dim(3) = size(image,2);


% loop
parfor i = 1:I % for each view (block-ART)
    i
    j = i;
    out = strcat('/data2/liaoh/new_with_covar_reduce_index_DHX_',type,'/big_tot_matlab/tot_',num2str(j,'%05d'));
    p = load(out);
    A = p.toti;
    array = ones(size(A,2),1);
    cov =  A*array;
    ss = sqrt(size(cov,1))
    cov = reshape(cov,ss,ss);
    var=get_diag2(cov,ind2,j);
    string=strcat('var_see_',type,'_',num2str(sel(j),'%05d'),ext);
    writeSPIDERfile(string,var);
    out_head = strcat('forw_',type);
    write_image_stack(out_head,sel(j),cov);
end

  
