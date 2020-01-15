function mask = sph_mask(v_dim)
%addpath /home/liaoh/lib/matlab

NX = v_dim(1); 
NY = v_dim(2); 
NZ = v_dim(3);
% half
NX2 = floor(NX/2);
NY2 = floor(NY/2);
NZ2 = floor(NZ/2);
% squared radius
r2 = min(NX2,NY2);
r2 = min(r2,NZ2);
r2 = r2;
r22 = r2*r2;
% default spherical mask
mask = zeros(NX,NY,NZ);
for x=-NX2:NX2-1
    for y=-NY2:NY2-1
        for z=-NZ2:NZ2-1
            if x*x + y*y+ z*z < r22;
                i = x + NX2 + 1;
                j = y + NY2 + 1;
                k = z + NZ2 + 1;
                mask(i,j,k) = 1;
            end
        end
    end
end
