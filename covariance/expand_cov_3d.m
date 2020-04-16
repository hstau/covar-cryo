function new_cov = compress_data(cov,ind3,v_dim)
addpath /guam.raid.home/liaoh/lib/matlab
%
NX = v_dim(1);
ss = NX^3;
NX2 = NX/2;
% decompose 
find3 = ind3{1};
cind3 = ind3{2};
%
II = [find(cind3);find(find3)]; % coordinates of good pixels
%
IC = size(find(cind3),1);
I =  size(II,1);
%
new_cov = zeros(NX^3);
% resize cov
cov = cov(:);
new_cov = new_cov(:);
%  
for i1 = 1:I  % i1 is new mapping
    % for every voxel
    i1
    ind1 = II(i1);
    F1 = obtain_abc(i1,IC,ind1,NX2,NX);  % ind1 is old mapping
    % the other voxel
    for i2 = i1:I
        ind2 = II(i2);
        ind = (i1-1)*I + i2;
        F2 = obtain_abc(i2,IC,ind2,NX2,NX);
        % combine
        F1a = repmat(F1,1,size(F2,1));  
        F2a = repmat(F2,1,size(F1,1));
        new_ind = (F1a-1)*ss + F2a';   
        new_ind = new_ind(:);
        % expand value
        new_cov(new_ind) = repmat(cov(ind),size(new_ind,1),1); 
    end
end

        
function F = obtain_abc(i,IC,ind,NX2, NX)  % i is new mapping, ind is old
if i <= IC %  for coarse part, need scaling: orig image -> scale3 -> cind3
    [a b c] = decomp3(ind-1,[NX2 NX2 NX2]);
    v = [2*a 2*b 2*c; 2*a+1 2*b 2*c; 2*a 2*b+1 2*c; 2*a+1 2*b+1 2*c;...  
         2*a 2*b 2*c+1; 2*a+1 2*b 2*c+1; 2*a 2*b+1 2*c+1; 2*a+1 2*b+1 2*c+1]; % all 8 possible
    a = v(:,1); b = v(:,2); c = v(:,3);
    F = sum([a b c].*repmat([1 NX NX*NX],size(a,1),1),2) + 1;
else
    F = ind;
end

