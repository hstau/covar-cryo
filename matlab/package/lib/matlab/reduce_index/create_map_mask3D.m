function ind3 = create_mask(string)  % mask and decimation factor  
addpath /guam.raid.cluster.software/relion_more/matlab_lib/
addpath /guam.raid.home/liaoh/lib/matlab

%string = '/guam.raid.home/liaoh/2D_var_DHX/new_with_covar_reduce_index_DHX/sfvol_var_perc100_mask.spi';
string ='/guam.raid.home/liaoh/2D_var_DHX/new_with_covar_reduce_index_DHX/sfvol_var_perc030_mask.spi';
mask = readSPIDERfile(string);
mask = permute(mask,[2 1 3]);
sv = 1;
NX = size(mask,1);
NY = size(mask,2);
NZ = size(mask,3);
NX2 = NX/2;
NY2 = NY/2;
NZ2 = NZ/2;
v_dim(1) = NX;
v_dim(2) = NY;
v_dim(3) = NZ;
inda2 = [1 NX2 NY2*NX2];
% initial values
find3 = zeros(size(mask(:),1),1);   % fine grain
cind3 = zeros(size(mask(:),1)/8,1);  % coarse grain
% reduced vol indeces
sph = sph_mask(v_dim);
mask = mask + 1;  % the range is 2 or 1
mask = mask.*sph; % the range is 2 (fine), 1 (coarse), or 0 (outside)
for i = 1:size(mask(:),1)
    [a b c] = decomp3(i-1, v_dim);
    if mask(i) == 1 %                 !!!!!!!!!!!!!!!!!!!!!!!! CHECK HERE 
        find3(i) = 0;%-i; % fine ones !!!!!!!!!!!!!!!!!!!!!!!! CHECK HERE 
    elseif mask(i) == 2
        for s = 1:sv  % for each scale
           a = floor(a/2);
           b = floor(b/2);
           c = floor(c/2);
        end
        m = sum([a b c].*inda2) + 1;
        cind3(m) = m;  % coarse ones !!!!!!!!!!!!!!!!!!!!!!!! CHECK HERE 
    end
end
% prunning 
for i = 1:size(mask(:),1)
    [a b c] = decomp3(i-1, v_dim);
    a = floor(a/2);
    b = floor(b/2);
    c = floor(c/2);
    m = sum([a b c].*inda2) + 1;
    if cind3(m) ~= 0
        find3(i) = 0;  % set zero to those in the coarse area 
    end
end
%
% reduce indexing size
I = find(cind3);
cind3(I) = [1:size(I,1)]';
offset = size(I,1);
I = find(find3);
find3(I) = [1:size(I,1)]' + offset;

%
ind3{1} = find3;
ind3{2} = cind3;
%
save ind3 ind3


% reverse mapping too slow; not used
function jj =rev_map1(ii, mapi)
   jj = 1;
   while ii > mapi(jj)
       jj = jj + 1;
   end

