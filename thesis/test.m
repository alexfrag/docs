%%
addpath('/home/alex/thesis');
%%
Settle = '21-Jan-2008';

Rates= [0.0627; 0.0657; 0.0691; 0.0717; 0.0739; 0.0755; 0.0765; 0.0772;
    0.0779; 0.0783; 0.0786; 0.0789];

ValuationDate = '21-Jan-2008';
EndDates = {'21-Mar-2008';'21-Jun-2008';'21-Sep-2008';'21-Dec-2008';...
    '21-Mar-2009';'21-Jun-2009';'21-Sep-2009';'21-Dec-2009';....
    '21-Mar-2010';'21-Jun-2010';'21-Sep-2010';'21-Dec-2010'};


Compounding = -1;
Basis = 0;

RateSpec = intenvset('ValuationDate', ValuationDate, ...
'StartDates', ValuationDate, 'EndDates', EndDates, ...
'Rates', Rates, 'Compounding', Compounding, 'Basis', Basis)




%%
res = datenum(EndDates)-datenum(Settle);
res=res/360;
zeroCurve = fit(res,Rates,'cubicinterp')
feval(zeroCurve,res)
%%
MarketMaturity = {'21-Mar-2008'; '21-Jun-2008'; '21-Sep-2008'; '21-Dec-2008';
    '21-Mar-2009'; '21-Jun-2009'; '21-Sep-2009'; '21-Dec-2009';
    '21-Mar-2010'; '21-Jun-2010'; '21-Sep-2010'; '21-Dec-2010'};
MarketMaturity = datenum(MarketMaturity);
strike=[0.0590 0.0790];
notional=100;
reset=4;

cap_volatilities =[0.1533 0.1731 0.1727 0.1752 0.1809 0.1800 0.1805 0.1802...
    0.1735 0.1757;
    0.1526 0.1730 0.1726 0.1747 0.1808 0.1792 0.1797 0.1794...
    0.1733 0.1751];
maturities=[1 2 3 4 5 6 7 8 9 10]
cap_prices(1,:)=cap_price_blk(cap_volatilities,maturities,strike,notional,zeroCurve,reset);


cap_prices(1,:)=cap_price_blk(cap_volatilities(1,:),maturities,strike(1),notional,zeroCurve,reset);
cap_prices(2,:)=cap_price_blk(cap_volatilities(2,:),maturities,strike(2),notional,zeroCurve,reset);

%%
initialGuess = [0.085 0.05];
lb = [-Inf 0.000000001];
ub = [Inf Inf];
opt = optimset('MaxIter',100);
reset=4;
compounding='continuous';


[x,resnorm,FVAL,Exitfalg,output]=...
    lsqnonlin(@(params)calibrateHWparams(params,cap_prices,maturities,zeroCurve,strike,notional,reset,compounding),initialGuess, lb, ub, opt);

params=x;

price=cap_price_HW(params,maturities,zeroCurve,strike(1),notional,reset,compounding)
price=cap_price_HW(params,maturities,zeroCurve,strike(2),notional,reset,compounding)


%%