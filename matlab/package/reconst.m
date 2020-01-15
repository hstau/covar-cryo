function cov_3d = reconst(lambda,sel_ang,sel_prj_pref,mat_pref,cov2d_pref,ind3,const,th)
% 
% RECONST computes the 3D covariance, given the 2D covariance, which in turn are computed per angle bin. The problem is poised as an solving iteratively a system of linear equations. See "algebraic reconstruction techniques."
% 
% Input:  
%       lambda        - float relaxation parameter for the iterative algorithm
%	sel_ang       - string, filename containing the indeces of angle bins
%       sel_prj_pref  - string, rootname of files containing indeces of particles
%       mat_pref      - string, rootname of files containing the coefficients of the linear system per angle bin
%       cov2d_pref    - string, rootname of file containing the 2D covariance for a angle bin 
%  	ind3  	      - cell with two vectors of indeces: fine and coarse grid in 3D volume
%       const         - integer, if 1 then contraint applied
%       th            - integer minimum size of a bin above which it is considered
% Returns:
%                     - 3D covariance
% 
%       Author:
% 	Hstau Liao
% 	Columbia University
%	Frank Lab
%	hstau.y.liao@gmail.com
%	
% Tested:	
%	MATLAB2013a
% Copyright notice: You are free to modify, extend and distribute 
%    this code granted that the author of the original code is 
%    mentioned as the original author of the code.


% read angle sel file 
sel = readSPIDERdoc(sel_ang);
I = size(sel,1); 
% read one set of coefficients to determine some sizes 
out=strcat(mat_pref,num2str(1,'%05d'));
p = load(out);
% sizes
N1 = size(p.toti,2);
% initial array
cov3d = zeros(N1,1);
cov3d = sparse(cov3d);
%

% iteration begins
report = zeros(100,1);
lambda = lambda*0.5;
for n = 1:15 % usually less than 15 is needed
    n
    resid = 0;
    frs = 0;
    grs = 0;
    J = randperm(I);
    MM = 0;
    cc = 0;
    for i = 1:I % for each view (block-ART)
        j = J(i);
        l = sel(j);
        %string=strcat('covar/selfiles/prj_sel_',num2str(l,'%05d'),'.spi');
        string=strcat(sel_prj_pref,num2str(l,'%05d'),'.spi');
        prj_sel = readSPIDERdoc(string);
        if (size(prj_sel,1) > th)
            %out = strcat('/data2/liaoh/new_with_covar_reduce_index_DHX_',type,'/big_tot_matlab/tot_',num2str(j,'%05d'));
            out = strcat(mat_pref,num2str(j,'%05d'));
            p = load(out);
            A = p.toti;
            p = [];
            % size data
            M1 = size(A,1);
            MM = MM + M1;
            cc = cc + 1;
            % initial solution set to zero
            data = zeros(M1,1);
            data = sparse(data);
            string=strcat(cov2d_pref,num2str(l,'%05d'),'.txt'); % run 
            data = load(string);
            % main iterative step
            cov3d = cov3d + lambda*A'*(data - A*cov3d);
            %
            if (const == 1)
                [gr, fr, cov3d] = array_constraints(cov3d);
                frs = frs + fr;
                grs = grs + gr;
            end
            resid = resid + norm(data - A*array);
        end
    end
    if n == 1
        MM
        cc
    end
    % get the variance which are the diag elements of cov3d
    var = get_diag3(cov3d,ind3);
    str = strcat('var_',num2str(const),'_',num2str(n,'%02d'),'_',num2str(th,'%03d'),'.spi');
    writeSPIDERfile(str,var);
    % check the residual (should not diverge)
    resid
    frs = frs / cc   
    grs = grs / cc  
    report(n) = resid;
    % store partial results
    string = strcat('cov3d',num2str(const),'_',num2str(n,'%05d'),'_',num2str(th,'%03d'));
    save(string,'cov3d','-v7.3');
end

