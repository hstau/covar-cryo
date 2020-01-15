function verify(align_file)

addpath ../LMFnlsq/

ANG=readSPIDERdoc(align_file);
ang=ANG(:,1:3)*pi/180;
nump=size(ang,1);
ANG=[];

for i=1:nump
    v(1:4)=[0 0 0 1];
    v(5:8)=[ang(i,:) 0];
    tran=x2t_ZYZ(v','rpm');
    
    [ax ay az]=transform(tran,'rzyz');
    ANG=[ANG; ax ay az];     
end

writeSPIDERdoc('Nrandom1_short_modif.dat',ANG);