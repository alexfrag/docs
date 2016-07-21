function y = findWHparams(params,MarketCap,Principal,T,t,P,Face,PutCall);
alpha = params(1);
sigma = params(2);

N = length(T);

% Caplets are put options in Black's 1976 model.
for i=1:N-1
	HW(i) = HWCaplet(Principal,T(i),t,T(i+1),P(i),P(i+1)*Face,alpha,sigma,PutCall);
end

% Caps are the cumulative sum of the caplets.
HWC = cumsum(HW)';

% Objective function.
y = sum(((HWC - MarketCap)./MarketCap).^2);

% Penalty ensures that sigma>0.
if sigma<0
	y = 1e100;
end
