function var = get_diag(array,ind3)
%addpath /home/liaoh/lib/matlab

% sizes
N1 = size(array,1);
N = sqrt(N1);
%
find3 = ind3{1};   % recall szie(cind2,2)=195
S = size(find3,1);
NX = round(S^(1/3));
v_dim(1) = NX;
v_dim(2) = NX;
v_dim(3) = NX;
%
all = ([1:N]-1)*N + [1:N];
var = array(all);
var = expand_volume(var,ind3,v_dim);