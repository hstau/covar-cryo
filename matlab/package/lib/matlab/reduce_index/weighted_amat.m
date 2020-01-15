function arr = weighted(array,ind3,ft)
% sizes
N1 = size(array,1);
cind3 = ind3{2};
find3 = ind3{1};
S = size(find(cind3),1);
%
arr = zeros(N1,1);
arr(1:S) = array(1:S);
arr(S+1:end) = ft*array(S+1:end);
