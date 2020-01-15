function Rot=et_ang(eigv,C)

Ang=[];
Rot=[];
N=size(eigv,1);
C=reshape(C,9,9);


% GET ROTATION MATRICES
for i=1:N
    eig=eigv(i,:); %eig is a row vector
    eig=eig';
    R=C*eig;
    
    % polar decomposition
    R=reshape(R,3,3);
    [U,S,V]=svd(R);
    if(abs(det(S)) < 1e-10)
        i
    end
    R=U*V';
    
    R=R(:);
    R=R';
    Rot=[Rot; R];
    
    % GET EULER ANGLES ZYZ
    R=reshape(R,3,3);
    [ax ay az]=transform(R, 'rzyz');
    Ang=[Ang; ax ay az];

    if(mod(i,1000)==0)
      i
    end
end

save Rotation Rot -ascii;
save Euler_ang Ang -ascii;

%writeSPIDERdoc('my_angles.dat',Ang);

load random5000

N=size(random5000,2);

ang=[];
for i=1:N
      ind=random5000(i);   
%%     ind=i;
     ang=[ang; ind 3 Ang(i,:)];
end
ang=double(ang);

save my_angles.dat ang -ascii;
   
