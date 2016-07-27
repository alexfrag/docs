function objective=calibrateHWparams(params,MarketCap,Maturities,zeroCurve,strikes,Notional,reset,compounding)
alpha = params(1);
sigma = params(2);
counter=0;
for j=1:length(strikes)
    strike=strikes(j);
    for i=1:length(MarketCap)
        Cap_HW(i,j) = cap_price_HW(params,Maturities(i),zeroCurve,strike,Notional,reset,compounding);
    end
end
Cap_HW=Cap_HW';
% Objective function.
objective = (Cap_HW(:) - MarketCap(:))./MarketCap(:);

end