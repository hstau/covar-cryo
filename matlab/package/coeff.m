function coeff(mat,sel_ang,coeff_pref, v_dim, p_dim)
% COEFF computes the coefficients of the system matrix that solves the 3D covariance given the 2D covariance
% 
% Input:
%       mat        - cell, length of intersection of lines passing through coarse and fine voxels
%	sel_ang    - string, name of file containing the indices of angle bins
% 	coeff_pref - string, rootname of files containing the coefficients per bin angle (output)
%   	v_dim      - array, dimensions of volume at final resolution 
%   	p_dim      - array, dimensions of image  at final resolution
%
% 
% Author:
% 	Hstau Liao
% 	Columbia University
%	Frank Lab
%	hstau.y.liao@gmail.com
%	
%
% Copyright notice: You are free to modify, extend and distribute 
%    this code granted that the author of the original code is 
%    mentioned as the original author of the code.

string=strcat(sel_ang);
S = readSPIDERdoc(string);
N = size(mat{1},2);
N1 = N*N;
parfor i = 1:size(mat,2)  
    %if(mod(i,100)==0)
        i
    %end
    cc = []; % concatenated rays
    lab_pix = []; % pixel labels of the concatenation 
    lab_vox = []; % voxel labels of the concatenation 
    J = size(mat{i},1)
    % concatenate all the non-empty ray
    for j = 1:J
        ray = mat{i}(j,:); % 1X N sparse matrix
        ind = find(ray);
        fray = full(ray(ind));
        if size(fray,2) > 0
            cc = [cc fray];
            lab_vox = [lab_vox ind];
            lab_pix = [lab_pix j*ones(1,size(fray,2))];
        end
    end
    M = size(mat{i},1);
    M1 = M*M;
    % expa is a coo matrix
    expa = expand(lab_pix,lab_vox,cc,N,M);     
    %write1(expa,i);
    % crate a sparse matrix for better memory management    
    row = expa(:,1);  
    col = expa(:,2);
    w = expa(:,3);
    toti = sparse(row,col,w,M1,N1);  
    out = strcat(coeff_pref,num2str(i,'%05d'));
    write2(out,toti,i);
    %get_norm_toti_input(type,toti,S(i));
    toti = [];
end


function expa = expand(lab,lv,cc, N,M)

[i j w] = find(cc); % cc is a sparse row matrix; w is a row vector
% compute the corresponding weights
w1 = w'*w;
%w1=2*w1-diag(diag(w1)); % the extra-diag elements must be doubled; N/A!
% created new "ray"
[i j w1] = find(triu(w1));

% grand multiplication for the voxel indices
lv = lv - 1; % must start from 0
ll = size(lv,2); % this should equal the size of lab
in2 = N*repmat(lv,ll,1) + repmat(lv',1,ll) + 1; 
[i j in2] = find(triu(in2));   % only the upper triag portion

% now the ray indices
lab = lab - 1; % must start from 0; lab is 1xN
ll = size(lab,2); % this should equal the size of lab
ind = M*repmat(lab,ll,1) + repmat(lab',1,ll) + 1; 
[i j ind] = find(triu(ind));   % only the upper triag portion

% put together
expa = [ind in2 w1];
