function mask = circ_mask(p_dim)
%addpath /home/liaoh/lib/matlab

NX = p_dim(1); 
NY = p_dim(2); 
% half
NX2 = floor(NX/2);
NY2 = floor(NY/2);
% squared radius
r2 = min(NX2,NY2);
r2 = r2;
r22 = r2*r2;
% default circular mask
mask = zeros(NX,NY);
for x=-NX2:NX2-1
    for y=-NY2:NY2-1
        if x*x + y*y < r22;
            i = x + NX2 + 1;
            j = y + NY2 + 1;
            mask(i,j) = 1;
        end
    end
end 