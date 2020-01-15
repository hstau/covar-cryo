function [J,resnorm,residual,output]=coef(eigv,C, options)

N=size(eigv,1);
C=reshape(C,81,1);
eval(eigv,C)

count =0;
res=[];

[J,resnorm,residual,output] = lsqnonlin(@FUN,C,[],[],options);

    function y=FUN(x)
        count=count+1
        y=[];
        obj=0;
        x=reshape(x,9,9);
        parfor i=1:N
            eig=eigv(i,:); % eig is a row vector
            eig=eig';
            R=x*eig;

            R=reshape(R,3,3);
    
            a=R'*R-eye(3);
            b=det(R)-1;
  
            S=sum(diag(a'*a))+b*b;
            obj=obj+S;
            y=[y sqrt(S)];
        end
        obj
        res=[res obj]; 
        y=y';
        
    end
J=double(J);
save coefficients J -ascii;
%eval(eigv,J);
save iter_result res;
end

function eval(eigv,x)
    N=size(eigv,1);
    y=0;
    x=reshape(x,9,9);
    parfor i=1:N
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
