function mat = create_mat(ind2, ind3, img_size, sel_ang, angles)
% CREATE_MAT considers each angle bin, and calls project(), which computes the length of intersection of lines passing through coarse and fine voxels 
% 
% Input:
%	ind2       - cell with two vectors of indexes: fine and coarse grid in 2D image
%  	ind3  	   - cell with two vectors of indexes: fine and coarse grid in 3D volume
%       img_size   - integer images are of size img_size^2
%	sel_ang    - string, name of file containing the indexes of angle bins
%       ref_ang     - string, name of file containing the angles
%
% Returns:
%       mat        - cell, length of intersection of lines passing through coarse and fine voxels
%
% Example:
%       mat = create_mat(ind2, ind3, 32, 'sel_ang.spi', 'refangles.spi')
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

sel = readSPIDERdoc(sel_ang);
I = size(sel,1)
% read the angles
refang = readSPIDERdoc(ref_ang);
psi  = refang(sel,1);
theta= refang(sel,2);
phi  = refang(sel,3);
% sizes
p_dim(1) = img_size;
p_dim(2) = img_size;
v_dim(1) = img_size;
v_dim(2) = img_size;
v_dim(3) = img_size;
% ray tracing 
parfor i = 1:I % for each view
   if(mod(i,1)==0)
      i
   end
   euler = [psi(i) theta(i) phi(i)];
        
   mat = project(euler, v_dim, p_dim, ind2, ind3, i);
   mat{i} = mat;
end
% save mat

