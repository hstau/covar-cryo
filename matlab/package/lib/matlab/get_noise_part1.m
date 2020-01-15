function par = get_cov(good_head,prj_head,ext)
mmax = 200;
string=strcat(good_head,ext);
good = readSPIDERdoc(string);
% read an image to get the dimensions
u = good(1);
string=strcat(prj_head,num2str(u,'%06d'),ext);
part = readSPIDERfile(string);
% vector
par = zeros(size(part(:),1),mmax);
% main loop
J=randperm(size(good,1));
for j=1:mmax
      i = J(j);
      u = good(i);
      string=strcat(prj_head,num2str(u,'%06d'),ext);
      part = readSPIDERfile(string);
      %save unshift part
      %max_sh = floor(0.2*size(part,1))
      %sh_x = randi(max_sh)
      %sh_y = randi(max_sh)
      %part = FourierShift2D(part, [sh_x sh_y]);
      %save shift part
      par(:,j) = part(:);
end



