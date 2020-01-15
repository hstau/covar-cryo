function result = expand_volume(array,ind3,v_dim)
%addpath /home/liaoh/lib/matlab

find3 = ind3{1};
cind3 = ind3{2};
N = v_dim(1) * v_dim(2) * v_dim(3);
result = zeros(N,1);
result2 = zeros(N/8,1);
% coarse grid
I = find(cind3);
result2(I) = array(cind3(I));
result = fillin3(result2);
% fine grid
I = find(find3);
result(I) = array(find3(I));
%
result = reshape(result,v_dim(1),v_dim(2),v_dim(3));
%result = permute(result,[2 1 3]);  why permute?
