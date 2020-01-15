function ind2 = create_ind2d(op,img_size,sel_ang,mask_pref)  
% CREATE_IND2D - creates two vectors of indices, one for the coarse grid and the other one for the finer grid of a 2D mask. A coarse grid point is obtained by merging four fine grid points 
%
% Input:
%	op 	      - integer, 1 (coarse resolution, only circular mask, no input mask), 
%				 2 (fine resolution, using input mask), and
%				 3 (both resolution with resp. masks) 	
%       img_size      - integer images are of size img_size^2
%	sel_ang       - string, filename containing the indices of angle bins
%
% 	mask_pref     - string, rootname of 2D mask files 
%       
%             
% 
% Returns: 
%  	ind2	      - cell with two vectors of indices: fine and coarse grid in 2D image
% 
% Examples:
%       ind2 = create_ind2d(1,32,'sel_ang.spi')
%       ind2 = create_ind2d(2,32,'sel_ang.spi','rep_mask')
%       ind2 = create_ind2d(3,32,'sel_ang.spi','rep_mask')
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


ext = '.spi';
% read angle sel file 
sel = readSPIDERdoc(sel_ang);
I = size(sel,1)
% number of scales
sv = 1;
% square images
NX = img_size
NY = NX
N = NX*NY
NX2 = NX/2;
NY2 = NY/2;
p_dim(1) = NX;
p_dim(2) = NY;
inda2 = [1 NX2];
% creating a circular mask
circ = circ_mask(p_dim);
% allocate index arrays, one coarse and one fine
find2 = zeros(N,I);
cind2 = zeros(N/4,I);
% if mask file are absent, op may not be 3
if nargin < 4 && op == 3
    display('op=3 requires mask files'); 
    return 
end
for k = 1:I
    %k
    j = sel(k);
    % default mask is circular
    mask = circ > 0;	
    if nargin > 3 && op > 1 % if mask	
        % read mask
    	string=strcat(mask_pref,num2str(j,'%05d'),ext);
    	mask = readSPIDERfile(string); 
        mask = (mask > 0) + 1; % value is 2 if inside the mask
    	mask = mask.*circ; % the range is 2 (fine), 1 (coarse), or 0 (outside)
    end
    mask = mask(:);
    % compute the indices
    for i = 1:size(mask(:))
        [a b] = decomp2(i-1, p_dim);
        if mask(i) == 2 % with input mask
            find2(i,k) = -i; % fine grid  
        elseif mask(i) == 1 % outside input mask but inside circular mask, for coarse and mixed resol 
            for s = 1:sv  % for each scale
               a = floor(a/2);
               b = floor(b/2);
            end
            m = sum([a b].*inda2) + 1;
	    if op == 2
               cind2(m,k) = 0; % fine grid only
            else 
               cind2(m,k) = m; % coarse and mixed grid
            end
        end
    end
    % prunning
    for i = 1:size(mask(:),1)
        [a b] = decomp2(i-1, p_dim);
        a = floor(a/2);
        b = floor(b/2);
        m = sum([a b].*inda2) + 1;
        if cind2(m,k) ~= 0
            find2(i,k) = 0;  % set zero to those in the coarse zone 
        end
     end
    % reduce indexing size
    I = find(cind2(:,k));
    cind2(I,k) = [1:size(I,1)]';
    offset = size(I,1);
    I = find(find2(:,k));
    find2(I,k) = [1:size(I,1)]' + offset;
    
%
end
test = find2(:,2);
test = reshape(test,NX,NY);
save test test
ind2{1} = find2;
ind2{2} = cind2;
%save ind2 ind2

