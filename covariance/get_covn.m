function cov_2d = get_cov(part, ind2, i, ext)
% read an image to get the dimensions
ss = sqrt(size(part(:,1),1));
ima = reshape(part(:,1),ss,ss);
% comrpress this image
da = compress_data(ima,ind2, i);
% vector for the differences for each pixel
par = zeros(size(da(:),1),size(part,2));
% compute the average
for k = 1:size(part,2)
    ima = reshape(part(:,k),ss,ss);
    % compress data
    da = compress_data(ima,ind2, i);
    % distance from the ave
    par(:,k) = da;
end
ave = mean(par,2);
% compute the differences
par = par-repmat(ave,[1 size(part,2)]);
% compute the cov matrix
cov_2d = par*par'/(size(part,2)-1);%ones(size(sel,1),size(par,1))/size(sel,1);%par'/(size(sel,1)-1);

