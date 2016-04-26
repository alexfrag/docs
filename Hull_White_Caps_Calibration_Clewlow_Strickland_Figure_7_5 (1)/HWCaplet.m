function y = HWCaplet(K,T,t,s,PT,Ps,alpha,sigma,PutCall)

% Hul White caplets and floorlets in Black's 1976 model

% The Hull White variance.
sigmaP2 = sigma^2/2/alpha^3 * (1-exp(-2*alpha*(T-t))) * (1-exp(-alpha*(s-T)))^2;

% The Hull White volatility.
sigmaP = sqrt(sigmaP2);

d1 = log(Ps/PT/K)/sigmaP + sigmaP/2;
d2 = d1 - sigmaP;

% Caplet is a put, floorlet is a call
if strcmp(PutCall,'P')
	y = K*PT*normcdf(-d2) - Ps*normcdf(-d1);
elseif strcmp(PutCall,'C')
	y = Ps*normcdf(d1) - K*PT*normcdf(d2);
end