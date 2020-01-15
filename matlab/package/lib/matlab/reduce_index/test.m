function test(M)

N = 10000;

a = zeros(N,1);

for i=1:N

a(i) = std(randn(1000,1)/M);
a(i) = a(i)*a(i);
end

m =mean(a)
va = std(a)

