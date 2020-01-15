function [J,ssq]=ca(eigv,C,options)

N=size(eigv,1);
C=reshape(C,1,81);
eval(eigv,C);
%C=zeros(9,9);
[J,ssq] = anneal(@FUN,C,[options]);
ssq
    function y=FUN(x)
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
    end
J=double(J);
save coeff_anneal J -ascii;

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