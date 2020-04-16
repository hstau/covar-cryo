function result = expand_data(da,ind2,j,p_dim)
%addpath /home/liaoh/lib/matlab

find2 = ind2{1};
cind2 = ind2{2};
cind2 = cind2(:,j);
find2 = find2(:,j);
M = p_dim(1) * p_dim(2);
result = zeros(M,1);
result2 = zeros(M/4,1);
% coarse grid
I = find(cind2);
result2(I) = da(cind2(I));
result = fillin2(result2);
% fine grid
I = find(find2);
result(I) = da(find2(I));
%
result = reshape(result,p_dim(1),p_dim(2));