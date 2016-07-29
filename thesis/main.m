clear;
%% Portfolio
Settle = datenum('28-Jul-2016');
format = 'dd-mmm-yyyy';
portfolio=readtable('/home/alex/thesis/portfolio.xlsx');
portfolio=table2cell(portfolio);

swap_number=length(portfolio(:,1));
swap_settle=datenum(portfolio(:,1),format); 
swap_notional=cell2mat(portfolio(:,2));
swap_counterparty=cell2mat(portfolio(:,3)); 
swap_maturities=datenum(portfolio(:,4),format); 
swap_resets=cell2mat(portfolio(:,5));

% calculate the swap Rates
for i=1:swap_number
    swap_rates(i)=swapRates(zeroCurve,swap_resets(i),Settle,swap_settle(i),swap_maturities(i),'continuous');
end

%%

T=readtable('/home/alex/thesis/bloomberg/yield_curve.xlsx');
ZeroRates=(table2array(T(:,4))/100)';
Tenor = [1 2 7 30 60 90 180 270 360 450 540 630]/360;
Tenor=[Tenor [2:12] 15 20];
Tenor_days=Tenor*360;
Tenor_months=Tenor_days/30;


reset=4;
compounding='continuous';

zeroCurve = fit(Tenor',ZeroRates','cubicinterp');

%plot(feval(zeroCurve,0:0.5:20))
%%
figure;
plot(datemnth(Settle,Tenor_months), ZeroRates, 'o-');
xlabel('Date');
datetick('keeplimits');
ylabel('Zero rate');
grid on;
title('Yield Curve at Settle Date');

% swap curve construction
maturities=Settle+[0.5 1:20]*360;
start=Settle*ones(1,21);
swapRates=swapRates(zeroCurve,4,Settle,start,maturities,'continuous');

%%
T=readtable('/home/alex/thesis/bloomberg/bloombergVcube_red.xlsx');
Cap_Vol=[];
for i=3:2:9
    Cap_Vol=[Cap_Vol table2array(T(:,i))];
end
Cap_Vol=Cap_Vol'/100;
Cap_Strikes=[1 2 3 4]/100;
Cap_mat=[1:10];

[x,y]=meshgrid(Settle+Cap_mat*360,Cap_Strikes);
surf(x,y,Cap_Vol);
datetick;
xlabel('Maturities');
ylabel('Strikes');
zlabel('Volatility(in %)');
title('Cap Market Volatilities');
%%
initialGuess = [0.085 0.05];
lb = [-Inf 0.000000001];
ub = [Inf Inf];
opt = optimset('MaxIter',100,'TolFun',1e-5);
notional=100;

for i=1:length(Cap_Strikes)
    cap_prices_blk(i,:)=cap_price_blk(Cap_Vol(i,:),Cap_mat,Cap_Strikes(i),notional,zeroCurve,reset);
end

[x,resnorm,FVAL,Exitfalg,output]=...
    lsqnonlin(@(params)calibrateHWparams(params,cap_prices_blk,Cap_mat,zeroCurve,Cap_Strikes,notional,reset,compounding),initialGuess, lb, ub, opt);

params=x;
for i=1:length(Cap_Strikes)
     cap_prices_HW(i,:)=cap_price_HW(params,Cap_mat,zeroCurve,Cap_Strikes(i),notional,reset,compounding);
end

[x,y]=meshgrid(Settle+Cap_mat*360,Cap_Strikes);
surf(x,y,cap_prices_blk);
hold on
surf(x,y,cap_prices_HW);
datetick;
xlabel('Maturities');
ylabel('Strikes');
zlabel('Cap Prices');
title('Cap Prices: Market(Black''s) vs H-W ');

%% Construct the hull and White model

Compounding = -1;
Basis = 2;
ZeroDates=Settle+Tenor_days;
RateSpec = intenvset('StartDates', Settle,'EndDates', ZeroDates, ...
    'Rates', ZeroRates,'Compounding',Compounding,'Basis',Basis);

Alpha = params(1);

Sigma = params(2);

hw1 = HullWhite1F(RateSpec,Alpha,Sigma);

%% Generate yield curve scenarios

prevRNG = rng(0, 'twister');
sim_maturity=datenum('28-Apr-2020');
sim_dates=generate_sim_dates(Settle,sim_maturity);
dt = diff(yearfrac(Settle,sim_dates,2))';
nPeriods = numel(dt);
numScenarios=10;

scenarios = hw1.simTermStructs(nPeriods, 'nTrials',numScenarios, 'deltaTime',dt);

i = 10;
figure;
surf(Tenor_months, simulationDates, scenarios(:,:,i))
axis tight
datetick('y','mmmyy');
xlabel('Tenor (Months)');
ylabel('Observation Date');
zlabel('Rates');

%% MTM prices for IRS
Notional=100;

mtm(scenarios,Tenor,sim_dates,swap_maturities(i),swaprate,reset,Notional);

for j=1:numScenarios
    for i=1:swap_number
        IRS_mtm(i,:)=mtm(scenarios(:,:,j),Tenor,sim_dates,swap_settle(i),swap_maturities(i),swap_rates(i),swap_resets(i),swap_notional(i),compounding);
    end
end

plot(sim_dates,IRS_mtm)
datetick('keeplimits');
ylabel('Mark-To-Market Price($)');
xlabel('Simulation Dates');

%% MTM prices for the whole portfolio

