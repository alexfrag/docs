function A=A(a,t,T,Pt,PT,sigma,ft)
% Function A.
% Calculates part of formula from Brigo-Mercurio, section 3.3.2
% Inputs (in asc. order):
%   a           mean reversion parameter
%   t,T         times, t<T
%   Pt,PT       discount factors at t and T
%   sigma       volatility parameter
%   ft          instantaneous forward rate f(t)
% Formula:
% A=PT/Pt*exp(B(a,t,T)*ft-(sigma^2/4*a)*(1-exp(-2*a*t))*B(a,t,T)^2)
% where B() is another function.
A=PT/Pt*exp(B(a,t,T)*ft-(sigma^2/4*a)*(1-exp(-2*a*t))*B(a,t,T)^2);
