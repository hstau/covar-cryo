function array=trace(lambda,ind2,ind3,type,const,th)
addpath /guam.raid.home/liaoh/lib/matlab
addpath /guam.raid.cluster.software/relion_more/matlab_lib/

% read angle sel file 
sel = readSPIDERdoc('covar/sel_ang.spi');
I = size(sel,1); 
% read one total
%out=strcat('/data2/liaoh/new_with_covar_reduce_index_DHX_fine/big_tot_matlab/tot_',num2str(1,'%05d'));
out=strcat('/data2/liaoh/new_with_covar_reduce_index_DHX_',type,'/big_tot_matlab/tot_',num2str(1,'%05d'));
p = load(out);
% sizes
N1 = size(p.toti,2)
% N = sqrt(N1);
% initial array
array = zeros(N1,1);
array = sparse(array);
%

%string=strcat('covar/vol_var_f02.spi');
%init = readSPIDERfile(string);
%v_dim(1)=size(init,1);
%v_dim(2)=size(init,2);
%v_dim(3)=size(init,3);
%init = compress_volume(init,ind3,v_dim); 
%ss = sqrt(size(array,1));
%array = reshape(array,ss,ss);
%dd_ind = ss*[0:ss-1]'+[1:ss]';
%array(dd_ind) = init(:);
%array = array(:);
%
% get the diagonal and upper triangular elements
% [ind_v, dind_v] = ut(N);
% iterate all
report = zeros(100,1);
lambda = lambda*0.5;
for n = 1:30
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
        string=strcat('covar/selfiles/prj_sel_',num2str(l,'%05d'),'.spi');
        prj_sel = readSPIDERdoc(string);
        if (size(prj_sel,1) > th)
            % load tot
            out = strcat('/data2/liaoh/new_with_covar_reduce_index_DHX_',type,'/big_tot_matlab/tot_',num2str(j,'%05d'));
            p = load(out);
            A = p.toti;
            p = [];
            % size data
            M1 = size(A,1);
            MM = MM + M1;
            cc = cc + 1;
            % initial array
            data = zeros(M1,1);
            data = sparse(data);
            % get the diagonal and upper triangular elements
            % [ind_p, dind_p] = ut(M);
            % load data
            %string=strcat('forw_',type,num2str(l,'%05d'),'.txt');
            %data = load(string);
            %data=data(:);
            string=strcat('covar/stats/f1NscovarA_',type,num2str(l,'%05d'),'.txt'); % run
            data = load(string);
            % data(ind_p) = prj.cov_2d;
            %cov = data;
            %ss = sqrt(size(cov,1))
            %cov = reshape(cov,ss,ss);
            %var=get_diag2(cov,ind2,j);
            %string = strcat('var_see',num2str(l,'%05d'),'.spi');
            %writeSPIDERfile(string,var);
            % data = prj.cov_2d(:);
            % iteration
            %whos A array data
            array = array + lambda*A'*(data - A*array);
            %tic
            if (const == 1)
                [gr, fr, array] = array_constraints(array);
                frs = frs + fr;
                grs = grs + gr;
            end
            %toc
            %array = array - mu*sign(array); %l1min(array,mu);
            resid = resid + norm(data - A*array);
        end
    end
    if n == 1
        MM
        cc
    end
    % get the diag elemetns
    var = get_diag3(array,ind3);
    str = strcat('f1NvarA_',num2str(const),'_3a',type,num2str(n,'%02d'),'_',num2str(th,'%03d'),'.spi');
    writeSPIDERfile(str,var);
    %l1=sum(abs(array))
    resid
    frs = frs / cc
    grs = grs / cc
    report(n) = resid;
    string =   strcat('f1NreportA_',num2str(const),'_3a',type,num2str(n,'%05d'),'_',num2str(th,'%03d'));
    save(string,'report');
    %array_total = array;
    string = strcat('f1NarrayA_total_',num2str(const),'_3a',type,num2str(n,'%05d'),'_',num2str(th,'%03d'));
    save(string,'array','-v7.3');
    %save array_total_fine array -v7.3
end
% get the diagonal and upper triangular elements
function [ind,dind] = ut(N)
ind = repmat([1:N]',1,N) + repmat(N*[0:N-1],N,1);
dind = diag(ind);
[u v ind] = find(triu(ind)); % ind_v is column vector

% read total
function toti=read_tot(i)

out=strcat('tot_matlab/tot_',num2str(i,'%05d'));
toti=load(out);

function array = l1min(array,mu)

array = array - mu*sign(array);

