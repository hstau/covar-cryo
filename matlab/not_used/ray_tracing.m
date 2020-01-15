function [amat]=trace(ang,v_dim, p_dim, ind2, ind3, op)
addpath /guam.raid.cluster.software/relion_more/matlab_lib/
%addpath /guam.raid.home/liaoh/2D_var_simul_xabier/data/both/covar/lib
addpath /guam.raid.home/liaoh/lib/matlab

% read the angles
psi  = ang(:,1);
theta=ang(:,2);
phi  =ang(:,3);
I=size(ang,1);
% amat contains all the rays from all the views 
if op == 1
    parfor i = 1:I % for each view
        if(mod(i,1)==0)
            i
        end
        euler = [psi(i) theta(i) phi(i)];
        
        mat = project6(euler, v_dim, p_dim, ind2, ind3, i);
        amat{i} = mat;
        %write2ascii(amat{i},i);
    end
    save amat
else
   % op
   % kk=1
   % load alist;
   % load amat;
end

function write2ascii(amati,i)

    [row col w] = find(amati);
    A = [row col w];
    out=strcat('amat/amat_',num2str(i,'%05d'),'.txt');
    dlmwrite(out,A,'precision',32,'delimiter',' ')
    %fid=fopen(out,'w');
    %fprintf(fid,'%d %d %f\n',A);
    %fclose(fid);

    
