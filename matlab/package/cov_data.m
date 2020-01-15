function cov_data(ind2,sel_ang,sel_prj_pref,data_pref,sdata_pref,good_part,cov2d_pref) 
% COV_DATA - creates the 2D covariance computed from the projection data to be used as the rhs of a system equations, whose unknown is the 3D covariance
%
% Input:
%       ind2          - cell with two vectors of indeces: fine and coarse grid
%	sel_ang       - string, name of the file containing the indeces of angle bins
%       sel_prj_pref  - string, rootname of files containing indeces of particles
%       data_pref     - string, rootname of files containing the particles 
%       sdata_pref    - string, rootname of files containing shifted particles
%	good_part     - string, name of file containing the indeces of selected particles
%       cov2d_pref    - string, rootname of files containing 2D covariance (output)
% 
% Returns: 
%  	Files containing the 2D covariance computed from the projection data 
% 
% Example:
%       cov_data(ind2,
%		'covar/sel_ang.spi',
%               'covar/selfiles/prj_sel_',
%               'covar/data_flip/ffsar'
%               'covar/data_flip/sh_ffsar',
%		'covar/goodparticles.spi',
%               'covar/stats/scovar_')
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
% read selfile
string=strcat(sel_ang);
S = readSPIDERdoc(string);
% main loop
parfor i = 1:size(S,1)
    i
    % selection file for the occupied angles
    j = S(i);
    % list of particles for an angle
    string=strcat(sel_prj_pref,num2str(j,'%05d'),ext);
    sel = readSPIDERdoc(string);
    % get the 2D cov 
    cov_2d = get_cov(data_pref,sel, ind2, i, ext);
    % get the 2D cov of noise 
    part = get_noise_part1(good_part,sdata_pref,ext);
    cov_noise = get_covn(part,ind2, i, ext);
    cov_2d = cov_2d - cov_noise;
    cov_2d = cov_2d(:);
    % output
    write_image_stack(cov2d_pref,j,cov_2d);
end

