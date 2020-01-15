function [R]=read_projs()

MAX=5000;
N = 100;
addpath /guam.raid.cluster.software/relion_more/matlab_lib/
addpath  /guam.raid.cluster.software/relion_more/matlab_lib/3dtrans
addpath  /guam.raid.cluster.software/relion_more/matlab_lib/LMFnlsq
% output
adj=strcat('psi_adju_angles.spi');

% reading the refangles and the angles

%refang=readSPIDERdoc('/guam.raid.home/liaoh/2D_var_DHX/new_with_covar_%DHX/covar/refangles.spi');
refang=readSPIDERdoc('refangles.spi');

ang=readSPIDERdoc('/guam.raid.home/liaoh/2D_var_DHX/align_dala.spi');

sel_ang=readSPIDERdoc('/guam.raid.home/liaoh/2D_var_DHX/align_dala.spi',0);

I=size(refang,1)

J=size(ang,1)
% flag for mirror images
flag = zeros(J,1);
% in degrees
ang=ang*pi/180;
refang=refang*pi/180;
nang = ang;

rpsi=refang(:,1); % rpsi is a vector
rtheta=refang(:,2);
rphi=refang(:,3);

refv=[cos(rphi).*sin(rtheta) sin(rphi).*sin(rtheta) cos(rtheta)];

%vector of indeces
index=zeros(J,1);

% vector of mapping for each ref angle
rev=zeros(I,MAX);

%counter for each ref angle
quant=zeros(I);

for j=1:J % for each image projection (i.e., for each particle)
       psi=ang(j,1);

    if(mod(j,1000)==0)
          j
    end
    
    string=strcat('data/sar',num2str(j,'%06d'),'.spi');
    part=readSPIDERfile(string);
        
    theta=ang(j,2); % theta is a scalar
    phi=ang(j,3);
    
    if (theta >=pi)  % mirror image 
        theta=theta-pi;
        flag(j) = 1; 
        part=[part(:,1) part(:,end:-1:2)];
    end

    string=strcat('part_flip/prj',num2str(j,'%06d'),'.spi');
    writeSPIDERfile(string,part);

    % finding the closest point on tessellated S2

    v=[cos(phi).*sin(theta) sin(phi).*sin(theta) cos(theta)];
    
    inn=refv*v';
    
    [val ind]=max(inn);

    index(sel_ang(j))=ind;  % stores the index of the ref ang

    
    
    %if flag(j) == 1
        quant(ind)=quant(ind)+1;
        rev(ind,quant(ind))=sel_ang(j);
    %end
    % finding the closes point on S3

    rtheta=refang(ind,2); % theta is a scalar
    rphi=refang(ind,3);
    rpsi=refang(ind,1);
    v(1:4)=[0 0 0 1];
    v(5:8)=[rpsi rtheta rphi 0];
    rrot = x2t_ZYZ(v','rpm');
    
    dif = 1e10;

    for k=0:N-1
      psi = 2 * pi * k/N;
      v(5:8)=[psi theta phi 0];
      rot = x2t_ZYZ(v','rpm');

      ndif = norm(rrot-rot,'fro');
      if (ndif < dif)
         npsi = psi;
         dif = ndif;
      end
     end
    
     nang(j,1) = npsi;
     nang(j,2) = theta;  % change!
     
end

rev=double(rev);
save revert rev -ascii
save flag flag
%vector of sizes
sz=zeros(I,1);

S = [];
A = [];

for i=1:I % for each ref projection 
   if(mod(i,1000)==0)
          i
   end
   
   sz(i)=length(find(rev(i,:)));
   
   if (sz(i) > 12) % 9, 7, 2, 8, 12, 30
     R = rev(i,1:sz(i));
     string=strcat('selfiles/prj_sel_',num2str(i,'%05d'),'.spi');
     writeSPIDERdoc(string,R');

     S = [S; i];
     rtheta=refang(i,2); % theta is a scalar
     rphi=refang(i,3);
     rpsi=refang(i,1);
     A = [A; [rpsi rtheta rphi]];
   end
end

string=strcat('sel_ang.spi');
writeSPIDERdoc(string,S);
string=strcat('binned_angles.spi');
writeSPIDERdoc(string,A*180/pi);

nang = nang*180/pi;

writeSPIDERdoc(adj,nang);

sz=double(sz);
save sizes sz -ascii


end


