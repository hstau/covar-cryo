function mask = create_mask(fract, img_size, vol, maskfile)  % percent < 1
%
% MASK creates 3D mask based on a volume density
%
% Input:
% 	fract     - float, fract*(maximum density) is the density above which voxels are kept 
%       img_size  - integer, img_size^3 is the size of the volume
% 	vol       - string, file name of the reference volume used to construct the mask; if missing, then the default is a sphere 
%	maskfile - string, file name of computed mask (output)
%
% Returns:
%	mask      - resulting mask 
%
% Author:
% 	Hstau Liao
% 	Columbia University
%	Frank Lab
%	hstau.y.liao@gmail.com
%	
%
% Copyright notice: You are free to modify, extend and distribute 
%    this code granted that the author of the original code is 
%    mentioned as the original author of the code.


ext = '.spi';
NX = img_size;
if nargin > 2
    im = readSPIDERfile(vol_dens);
else
    im = sph_mask([NX NX NX]);
end
% sort mask
[w I] = sort(im(:),'descend');
i = 1;
last = i-1;
while (w(i) > percent*w(1))
    i = i+1;
    last = i;
end
% fraction of non-zeros
fraction = last/size(im(:),1)
% binary mask
mask = zeros(NX,NX,NX);
mask(I(1:last)) = im(I(1:last));
% pruning; scale down
%mask = scale3(mask);
% prunning; scale up
%mask = fillin(mask);
% binarize
mask = mask > 0;
%output
writeSPIDERfile(maskfile,mask);
% now the remaining
%remain = zeros(NX,NX,NX);
%remain(I(last+1:end)) = im(I(last+1:end));
%out_remain = strcat('sfvol_var_perc',num2str(100*percent,'%03d'),'_remain',ext);
%writeSPIDERfile(out_remain,remain);

