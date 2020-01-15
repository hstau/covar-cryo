function disect_coord(coord,array,ind3,type)
% sizes
N1 = size(array,1);
N = sqrt(N1);
cind3 = ind3{2};
find3 = ind3{1};
S = size(cind3,1);
NX2 = round(S^(1/3));
NX = 2*NX2;
v_dim(1) = NX;
v_dim(2) = NX;
v_dim(3) = NX;
% first check if it is in the fine area
a = coord(1);
b = coord(2);
c = coord(3);
a1 = a-1;
b1 = b-1;
c1 = c-1;
indf = sum([1 NX NX*NX].*[a1+1 b1 c1]);
ii = find3(indf);
% if it is not in the fine area
if ii == 0
    a1 = floor(a/2);
    b1 = floor(b/2);
    c1 = floor(c/2);
    indc = sum([1 NX2 NX2*NX2].*[a1+1 b1 c1]);
    ii = cind3(indc);
end
% result
ii
disect_cov(ii,coord,array,ind3,type);