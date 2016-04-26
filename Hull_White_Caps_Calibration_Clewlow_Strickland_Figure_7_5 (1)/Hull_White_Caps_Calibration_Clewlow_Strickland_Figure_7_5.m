% Calibration of Hull White model to interest rate caps.
% Reproduces Figure 7.5 in Clewlow and Strickland's book
% "Implementing Derivatives Models"

clc; clear;

% Valuation date
today = datenum('21-Jan-95');
t = 0;

% Input dates, caplet volatilities, discount factors from Figure 7.5
data = [...
	datenum('21-Mar-95')	0.1525	0.98979276;
	datenum('21-Jun-95')	0.1725	0.97331933;
	datenum('21-Sep-95')	0.1725	0.95552272;
	datenum('21-Dec-95')	0.1750	0.93703962;
	datenum('21-Mar-96')	0.1800	0.91817120;
	datenum('21-Jun-96')	0.1800	0.89963864;
	datenum('21-Sep-96')	0.1800	0.88145856;
	datenum('21-Dec-96')	0.1800	0.86366702;
	datenum('21-Mar-97')	0.1775	0.84619313;
	datenum('21-Jun-97')	0.1750	0.82923527;
	datenum('21-Sep-97')	0.1750	0.81261725;
	datenum('21-Dec-97')	0.1750	0.79633225;
	datenum('21-Mar-98')	0.1725	0.78027803;
	datenum('21-Jun-98')	0.0000  0.76465985];

% Caplet Maturities.
T = (data(:,1) - today)./365;

% Black caplet volatilities from the market.
v = data(:,2);

% Pure discount bond factors.
P = data(:,3);

% Strike rate for the cap.
K = 0.07;

% Bond principal.
Principal = 1;

% Bond face value.
Face = Principal*(1+K/4);

% Calculate the market prices of the caplets.
N = length(v);
for i=1:N-1
	r(i)   = -log(P(i))/T(i);
	dt(i)  = T(i+1) - T(i);
%	dt(i)  = 0.25;                % Make dt consistent with C&L
	f(i)   = -log(P(i+1)/P(i))/dt(i);
    Caplet(i) = Black76Call(f(i),K,T(i),v(i),P(i+1),'P')*.25;
end

% Market prices of the caps is cumulative sum.
MarketCap = cumsum(Caplet)';

% Find the HW parameters: alpha and sigma.
% Caplets are put options in Black's model.
PutCall = 'P';
SetOptions = optimset('TolFun', 1e-5, 'TolX', 1e-5, 'MaxIter', 1e5, 'MaxFunEvals', 1e7);
start = [-.2 .05];
[beta feval] = fminsearch(@(b) findWHparams(b,MarketCap,Principal,T,t,P,Face,PutCall), start, SetOptions);

% Caplet prices from Hull White model.  A series of put options
alpha = beta(1)
sigma = beta(2)
for i=1:N-1
	HW(i) = HWCaplet(Principal,T(i),t,T(i+1),P(i),P(i+1)*Face,alpha,sigma,PutCall);
end

% Cap prices from the Hull White model.
HWC = cumsum(HW)';

% Compare the market caps and HW caps
Compare = [MarketCap HWC]
