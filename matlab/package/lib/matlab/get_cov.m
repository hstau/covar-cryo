function cov_2d = get_cov(prj_head,sel, ind2, i, ext)
% read an image to get the dimensions
u = sel(1);
string=strcat(prj_head,num2str(u,'%06d'),ext);
part = readSPIDERfile(string);
% comrpress this image
da = compress_data(part,ind2, i);
% vector for the differences for each pixel
par = zeros(size(da(:),1),size(sel,1));
% compute the average
for k = 1:size(sel,1)
    u = sel(k);
    % read a particle
    string=strcat(prj_head,num2str(u,'%06d'),ext);
    part = readSPIDERfile(string);    
    % compress data
    da = compress_data(part,ind2, i);
    % distance from the ave
    par(:,k) = da;
end
ave = mean(par,2);
% compute the differences
par = par-repmat(ave,[1 size(sel,1)]);
% compute the cov matrix
cov_2d = par*par'/(size(sel,1)-1);
