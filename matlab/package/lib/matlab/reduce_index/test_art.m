function x = test_art(lamb)
A=[1 1 1 0 0 0 0 0 0;  % horiz 
   0 0 0 1 0.5 1 0 0 0; 
   0 0 0 0 0 0 1 1 1;
   1 0 0 1 0 0 1 0 0;  % vertical
   0 1 0 0 0.5 0 0 1 0; 
   0 0 1 0 0 1 0 0 1
   1 0 0 0 0.5 0 0 0 0.5; %diag
   0 1 0 0 0 1 0 0 0;
   0 0 0 1 0 0 0 1 0];

b = [3 2.5 3 3 2.5 3 2.5 2 2]'
perf_data = A*ones(size(b))
x = zeros(9,1);
for i=1:20
    x = x + lamb*A'*(b-A*x);
    s = reshape(x,3,3)
    norm(b-A*x)
end
sol = A\b