function [a b c] = decomp3(in1, v_dim)
%addpath /home/liaoh/lib/matlab

NX = v_dim(1); 
NY = v_dim(2); 
NN = NX*NY;
a = floor(in1/NX);
a = in1 - a*NX;
in1 = (in1 - a)/NX;
c = floor(in1/NY);
b = in1 - c*NY;