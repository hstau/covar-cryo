function arr = weighted(array,ind3)
% sizes
N1 = size(array,1);
N = sqrt(N1);
cind3 = ind3{2};
find3 = ind3{1};
S = size(find(cind3),1);
%
array = reshape(array,N,N);
arr = zeros(N);
arr(1:S,1:S) = array(1:S,1:S);
arr(S+1:end,S+1:end) = 4*array(S+1:end,S+1:end);
arr(1:S,S+1:end) = 2*array(1:S,S+1:end);
arr(S+1:end,1:S) = 2*array(S+1:end,1:S);
arr = arr(:);