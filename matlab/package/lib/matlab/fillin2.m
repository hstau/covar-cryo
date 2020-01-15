function result = fillin2(result2)
%addpath /home/liaoh/lib/matlab
M = size(result2,1)*4;
NX = sqrt(M);
NX2 = NX/2;
result2 = reshape(result2,NX2,NX2);
result = zeros(NX,NX);
for i = 1:2
    for j=1:2
       result(i:2:end,j:2:end) = result2;
    end
end

