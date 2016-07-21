function [sm,pr] = sumprod(A)
% returns the sum and product of the elements of a vector.

sm = getsum(A);
pr = getprod(A);


function sm = getsum(A)
% subfunction to sumprod
sm = sum(A);


function pr = getprod(A)
% subfunction to sumprod
pr = prod(A);
