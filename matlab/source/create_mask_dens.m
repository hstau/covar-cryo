function mask = create_mask(percent, NX,varargin)  % percent < 1
addpath /home/liaoh/lib/matlab

ext = '.spi';
if nargin > 2
    string = varargin{1};
    im = readSPIDERfile(string);
    NX = size(im,1);
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
% prunning; scale down
%mask = scale3(mask);
% prunning; scale up
%mask = fillin(mask);
% binarize
mask = mask > 0;
%output
out_mask = strcat('sfvol_var_perc',num2str(100*percent,'%03d'),'_mask',ext);
writeSPIDERfile(out_mask,mask);
% now the remaining
remain = zeros(NX,NX,NX);
remain(I(last+1:end)) = im(I(last+1:end));
out_remain = strcat('sfvol_var_perc',num2str(100*percent,'%03d'),'_remain',ext);
writeSPIDERfile(out_remain,remain);

