function get_data(ind2)
addpath /guam.raid.cluster.software/relion_more/matlab_lib/
addpath /guam.raid.home/liaoh/lib/matlab

ext = '.spi';
% read selfile
string=strcat('covar/sel_ang.spi');
S = readSPIDERdoc(string);
SL = size(S,1);
% read the mas for normalization
string=strcat('covar/mask_12n',ext);
mask = readSPIDERfile(string);
%mask = scale(norm_mask);
% loop starts
parfor i = 1:size(S,1)
    i
    % selection file for the occupied angles
    j = S(i);
    % list of particles for an angle
    string=strcat('covar/selfiles/prj_sel_',num2str(j,'%05d'),ext);
    sel = readSPIDERdoc(string);
    % test
    string=strcat('covar/stats/var_',num2str(j,'%05d'),ext);
    svar = readSPIDERfile(string);
    string=strcat('covar/stats/var_',num2str(j,'%05d'),'.txt');
    write_stack(string,j,svar);
    %test
    % get the 2d cov 
    prj_head = 'covar/part_flip/fsar';
    cov_2d = get_cov(prj_head,sel, ind2, i, ext);
    % get the 2d cov of "background"
    %prj_head = 'covar/part_flip/reprprj';
    %repcov_2d = get_cov(prj_head,sel, ind2, i, ext);
    % subtract the two
    %cov_2d = cov_2d-repcov_2d;   
    % get the diag elements
    var = get_diag2(cov_2d,ind2,i);
    string = strcat('temp/matlab_2dvar',num2str(i,'%05d'),ext);
    writeSPIDERfile(string,var);
    % get the noise var
    var =  get_noise_cov(prj_head,sel,  i, ext);
    [me st] = calc_backg(var, mask);
     cov_2d = normalize(cov_2d,me,st,ind2,i); %test
    %cov_2d = normalize1(cov_2d,ind2,i);
    % output result
    out_head = 'covar/stats/scovar_';
    %out_head = 'covar/stats_fine/scovar_';
    %string = strcat(out_head,num2str(j,'%05d'));
    %save(string,'cov_2d');
    write_image_stack(out_head,j,cov_2d);
end


function [me st] = calc_backg(var, mask)
bg = var .* mask(:);
%bg = bg(:);
bg = bg(find(bg));
me = mean(bg); % 0.8
st = std(bg);

function cov_2d = normalize(cov_2d,me,st,ind2,i)
% sizes
M = size(cov_2d,1);
cind2 = ind2{2};
cind2 = cind2(:,i);
I = size(find(cind2),1);
%
cov_2d = cov_2d(:);
% get the diag elements
all = ([1:M]-1)*M + [1:M];
var = cov_2d(all);
me = [me*ones(I,1); 0.3*me*ones(M-I,1)];  %for fine, no mult factor applied
st = [st*ones(I,1); st*ones(M-I,1)];
var = var - me;
%var = var./st;
cov_2d(all) = var;

function cov_2d = normalize1(cov_2d,ind2,i)
% sizes
M = size(cov_2d,1);
cind2 = ind2{2};
cind2 = cind2(:,i);
I = size(find(cind2),1);
% get the diag elements
var = diag(cov_2d);
co = var([1:I]);
co = co - mean(co);
fi = var([I+1:M]);
fi = fi - mean(fi);
t0 = [co; fi];
cov_2d = cov_2d - diag(t0);
cov_2d = cov_2d(:);

function var = get_noise_cov(prj_head,sel, i, ext)
% read an image to get the dimensions
u = sel(1);
string=strcat(prj_head,num2str(u,'%06d'),ext);
part = readSPIDERfile(string);
% vector for the differences for each pixel
par = zeros(size(part(:),1),size(sel,1));
% compute the average
for k = 1:size(sel,1)
    u = sel(k);
    % read a particle
    string=strcat(prj_head,num2str(u,'%06d'),ext);
    part = readSPIDERfile(string);
    % distance from the ave
    par(:,k) = part(:);
end
ave = mean(par,2);
% compute the differences
par = par-repmat(ave,[1 size(sel,1)]);
% compute the cov matrix
cov_2d = par*par'/(size(sel,1)-1);%ones(size(sel,1),size(par,1))/size(sel,1);%p
var = diag(cov_2d);



