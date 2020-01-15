function vols = scale3(vol)
%addpath /home/liaoh/lib/matlab

vols = zeros(size(vol)/2);
for i = 1:2
    for j=1:2
        for k=1:2
            vols = vols + vol(i:2:end,j:2:end,k:2:end);
        end
    end
end
vols = vols/8;
  