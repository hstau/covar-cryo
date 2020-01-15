function [gr, fr,array] = constraints(array)
ss = sqrt(size(array,1));
array = reshape(array,ss,ss);
% diagonal non-neg
dd = diag(array);
dd_ind = ss*[0:ss-1]'+[1:ss]';
array(dd_ind) = dd.*(dd >= 0); % non-negative
gr = sum(dd >= 0)/ss;
% extra diag smaller than product of diag
dd = diag(array); %optional
cross = dd*dd' + 1e-12;
ta = (array.*array) <= cross;
array = array.* ta + (1-ta).*sign(array).*sqrt(cross);    
array = array(:);
fr = sum(ta(:))/(ss*(ss-1));




