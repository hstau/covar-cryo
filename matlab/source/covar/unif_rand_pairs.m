function read_projs(NU)
addpath /guam.raid.home/liaoh/lib/matlab

string=strcat('sel_ang_764.spi');
S = readSPIDERdoc(string);
string=strcat('binned_angles_764.spi');
A = readSPIDERdoc(string);

A = A * pi/180;
%rng(1);
% random search for the NU pairs
MP = size(A,1)*(size(A,1)-1)/2;
num = min(NU, MP);
mm = 1e-10;
for t = 1:200 % 1000 trials
    t
    r = randperm(MP);
    r = r(1:num)';
    save r r
    [i1 i2] = decompUT(r);
    save i1 i1
    save i2 i2
    theta1 = A(i1,2);
    phi1 = A(i1,3);
    theta2 = A(i2,2);
    phi2 = A(i2,3);
    v1 = [cos(phi1).*sin(theta1) sin(phi1).*sin(theta1) cos(theta1)];
    v2 = [cos(phi2).*sin(theta2) sin(phi2).*sin(theta2) cos(theta2)];
    %
    inn = abs(v1*v2');
    inn = 1 - inn;
    score = sum(inn(:));
    %
    if score > mm
        good1 = i1;
        good2 = i2;
        mm = score
    end
end
P1 = S(good1);
P2 = S(good2);
string=strcat('sel_ang_pair1.spi');
writeSPIDERdoc(string,P1);
string=strcat('sel_ang_pair2.spi');
writeSPIDERdoc(string,P2);
% UNNECESSARY BECAUSE A LARGE SET IS A SUPERSET OF A SMALLER SET
%for i = 1:size(good,1)
%    r = good(i);
%    j = S(r);
%    string=strcat('selfiles_1069/prj_sel_',num2str(j,'%05d'),'.spi');
%    R = readSPIDERdoc(string);
%    string=strcat('selfiles_pair/prj_sel_',num2str(j,'%05d'),'.spi');
%    writeSPIDERdoc(string,R);
%end
    
    
function [i1 i2] = decompUT(r) 

i1 = floor(sqrt(2*r)-1/2);
i2 = r - i1.*(i1+1)/2 + 1;


    



