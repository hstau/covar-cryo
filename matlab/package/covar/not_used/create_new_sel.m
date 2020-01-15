function [R]=read_projs(th)

addpath /guam.raid.cluster.software/relion_more/matlab_lib/
addpath  /guam.raid.cluster.software/relion_more/matlab_lib/3dtrans
addpath  /guam.raid.cluster.software/relion_more/matlab_lib/LMFnlsq

S = [];

string=strcat('sel_ang.spi');
sel = readSPIDERdoc(string);

for i=1:size(sel,1) % for each ref projection 
   if(mod(i,100)==0)
          i
   end
   j = sel(i);
   string=strcat('selfiles/prj_sel_',num2str(j,'%05d'),'.spi');
   prj_sel = readSPIDERdoc(string);
   
   if (size(prj_sel,1) > th) % 2 8, 12, 30
     %string=strcat('selfiles_new/prj_sel_',num2str(j,'%05d'),'.spi');
     %writeSPIDERdoc(string,prj_sel);
     S = [S; j];
   end
end
string=strcat('sel_ang_new.spi');
writeSPIDERdoc(string,S);


end


