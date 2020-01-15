function amat=trace(ind2, ind3)
addpath /guam.raid.home/liaoh/lib/matlab
addpath /guam.raid.cluster.software/relion_more/matlab_lib/
ext = '.spi';
% read angle sel file 
sel = readSPIDERdoc('covar/sel_ang.spi');
I = size(sel,1)
% read the angles
refang = readSPIDERdoc('covar/refangles.spi');
ang = refang(sel,1:3);
% read one resized image and its size
good = readSPIDERdoc('covar/goodparticles.spi');
string=strcat('covar/part_flip/fsar',num2str(good(1),'%06d'),ext);
image = readSPIDERfile(string);
% sizes
p_dim(1) = size(image,1);
p_dim(2) = size(image,2);
v_dim(1) = size(image,1);
v_dim(2) = size(image,2);
v_dim(3) = size(image,2);
% ray tracing 
[amat] = ray_tracing_easy4(ang,v_dim, p_dim, ind2, ind3, 1);
% correct the proj; sv must be 0
%if nargin > 3
%    prjs = cor_prj(prjs,v_dim,p_dim,mask,amat,ivol);
%end
