function [a b] = decomp2(in1, p_dim)
%addpath /home/liaoh/lib/matlab

NX = p_dim(1); 
a = floor(in1/NX);
a = in1 - a*NX;
b = (in1 - a)/NX;
