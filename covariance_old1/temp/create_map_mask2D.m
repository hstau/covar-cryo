function ind2 = create_mask()  % mask and decimation factor  
addpath /guam.raid.cluster.software/relion_more/matlab_lib/
addpath /guam.raid.home/liaoh/lib/matlab

ext = '.spi';
% read angle sel file 
sel = readSPIDERdoc('covar/sel_ang.spi');
I = size(sel,1)
% 
sv = 1;
%string=strcat('covar/stats/rep_mask1',num2str(sel(1),'%05d'),ext);
string=strcat('covar/stats/rep_mask005',num2str(sel(1),'%05d'),ext);
image = readSPIDERfile(string);
NX = size(image,1);
NY = size(image,2);
NX2 = NX/2;
NY2 = NY/2;
p_dim(1) = NX;
p_dim(2) = NY;
inda2 = [1 NX2];
circ = circ_mask(p_dim);
% allocate projection data array
find2 = zeros(size(image(:),1),size(sel,1));
cind2 = zeros(size(image(:),1)/4,size(sel,1));
for k = 1:I
    j = sel(k);
    string=strcat('covar/stats/rep_mask005',num2str(j,'%05d'),ext);
    mask = readSPIDERfile(string);
    mask = (mask > 0) + 1; % binarized and plus 1
    mask = mask.*circ; % the range is 2 (fine), 1 (coarse), or 0 (outside)
    mask = mask(:);
    % compute image indeces
    for i = 1:size(mask(:))
        [a b] = decomp2(i-1, p_dim);
        if mask(i) == 2 % !!!!!!!!!!!!!!!!!!!!!!!! CHECK HERE 
            find2(i,k) = -i; % fine ones!!!!!!!!!!!!!!!!!!!!!!!! CHECK HERE 
        elseif mask(i) == 1 % !!!!!!!!!!!!!!!!!!!!!!!! CHECK HERE 
            for s = 1:sv  % for each scale
               a = floor(a/2);
               b = floor(b/2);
            end
            m = sum([a b].*inda2) + 1;
            cind2(m,k) = 0;%m;  % coarse ones !!!!!!!!!!!!!!!!!!!!!!!! CHECK HERE 
        end
    end
    % prunning
    for i = 1:size(mask(:),1)
        [a b] = decomp2(i-1, p_dim);
        a = floor(a/2);
        b = floor(b/2);
        m = sum([a b].*inda2) + 1;
        if cind2(m,k) ~= 0
            find2(i,k) = 0;  % set zero to those in the coarse area 
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
test = cind2(:,2);
test = reshape(test,NX2,NY2);
save test test
ind2{1} = find2;
ind2{2} = cind2;
save ind2 ind2

