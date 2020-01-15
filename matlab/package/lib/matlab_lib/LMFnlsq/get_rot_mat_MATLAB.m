function get_rot_mat

A=[];
B=[];
load Rotation

for i=1:size(R,3)
    if(mod(i,100)==0)
        i
    end
    R1=R(i,:);
        
    b=[i 9 R1];
    B=[B; b];
end

save Rotation.dat -ascii
