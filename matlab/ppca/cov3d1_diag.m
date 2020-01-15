function [ E, A, S, Mu, V, cv, hp, lc ] = get_data(v_dim)
addpath /guam.raid.cluster.software/relion_more/matlab_lib/
addpath /guam.raid.home/liaoh/lib/matlab/

%load amat
load X 
load PM
load ind3
V = 1;
voli = readSPIDERfile('covar/vol_var_32.spi');
voli = compress_volume(voli,ind3,v_dim); 
ncomp = 2;
opts = struct( 'maxiters', 30,...
               'algorithm', 'vb',...
               'xprobe', [],...
               'uniquesv', 0,...
               'cfstop', [ 100 0 0 ],...
               'minangle', 0 );

 %[ E, A, S, Mu, V, cv, hp, lc ] = pca_diag( X, PM, V, voli, ncomp,opts );
[ E, A, S, Mu, V, cv, hp, lc ] = pca_diag_new( X, PM, V, voli, ncomp);

vol=expand_volume(E(:,1),ind3,v_dim);
writeSPIDERfile('ppca2.spi',vol);
%vol=expand_volume(E(:,2),ind3,v_dim);
%writeSPIDERfile('kk2.spi',vol);

%pca_full( X, ncomp, amat, V, voli, varargin );
%pca_diag1( X, amat, V, ncomp, voli(:) );

%out_head = strcat('covar/stats/scovar_',type);
%write_image_stack(out_head,j,cov_2d);

