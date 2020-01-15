function trace(sel,ii,coord,array,ind2,ind3,type,amat)
addpath /guam.raid.home/liaoh/lib/matlab
addpath /guam.raid.cluster.software/relion_more/matlab_lib/
ext = '.spi';
% coord
a = coord(1);
b = coord(2);
c = coord(3);
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
p_dim(1) = NX;
p_dim(2) = NX;
% project
array = zeros(NX,NX,NX);
array = compress_volume(array,ind3,v_dim); 
array(ii) = 1;
for i=1:size(sel,1)
    if mod(i,100) == 0
        i
    end
    j = sel(i);
    A = amat{i};
    prj = A*array;
    [val,ind] = sort(prj(:)); 
    pix = ind(end);         % projected voxel
    string=strcat('covar/stats/fscovarA_',type,num2str(j,'%05d'),'.txt'); % load the 2d cov 
    cov_2d = load(string);
    M = sqrt(size(cov_2d,1));   % get the total number of pix
    cov_2d = reshape(cov_2d,M,M);
    all = (pix*ones(1,M)-1)*M + [1:M];  % get all the pixels wrt to the proj voxel
    var = cov_2d(all);                      
    result = expand_data(var,ind2,i,p_dim);   
    suffix = strcat(type,'_',num2str(a,'%02d'),'_',num2str(b,'%02d'),'_',num2str(c,'%02d'));
    string = strcat('2dcov/2dcov','_',suffix, '_',num2str(j,'%04d'),ext);
    writeSPIDERfile(string,result);
    % compare with prj
    result = expand_data(prj,ind2,i,p_dim);
    string = strcat('2dcov/2dprj','_',suffix, '_',num2str(j,'%04d'),ext);
    writeSPIDERfile(string,result);
end
