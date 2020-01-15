function [J,ssq]=ls(eigv,C,rota_mat_file)

MAT=readSPIDERdoc(rota_mat_file);

N=size(eigv,1);
C=reshape(C,81,1);
eval(eigv,C);

%C=zeros(9,9);
[J,ssq] = LMFnlsq(@FUN,C);
ssq
    function y=FUN(x)
        y=[];
        x=reshape(x,9,9);
        for i=1:N
            eig=eigv(i,:); % eig is a row vector
            eig=eig';
            R=x*eig;

            R=reshape(R,3,3);
            RO=MAT(i,:);
            %if(i==999)
            %    RO
            %end
            RO=reshape(RO,3,3);
            
            D=R-RO;
  
            S=sum(diag(D'*D));
            y=[y sqrt(S)];
        end
        y=y';
    end
J=double(J);
save coefficients J -ascii;
eval(eigv,J);
end

function eval(eigv,x)
    N=size(eigv,1);
    y=0;
    x=reshape(x,9,9);
    for i=1:N
         eig=eigv(i,:); % eig is a row vector
         eig=eig';
         R=x*eig;

         R=reshape(R,3,3);
    
         a=R'*R-eye(3);
         b=det(R)-1;
  
         S=sum(diag(a'*a))+b*b;
         y=y+S;
    end
     y

end
