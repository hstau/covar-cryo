function mat = project(euler, v_dim, p_dim, ind2, ind3, i)
% PROJECT computes the length of intersection of lines passing through coarse and fine voxels for a given angle 
% 
% Input:
%       euler      - array with the three Euler angles
%       v_dim      - dimensions of the covering cube
%       p_dim      - dimensions of the covering square
%	ind2       - cell with two vectors of indeces: fine and coarse grid in 2D image
%  	ind3  	   - cell with two vectors of indeces: fine and coarse grid in 3D volume
%       i          - integer, index of the selected angle
%
% Returns:
%       mat        - cell, length of intersection of lines passing through coarse and fine voxels
%
% Example:
%       mat = project([30 45 90], [32 32 32], [32 32], ind2, ind3, 2)
%   
% 
%       Author:
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


factor=20; % step factor in ray casting 

% make ind2 for index i only
find2 = ind2{1};
cind2 = ind2{2};
find2 = find2(:,i);
cind2 = cind2(:,i);
ind2{1} = find2;
ind2{2} = cind2;
%
% to radians
euler=euler*pi/180;
psi = euler(1); theta = euler(2); phi = euler(3);
% get the direction vector
[unit u v] = get_uv(psi,theta,phi);
% dimensions of projection image
Mu = p_dim(1);
Mv = p_dim(2);
Mu2 = floor(Mu/2);
Mv2 = floor(Mv/2);

list_v = [];
mat = []; 

find2 = ind2{1};
cind2 = ind2{2};
find3 = ind3{1};
cind3 = ind3{2};

% tracing for each grid point on projection image
for uu = 1:Mu % Mu2+1 
    for vv = 1:Mv % Mu2+1 
        rx = uu-Mu2-1;
        ry = vv-Mv2-1;
        pp = u*rx + v*ry;
        u1 = uu-1;
        v1 = vv-1;
        % fine grid 
        rad2 = rx*rx + ry*ry;
        mat = gtrace(0, u1, v1, rad2, pp,unit, v_dim, p_dim, find2, ind3, factor, mat);
        % coarse grid 
        if mod(uu,2) == 1 && mod(vv,2) == 1
           rx = uu-Mu2-0.5;
           ry = vv-Mv2-0.5; 
           pp = u*rx + v*ry; % displace +0.5 in each coord
           u1 = floor(u1/2);
           v1 = floor(v1/2);
           rad2 = rx*rx + ry*ry;
        mat = gtrace(1, u1, v1, rad2, pp,unit, v_dim, p_dim, cind2, ind3, factor, mat);           
        end
    end
end

M = max([find2(:); cind2(:)]);
N = max([find3(:); cind3(:)]);
% crate a sparse matrix from mat
row = mat(:,1);  
col = mat(:,2);
w = mat(:,3);
mat = sparse(row,col,w,M,N);
mat = mat/10;
    

function matn = gtrace(sp, u1, v1, rad2, pp, unit, v_dim, p_dim, ind2, ind3, factor, mat)
Mu = p_dim(1);
Mv = p_dim(2);
Mu2 = Mu/2;
Mv2 = Mv/2;
if sp == 1
   Mu = Mu2;
   Mv = Mv2;
end
ind = u1*Mv + v1 + 1; % use new indexing
ind = ind2(ind);      
if ind > 0            % if within mask
    pos = [];
    %    positive side
    pos = trace(pos, rad2, pp, unit, v_dim, 0,factor);
    %    negative side
    pos = trace(pos, rad2, pp, -unit, v_dim, 1,factor);
    % put together positive and negative sides
    l = ind_we(pos, v_dim, ind3, factor);
    on = ones(size(l,1),1);
    l = [ind*on l]; matn = [mat; l];
else
    matn = mat;
end


function pos = trace(pos, rad2, pp, unit, v_dim,start,factor)

%sv = 1;
NX = v_dim(1); 
NY = v_dim(2); 
NZ = v_dim(3);

N = NX*NY*NZ;

