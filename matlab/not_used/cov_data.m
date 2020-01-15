function cov_data(ind2,sel_ang,sel_prj_pref,part_pref,spart_pref,cov2d_pref) 
% COV_DATA - creates the 2D covariance computed from the projection data to be used as the rhs of a system equations, whose unknown is the 3D covariance
%
% Input:
%       ind2          - cell with two vectors of indeces: fine and coarse grid
%	sel_ang       - string, filename containing the indeces of angle bins
%       sel_prj_pref  - string, rootname of files containing indeces of particles
%       part_pref     - string, rootname of particles 
%       spart_pref    - string, rootname of shifted particles
%       cov2d_pref    - string, rootname of 2D covariance 
% 
% Returns: 
%  	Files containing the 2D covariance computed from the projection data 
% 
% Example:
%       cov_data(ind2,
%		'covar/sel_ang.spi',
%               'covar/selfiles/prj_sel_',
%               'covar/part_flip/ffsar'
%               'covar/part_flip/sh_ffsar',
%               'covar/stats/scovar_')
%
% Author:
% 	Hstau Liao
% 	Columbia University
%	Frank Lab
%	hstau.y.liao@gmail.com
%	
% Tested:	
%	MATLAB2013a
% Copyright notice: You are free to modify, extend and distribute 
%    this code granted that the author of the original code is 
%    mentioned as the original author of the code.


%addpath /guam.raid.cluster.software/relion_more/matlab_lib/
%addpath /guam.raid.home/liaoh/lib/matlab
%addpath /guam.raid.home/liaoh/lib/matlab/extern

ext = '.spi';
% read selfile
S = readSPIDERdoc(sel_ang);
parfor i = 1:size(S,1)
    i
    % selection file for the occupied angles
    j = S(i);
    % list of particles in an agle bin
    string=strcat(sel_prj_pref,num2str(j,'%05d'),ext);
    sel = readSPIDERdoc(string);
    % get the 2D cov of signal plus noise
    cov_2d = get_ccov(S,part_pref,sel, ind2, i, ext);
    % get the 2D cov of shifted particles (noise)
    cov_noise = get_ccov(S,spart_pref,sel, ind2, i, ext);
    % get the 2D cov of signal   
    cov_2d = cov_2d - cov_noise;
    cov_2d = cov_2d(:);
    % write output 2D covariance
    write_image_stack(cov2d_pref,j,cov_2d);
end

