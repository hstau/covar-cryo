function find_num_neigh(a,b,N)

addpath ../
addpath ~/rr2734/3D/matlab_lib/

parfor i=1:N
    i
    nn=INT(a+(i-1)*(b-a)/N);
  
    C=ones(9);

    [W,V1]=embedding4_tune_nn(sigma,nn,1);
     
    [J,ssq,res]=coef(V1,C);

    file=strcat('res/res', (i));
    writeSPIDERdoc(file,res);

    file=strcat('res/ssq', (i));
    writeSPIDERdoc(file,ssq);
       
end

