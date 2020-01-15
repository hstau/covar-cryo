function [d0,d1,l1,l2,l3,ll1,ll2,ll3] = fneigh(cov, i, ind2, mask)
% size of cov_noise
M = size(cov,1);
% get the size
cind2 = ind2{2};
cind2 = cind2(:,i);
%
I = size(find(cind2),1); 
% get the neighbor masks
nmask = pair_neighbor_mask(cov, i, ind2);
n1 = nmask{2};
n2 = nmask{3};
n3 = nmask{4};
nn1 = nmask{12};
nn2 = nmask{13};
nn3 = nmask{14};
%yes=isequal(n1,nn1)
% test
%k1 = sum(n1);
%k1 = k1 > 0;
%k1= expand_data(k1,ind2,i,[32 32]);
%save k1
% extend the mask
mask = compress_data(mask,ind2, i);
emask = mask*mask';
cov = cov.*emask;
% masked values
l1 = cov.*n1;
l2 = cov.*n2;
l3 = cov.*n3;
ll1 = cov.*nn1;
ll2 = cov.*nn2;
ll3 = cov.*nn3;
% diagonal elements
dd = diag(cov);
% averages
if size(dd(1:I),1) == 0 d0 = 0;
else
    data = dd(1:I);
    d0 = mean(data)
    get_stat(data);
end
if size(dd(I+1:end),1) == 0 d1 = 0;
else
    data = dd(I+1:end); 
    d1 = mean(data)
    get_stat(data);
end
if size(find(l1),1) == 0 m1 = 0;    
else
    data = l1(find(l1));
    m1 = mean(data)
    get_stat(data);
end
if size(find(l2),1) == 0 m2 = 0;
else
    data = l2(find(l2)); 
    m2 = mean(data)
    get_stat(data);
end
if size(find(l3),1) == 0 m3 = 0;
else
    data = l3(find(l3)); 
    m3 = mean(data)
    get_stat(data);
end
if size(find(ll1),1) == 0 mm1 = 0;
else
    data = ll1(find(ll1)); 
    mm1 = mean(data)
    get_stat(data);
end
if size(find(ll2),1) == 0 mm2 = 0;
else
    data = ll2(find(ll2)); 
    mm2 = mean(data)
    get_stat(data);
end
if size(find(ll3),1) == 0 mm3 = 0;
else
    data = ll3(find(ll3));
    mm3 = mean(data)
    get_stat(data);
end

% weighted mask
l1 = m1*n1;         % vector
l2 = m2*n2; 
l3 = m3*n3;
ll1 = mm1*nn1;
ll2 = mm2*nn2; 
ll3 = mm3*nn3;

function get_stat(data)
%mea = mean(data);
%st = std(data);
%Min=min(data);
%Max=max(data);
%whos data
[std(data) min(data) max(data)]
