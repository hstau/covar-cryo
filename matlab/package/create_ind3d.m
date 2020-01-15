function ind3 = create_ind3d(op,img_size,maskfile)   
% CREATE_IND3D - creates two vectors of indices, each of which corresponding to the coarse and fine area of a 3D mask.A coarse grid point is obtained by merging nine fine grid points 
%
% Input:
%	op 	      - integer, 1 (coarse resolution, only circular mask), 
%				 2 (fine resolution, using input mask), and
%				 3 (both resolution with resp. masks ) 	
%       img_size      - integer images are of size img_size^3
% 	maskfile      - string, name of the 3D mask file 
%       
%             
% 
% Returns: 
%  	ind3	      - cell with two vectors of indices: fine and coarse grid in 3D volume
%
% Example:
%       ind3 = create_ind3d(1,32,'mask.spi')
%       
% Author:
% 	Hstau Liao
% 	Columbia University
%	Frank Lab
%	hstau.y.liao@gmail.com
%
% Copyright notice: You are free to modify, extend and distribute 
%    this code granted that the author of the original code is 
%    mentioned as the original author of the code.


sv = 1;
NX = img_size;
NY = NX;  % just cubic volume
NZ = NX;  % just cubic volume 
NX2 = NX/2;
NY2 = NY/2;
N=img_size^3;
v_dim(1) = NX;
v_dim(2) = NY;
v_dim(3) = NZ;
inda2 = [1 NX2 NY2*NX2];
% if mask file is absent, op may not be 3
if nargin < 3 && op == 3
    display('op=3 requires mask files'); 
    return 
end
% initial values
find3 = zeros(N,1);   % fine area
cind3 = zeros(N/8,1);  % coarse area
% default shperical mask
sph = sph_mask(v_dim);
mask = sph>0;
if nargin > 2 && op > 1 % with input mask	
   mask = readSPIDERfile(maskfile);
   mask = permute(mask,[2 1 3]);
   mask = mask + 1;  % the values are 2 or 1
   mask = mask.*sph; % the values are 2 (fine), 1 (coarse), or 0 (outside)
end
% 
for i = 1:size(mask(:),1)
    
    [a b c] = decomp3(i-1, v_dim);
    if mask(i) == 2  % with input mask 
        find3(i) = -i; % fine grid 
    elseif mask(i) == 1 % outside input mask but inside circular mask, for coarse and mixed resol
        for s = 1:sv  % for each scale
           a = floor(a/2);
           b = floor(b/2);
           c = floor(c/2);
        end
        m = sum([a b c].*inda2) + 1;
        if op == 2
            cind3(m) = 0;  % fine grid 
        else
           cind3(m) = m; % coarse and mixed grid
        end   
    end
end
% pruning 
for i = 1:size(mask(:),1)
    [a b c] = decomp3(i-1, v_dim);
    a = floor(a/2);
    b = floor(b/2);
    c = floor(c/2);
    m = sum([a b c].*inda2) + 1;
    if cind3(m) ~= 0
        find3(i) = 0;  % set zero to those in the coarse zone
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
%save ind3 ind3



