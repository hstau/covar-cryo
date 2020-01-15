function Rot=et_ang(nprj)


load Rotation  % this is my 100K matrices
load samp_S3_rotmat    % this is a Nx3 matrix
load random5000
N=size(samp_S3_rotmat,1);


% GET ROTATION MATRICES
for i=1:N
    if(mod(i,100)==0)
        i
    end
    Q=samp_S3_rotmat(i,:);
    Q=reshape(Q,3,3);
    Ang=[];
    for j=1:nprj
        ind=random5000(j);
        R1=Rotation(ind,:);
        R1=reshape(R1,3,3);
        r=Q*R1;
        [ax ay az]=transform(r, 'rzyz');
        Ang=[Ang; ind 3 ax ay az];
    end
    if(i<10)
        ceros='0000';
    elseif(i<100)
        ceros='000';
    elseif(i<1000)
        ceros='00';
    elseif(i<10000)
        ceros='0';
    else
        ceros='';
    end
    string=strcat('grid/set_',ceros,num2str(i),'.dat'); 
    write(string,Ang'); 
end

%save Euler_ang Ang -ascii;


function write(string,D)
   fid=fopen(string,'wt');
   fprintf(fid,'%d %d %6.2f %6.2f %6.2f\n',D);
   fclose(fid);


%function write(string,D)
%   fid=fopen(string,'wt');
%   fwrite(fid, D,'float');
%   fclose(fid);


   
