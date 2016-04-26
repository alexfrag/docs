function P=P(a,t,T,Pt,PT,sigma,ft,rt)
% Function P(t,T) from Brigo-Mercurio, equation (3.39)
% Calculates price of ZCB in Hull-White model
% Inputs (in asc. order):
%   a           mean reversion parameter
%   t,T         times, t<T
%   Pt,PT       discount factors at t and T
%   sigma       volatility parameter
%   ft          instantaneous forward rate f(t)
%   rt          short rate r(t) from Hull-White model
% Formula: P=A(PT,Pt,a,t,T,sigma,ft)*exp(-B(a,t,T)*rt)
% where A() and B() are parts of the formula.
P=A(a,t,T,Pt,PT,sigma,ft)*exp(-B(a,t,T)*rt);