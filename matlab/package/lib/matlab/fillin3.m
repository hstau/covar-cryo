function result = fillin(result2)
%addpath /home/liaoh/lib/matlab

N = size(result2,1)*8;
NX = round(N^(1/3));
NX2 = NX/2;
result2 = reshape(result2,NX2,NX2,NX2);
result = zeros(NX,NX,NX);
for i = 1:2
    for j=1:2
       for k = 1:2
          result(i:2:end,j:2:end,k:2:end) = result2;
       end
    end
end

