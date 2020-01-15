function expand_cov(amat, type,v_dim, p_dim)
addpath /guam.raid.home/liaoh/2D_var_simul_xabier/data/both/covar/lib
addpath /guam.raid.home/liaoh/lib/matlab
string=strcat('covar/sel_ang.spi');
S = readSPIDERdoc(string);
% total number of voxles 
%N = v_dim(1) * v_dim(2) * v_dim(3);
% max number of rays
%M = p_dim(1) * p_dim(2);
% tot contains all the covariances for all the rays from all the views
% ray contains all the voxels from one ray: a 1xN sparse matrix
% for each view
N = size(amat{1},2);
N1 = N*N;
parfor i = 1:size(amat,2)  
    %if(mod(i,100)==0)
        i
    %end
    cc = []; % concatenated rays
    lab_pix = []; % pixel labels of the concatenation 
    lab_vox = []; % voxel labels of the concatenation 
    J = size(amat{i},1)
    % concatenate all the non-empty ray
    for j = 1:J
        ray = amat{i}(j,:); % 1X N sparse matrix
        ind = find(ray);
        fray = full(ray(ind));
        if size(fray,2) > 0
            cc = [cc fray];
            lab_vox = [lab_vox ind];
            lab_pix = [lab_pix j*ones(1,size(fray,2))];
        end
    end
    M = size(amat{i},1);
    M1 = M*M;
    % expa is a coo matrix
    expa = expand(lab_pix,lab_vox,cc,N,M);     
    %write1(expa,i);
    % crate a sparse matrixmatlab cannot handle this much memory    
    row = expa(:,1);  
    col = expa(:,2);
    w = expa(:,3);
    toti = sparse(row,col,w,M1,N1);  
    out = strcat('/data2/liaoh/new_with_covar_reduce_index_DHX_',type,'w/big_tot_matlab/tot_',num2str(i,'%05d'));
    write2(out,toti,i);
    get_norm_toti_input(type,toti,S(i));
    toti = [];
end


function expa = expand(lab,lv,cc, N,M)

[i j w] = find(cc); % cc is a sparse row matrix; w is a row vector
% compute the corresponding weights
w1 = w'*w;
%w1=2*w1-diag(diag(w1)); % the extra-diag elements must be doubled; N/A!
% created new "ray"
[i j w1] = find(triu(w1));

% grand multiplication for the voxel indeces
lv = lv - 1; % must start from 0
ll = size(lv,2); % this should equal the size of lab
in2 = N*repmat(lv,ll,1) + repmat(lv',1,ll) + 1; 
[i j in2] = find(triu(in2));   % only the upper triag portion

% now the ray indeces
lab = lab - 1; % must start from 0; lab is 1xN
ll = size(lab,2); % this should equal the size of lab
ind = M*repmat(lab,ll,1) + repmat(lab',1,ll) + 1; 
[i j ind] = find(triu(ind));   % only the upper triag portion

% put together
expa = [ind in2 w1];
