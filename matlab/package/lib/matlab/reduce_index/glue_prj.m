function g_prj = glue_prj(prj, sh_prj, maski, masko)
% size
ss = size(prj,2);
ss = sqrt(ss);
% 
masko = masko(:);
maski = maski(:);
masko = repmat(masko',size(prj,1),1);
maski = repmat(maski',size(sh_prj,1),1);
%
g_prj = prj.*masko + sh_prj.*maski;
