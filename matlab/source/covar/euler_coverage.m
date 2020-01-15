function euler_coverage()

sel_unif=readSPIDERdoc('sel_ang.spi');
sa=zeros(size(sel_unif,1),3);
ang=readSPIDERdoc('refangles.spi');
for i=1:size(sel_unif,1);
    j=sel_unif(i,1);
    sa(i,:) = ang(j,:);
end
writeSPIDERdoc('euler_1069.spi',sa);