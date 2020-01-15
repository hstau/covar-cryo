function R = binning(ref_ang,align,raw_pref,mir_pref,bin_sel_pref,sel_ang,psi_adj, th, N)
% Given reference angles, BINNING bins the projection data according to their theta and phi angles and find the correction for the psi angle for each particle.  
%
% Input:
%       ref_ang   	- string, name of the file containing the reference angles in SPIDER format
%       align     	- string, name of file containing the alignment parameters in SPIDER format
%       raw_pref 	- string, rootname of files containing projection data or particles 
%       mir_pref  	- string, rootname of files containing projection data corrected for the mirroring (output)
%       bin_sel_pref	- string, rootname of files containing the indices of particles in a bin (output)
%       sel_ang   	- string, name of file containing the indices of angle bins (output)
%       psi_adj   	- string, name of file containing the just computed adjusted psi angles (output)
%       th              - integer, required minimum number of particles per bin
%       N      		- integer, grid size for finding optimal inplane rotation 
%
% Example:
%       R = binning('refangles.spi',
% 		    'align.spi',
%                   'data/sar',
%                   'part_flip/prj',
%		    'selfiles/prj_sel_'
%		    'sel_ang.spi',
%                   'psi_adj.spi',
%   		     th,
%                    500)
%
% Author:
% 	Hstau Liao
% 	Columbia University
%	Frank Lab
%	hstau.y.liao@gmail.com
%	
%
% Copyright notice: You are free to modify, extend and distribute 
%    this code granted that the author of the original code is 
%    mentioned as the original author of the code.

MAX=5000;

% reading the refangles 
refang=readSPIDERdoc(ref_ang);
% read the alignment angles and the indices in the file 
ang=readSPIDERdoc(align);
align=readSPIDERdoc(align,0);
% total number of reference angles
I=size(refang,1)
% total number of particles
J=size(ang,1)
% flag for mirror images
flag = zeros(J,1);

% convert to radian
ang=ang*pi/180;
refang=refang*pi/180;

% reference angles in Euler notation
rpsi=refang(:,1); 
rtheta=refang(:,2);
rphi=refang(:,3);
% vector of unit vectors corresponding to the reference angles
refv=[cos(rphi).*sin(rtheta) sin(rphi).*sin(rtheta) cos(rtheta)];
% vector of indices
index=zeros(J,1);
% vector of mapping for each ref angle
rev=zeros(I,MAX);
%counter for each bin
quant=zeros(I);

% loop through all the particles
for j=1:J 
       psi=ang(j,1);
    % progress		
    if(mod(j,1000)==0)
          j
    end
    % read data 
    string=strcat(raw_pref,num2str(j,'%06d'),'.spi');
    part=readSPIDERfile(string);
    % theta and phi    
    theta=ang(j,2); 
    phi=ang(j,3);
    % possible mirroring
    if (theta >=pi)  % mirror image 
        theta=theta-pi;
	ang(j,2) = theta; % update
        flag(j) = 1; 
        part=[part(:,1) part(:,end:-1:2)];
    end	
    % keep mirror flipped images
    string=strcat(mir_pref,num2str(j,'%06d'),'.spi');
    writeSPIDERfile(string,part);
    % finding the closest point on tessellated S2
    % unit vector 
    v=[cos(phi).*sin(theta) sin(phi).*sin(theta) cos(theta)];
    % scalar product with reference angles to find the closest point on S3
    inn=refv*v';
    [val ind]=max(inn);
    % keep the index of the bin 
    index(align(j))=ind;  % stores the index of the ref ang    
    %if flag(j) == 1
    quant(ind)=quant(ind)+1; % actual count of particles for that bin
    rev(ind,quant(ind))=align(j); % 
    %end
    % find the bin by forcing similar net rotation, given the theta and phi of the bin
    rtheta=refang(ind,2); % first, get the bin angle
    rphi=refang(ind,3);
    rpsi=refang(ind,1);   
    v(1:4)=[0 0 0 1];     
    v(5:8)=[rpsi rtheta rphi 0];
    rrot = x2t_ZYZ(v','rpm');   % form rotation matrix corresp. to the bin
    
    dif = 1e10; % any large number
    % find the new psi of the particle, so that its rotation matrix is closest to that of the bin 
    for k=0:N-1
      psi = 2 * pi * k/N; % test a psi
      v(5:8)=[psi theta phi 0];
      rot = x2t_ZYZ(v','rpm');
      ndif = norm(rrot-rot,'fro');  
      if (ndif < dif)
         npsi = psi;
         dif = ndif;
      end
     end
     ang(j,1) = npsi; % update
end

rev=double(rev);
save revert rev -ascii

% cleaning up, keeping bins that are large enough 
S = []; % sel_angles
% A = []; % Euler_angles
for i=1:I % for each ref projection 
   % progress	
   if(mod(i,1000)==0)
          i
   end 
   if (quant(i) > th) % 7, 2, 8, 12, 30
     R = rev(i,1:quant(i));
     string=strcat(bin_sel_pref,num2str(i,'%05d'),'.spi');
     writeSPIDERdoc(string,R');

     S = [S; i];
     %rtheta=refang(i,2); 
     %rphi=refang(i,3);
     %rpsi=refang(i,1);
     %A = [A; [rpsi rtheta rphi]];
   end
end

writeSPIDERdoc(sel_ang,S);
%string=strcat('binned_angles.spi');
%writeSPIDERdoc(string,A*180/pi);
% change back to degrees
ang = ang*180/pi;
writeSPIDERdoc(psi_adj,ang);

end


