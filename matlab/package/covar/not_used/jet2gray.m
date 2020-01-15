function new = jet2gray(im)
new = zeros(size(im(:,:,1)));
colormap(jet)
cmap = round(double(colormap*255));
%cmap = cmap/norm(cmap);
for i=1:size(im,1)
    for j=1:size(im,2)
        color = im(i,j,:);
        sc = double([color(1,1,1) color(1,1,2) color(1,1,3)]');
        %sc = sc/norm(sc);
        %[m ind] = max(cmap*sc);
        sc =  repmat(sc',size(cmap,1),1);
        dif = sum(abs(cmap-sc),2);
        [m ind] = min(dif);
        new(i,j) = ind;
    end
end
        
        