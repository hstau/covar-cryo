function Rot=et_ang(R)

addpath ../3dtrans/


Ang=[];
N=size(R,3);


% GET ROTATION MATRICES
for i=1:N
    
    % GET EULER ANGLES ZYZ
    r=R(:,:,i);
    [ax ay az]=transform(r, 'rzxz');
    Ang=[Ang; ax ay az];
end

save Euler_ang Ang -ascii;


ang=[];
for i=1:N
     ind=i;
     ang=[ang; ind 3 Ang(i,:)];
end
%random1000(2)
ang=double(ang);

save chuck_angles.dat ang -ascii;
   
