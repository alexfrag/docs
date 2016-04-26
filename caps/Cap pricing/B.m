function B=B(a,t,T)
% Function B.
% Calculates part of formula from Brigo-Mercurio, section 3.3.2
% Inputs:
%   a   (mean reversion parameter)
%   t,T (times, t<T)
% Formula: B=(1/a)*(1-exp(-a*(T-t)))
B=(1/a)*(1-exp(-a*(T-t)));
 