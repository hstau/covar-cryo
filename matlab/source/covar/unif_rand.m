function read_projs(NU)

string=strcat('sel_ang_764.spi');
S = readSPIDERdoc(string);
string=strcat('binned_angles_764.spi');
A = readSPIDERdoc(string);

A = A * pi/180;
%rng(1);
% random search for the best NU projections
num = min(NU, size(A,1));
mm = 1e-10;
for t = 1:1000 % 100 trials
    r = randperm(size(A,1));
    r = r(1:num)';
    rtheta = A(r,2);
    rphi = A(r,3);
    refv=[cos(rphi).*sin(rtheta) sin(rphi).*sin(rtheta) cos(rtheta)];
    inn = abs(refv*refv');
    inn = 1 - inn;
    score = sum(inn(:));
    
    if score > mm
        good = r;
        mm = score;
    end
end

S1 = S(good);
A = A(good);
string=strcat('sel_ang_unif.spi');
writeSPIDERdoc(string,S1);
string=strcat('binned_angles_unif.spi');
writeSPIDERdoc(string,A*180/pi);

for i = 1:size(good,1)
    r = good(i);
    j = S(r);
    string=strcat('selfiles_764/prj_sel_',num2str(j,'%05d'),'.spi');
    R = readSPIDERdoc(string);
    string=strcat('selfiles_unif/prj_sel_',num2str(j,'%05d'),'.spi');
    writeSPIDERdoc(string,R);
end
    
    


