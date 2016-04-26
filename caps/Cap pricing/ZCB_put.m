function ZCB_put=ZCB_put(a,t,T,S,Pt,PT,PS,sigma,ft,rt,X)
% Function ZCB_put from Brigo-Mercurio, section 3.3.2 (equation 3.41)
% Calculates price of ZCB put option in Hull-White model.
% Inputs (in asc. order):
%   a           mean reversion parameter
%   t,T,S       times, t<T<S (T is option and S is bond maturity)
%   Pt,PT,PS    discount factors at t, T and S
%   sigma       volatility parameter
%   ft          instantaneous forward rate f(t)
%   rt          short rate r(t) from Hull-White model
%   X           strike rate (=cap/floor rate), 
% Formula: ZCB_put=X*P_tT*normcdf(-h+sigma_p,0,1)-P_tS*normcdf(-h,0,1),
% where ZCB prices for bonds maturing at S and T are called P_tS, P_tT,
% and h and sigma_p are calculated in this function:
%       sigma_p=sigma*(((1-exp(-2*a*(T-t)))/(2*a))^(0.5))*B
%       h=(1/sigma_p)*log(P_tS/(P_tT*X))+sigma_p/2
%       [B is yet another function: B=(1/a)*(1-exp(-a*(S-T)))]

% Call ZCB functions for option expiry and bond maturity dates.
P_tS=P(a,t,S,Pt,PS,sigma,ft,rt);
P_tT=P(a,t,T,Pt,PT,sigma,ft,rt);

% Calculate other intermediary steps.
sigma_p=sigma*(((1-exp(-2*a*(T-t)))/(2*a))^(0.5))*B(a,T,S);
h=(1/sigma_p)*log(P_tS/(P_tT*X))+sigma_p/2;

% Final function.
ZCB_put=X*P_tT*normcdf(-h+sigma_p,0,1)-P_tS*normcdf(-h,0,1);