% half
NX2 = floor(NX/2);
NY2 = floor(NY/2);
NZ2 = floor(NZ/2);
% bound vector spider wadsworth center volume
bound = [NX2 NY2 NZ2];

% index vector
inda = [1 NX NY*NX];

% squared radius
r2 = min(NX2,NY2);
r2 = min(r2,NZ2);
r2 = r2*r2;

d = unit/factor; % step vector
p = pp + start*d;
ds = 1/factor;  % step size
%max_dist = sqrt(r2+1-rad2) + 1;
max_dist = sqrt(r2) + 1;
K = floor(max_dist/ds); % maximum number of steps

%flag = 0;
for n = 1:K
        z = round(p);
        z = z';
        if(z >= -bound & z <= bound-1)
            pos = [pos; z];
%            flag = 1;
        end   
        p = p + d;
end

function  l = ind_we(pos,v_dim,ind3,factor)
find3 = ind3{1};
cind3 = ind3{2};
l = [];
if size(pos,1) > 0
    NX = v_dim(1); 
    NY = v_dim(2); 
    NZ = v_dim(3);
    N = NX*NY*NZ;
    % in2 are the linear coordinates of pos
    in2 = process(pos,v_dim,1);
    on = ones(size(in2,1),1);
    
    % fine grid first
    % A is a 1D sparse matrix whose elements corresponds to the linear coord
    A = 1./factor*rsparse(in2,on,on,N,1); % collapsing
    % sparsifying
    [in1 aux w] = find(A);
    % storing results
    co = find3(in1);
    I = find(co);
    co = co(I);
    wo = w(I);
    if size(co,1) > 0
        l = [co wo];
        %if flag == 1
         %   save fine_ll l
         %   flag = 2
        %end
    end
    % now the coarse grid
    % find the Cartesian coords
    [a b c] = decomp3(in1-1, v_dim);  % in1-1 must start from 0
    v_dim1 = v_dim;
    % scaling and NO masking
    %for s = 1:sv  % for each scale
    a = floor(a/2);
    b = floor(b/2);
    c = floor(c/2);
    pos1 = [a b c]; % a b c already shifted
    % scaling
    v_dim1 = floor(v_dim1/2);
    % recalculate A
    in2 = process(pos1,v_dim1,0); % no shift applied
    on = ones(size(in2,1),1);
    %end
    A = rsparse(in2,on,w,N,1); % collapsing
    [in1 aux w] = find(A);
    % storing results
    co = cind3(in1);
    I = find(co);
    co = co(I);
    wo = w(I);
    if size(co,1) > 0
        l = [co wo; l];
        %if flag == 2
        %   save coarse_ll l
        %end
    end
end


function in2 = process(pos,v_dim,shift)

NX = v_dim(1); 
NY = v_dim(2); 
NZ = v_dim(3);
% half
NX2 = floor(NX/2);
NY2 = floor(NY/2);
NZ2 = floor(NZ/2);
% index vector
inda = [1 NX NY*NX];
if shift == 1 % all-positive coordinates
    % shift vector (only if shift == 1)
    sh = [NX2 NY2 NZ2];
    pos = pos + repmat(sh,size(pos,1),1);
end
% linear coordinates
in2 = sum(pos.* repmat(inda, size(pos,1),1),2) + 1; % starts from 1 to 
% avoid zero index in the sparse operation
% new coordinate


function [n u v] = get_uv(psi,theta,phi)

c1 = cos(psi);
c2 = cos(theta);
c3 = cos(phi);
s1 = sin(psi);
s2 = sin(theta);
s3 = sin(phi);

R = [c1*c2*c3-s1*s3    c3*s1+c1*c2*s3    c1*(-s2);
     (-c1)*s3-c2*c3*s1 c1*c3-c2*s1*s3    s1*s2;
      c3*s2             s2*s3               c2   ];

R = R'; % need the inverse

n = R*[0; 0; 1];
u = R*[1; 0; 0];
v = R*[0; 1; 0];


