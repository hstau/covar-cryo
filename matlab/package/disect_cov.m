function trace(ii,coord,array,ind3,type)
% DISECT_COV computes the covariance map with respect to a point located at coord corresponding to a 3D covariance named 'array' 
% Author:
% 	Hstau Liao
% 	Columbia University
%	Frank Lab
%	hstau.y.liao@gmail.com
%	
% Tested:	
%	MATLAB2013a
% Copyright notice: You are free to modify, extend and distribute 
%    this code granted that the author of the original code is 
%    mentioned as the original author of the code.


ext = '.spi';
% sizes
N1 = size(array,1);
N = sqrt(N1);
cind3 = ind3{2};
S = size(cind3,1);
NX2 = round(S^(1/3));
NX = 2*NX2;
v_dim(1) = NX;
v_dim(2) = NX;
v_dim(3) = NX;
%
a = coord(1);
b = coord(2);
c = coord(3);
%
low = ([1:ii]-1)*N + ii;
high = (ii-1)*N + [ii+1 : N]; % array is NOT symmetric by construction !!
all = [low high];
var = full(array(all));
result = expand_volume(var,ind3,v_dim);
if(size(find(ind3{1})) == 0)
    result = scale3(result);
end
cc = result;
[mm I] = max(cc(:));
cc(I) = mean(cc(:));
%result = smooth3(result,'gaussian',[3 3 3],std);
%cc = smooth3(cc,'gaussian',[3 3 3],std);
pv = sort(cc(:));
mmin = -0.5*(pv(1)+pv(2))
mmax = 0.5*(pv(end-1)+pv(end-2))
suffix = strcat(type,'_',num2str(a,'%02d'),'_',num2str(b,'%02d'),'_',num2str(c,'%02d'),ext);
string = strcat('matlab_result_',suffix);
writeSPIDERfile(string,result);
string = strcat('neg_matlab_result_',suffix);
writeSPIDERfile(string,-result);
% test 
var = var(:);
var(:) = 0;
var(ii) = 1;
result = expand_volume(var,ind3,v_dim);
string = strcat('test_',suffix);
writeSPIDERfile(string,result);
% get the diagonal elements
all = ([1:N]-1)*N + [1:N];
var = full(array(all));
result = expand_volume(var,ind3,v_dim);
if(size(find(ind3{1})) == 0)
    result = scale3(result);
end
string = strcat('matlab_3dvar', type,ext);
writeSPIDERfile(string,result);

