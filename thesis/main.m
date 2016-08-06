clear;
%% Portfolio
Settle = datenum('28-Jul-2016');
format = 'dd-mmm-yyyy';
portfolio=readtable('/home/alex/thesis/portfolio.xlsx');
portfolio=table2cell(portfolio);
compounding='continuous';

swap_number=length(portfolio(:,1));
swap_settle=datenum(portfolio(:,1),format); 
swap_notional=cell2mat(portfolio(:,2));
swap_counterparty=cell2mat(portfolio(:,3)); 
swap_maturities=datenum(portfolio(:,4),format); 
swap_resets=cell2mat(portfolio(:,5));
swap_type=portfolio(:,6);

% calculate the swap Rates
for i=1:swap_number
    swap_rates(i)=swapRates(zeroCurve,swap_resets(i),swap_settle(i),swap_maturities(i),'continuous');
end

%confirm that using the previous swap rates value of the contract is zero
% at t=0
swap_prices=IRS_Price(zeroCurve,Settle*ones(swap_number,1),swap_maturities,swap_rates,swap_notional,swap_resets,'continuous');

%%

T=readtable('/home/alex/thesis/bloomberg/yield_curve.xlsx');
ZeroRates=(table2array(T(:,4))/100)';
Tenor = [1 2 7 30 60 90 180 270 360 450 540 630]/360;
Tenor=[Tenor [2:12] 15 20];
Tenor_days=Tenor*360;
Tenor_months=Tenor_days/30;


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

% Alpha = params(1);
% Sigma = params(2);
Alpha = 0.2;
Sigma = 0.015;

hw1 = HullWhite1F(RateSpec,Alpha,Sigma);

%% Generate yield curve scenarios

prevRNG = rng(0, 'twister');
sim_maturity=datenum('28-Oct-2021');
sim_dates=generate_sim_dates(Settle,sim_maturity);
dt = diff(yearfrac(Settle,sim_dates,2))';
nPeriods = numel(dt);
numScenarios=10;

scenarios = hw1.simTermStructs(nPeriods, 'nTrials',numScenarios, 'deltaTime',dt);

i = 10;
figure;
surf(Tenor_months, sim_dates, scenarios(:,:,i))
axis tight
datetick('y','mmmyy');
xlabel('Tenor (Months)');
ylabel('Observation Date');
zlabel('Rates');

%% MTM prices for IRS

for j=1:numScenarios
    for i=1:swap_number
        prices(i,:)=mtm(scenarios(:,:,j),Tenor,sim_dates,swap_settle(i),swap_maturities(i),swap_rates(i),swap_resets(i),swap_notional(i),compounding,swap_type{i});
    end
    IRS_mtm(:,:,j)=prices;
end

j=5;
plot(sim_dates,IRS_mtm(:,:,j))
datetick('keeplimits');
ylabel('Mark-To-Market Price($)');
xlabel('Simulation Dates');
grid on;
%% MTM prices for the total portfolio

figure;
Total_value = squeeze(sum(IRS_mtm,1));
plot(sim_dates,Total_value);
title('Total MTM Portfolio Value for All Scenarios');
datetick('x','mmmyy');
ylabel('Portfolio Value ($)');
xlabel('Simulation Dates');

%% Calculate the exposures with or without Netting
netting=true;
for i=1:numScenarios
    [total_portfolio_exp(i,:) exp_cp(:,:,i)]=compute_exposures(IRS_mtm(:,:,i),swap_counterparty,netting);
end


%Plot the total Portfolio exposure

figure;
plot(sim_dates,total_portfolio_exp);
title('Portfolio Exposure for Different Scenarios');
datetick('x','mmmyy');
ylabel('Exposure ($)');
xlabel('Simulation Dates');

%Plot counterpart's exposure


%% Calculate the Expected Exposures
[total_EE EE_cp]=compute_EE(total_portfolio_exp,exp_cp);

figure;
plot(sim_dates,total_EE);
title('Portfolio Expected Exposure');
datetick('x','mmmyy');
ylabel('Expected Exposure ($)');
xlabel('Simulation Dates');

figure;
plot(sim_dates,EE_cp(2,:));
title('Counter Party Expected Exposure');
datetick('x','mmmyy');
ylabel('Expected Exposure ($)');
xlabel('Simulation Dates');

%% Generate Default Probabilities

cds_info=readtable('/home/alex/thesis/portfolio.xlsx','Sheet','Sheet2');
cds_info=table2cell(cds_info);

CDS_Dates = datenum(cds_info(:,1),format);
CDS_Spreads = cell2mat(cds_info(:,2:end));
[spreads num_counterparties]=size(CDS_Spreads); 

Recoveries=[0.4 0.4];

for i=1:num_counterparties
    intensities(:,i)=findIntensities(CDS_Spreads(:,i),Settle,CDS_Dates,Recoveries(i),zeroCurve,reset);
    Prob(:,i)=findDefaultProb(intensities(:,i),Settle,CDS_Dates,CDS_Dates);
    Prob_cva(:,i)=findDefaultProb(intensities(:,i),Settle,CDS_Dates,sim_dates);
end


figure;
plot(sim_dates,Prob_cva(:,1),'k-');
hold on
plot(sim_dates,Prob_cva(:,2),'b-');
title('Default probabilities per counterparty');
datetick('x','mmmyy');
ylabel('Default probability');
xlabel('Simulation Dates');
grid on

%% Combute the discount factors in the simulation dates and

T=yearfrac(Settle,sim_dates,2)';
df=DiscFactor(zeroCurve,T,compounding)';
df=df(2:end);
%% CVA calcultion

for i=1:num_counterparties
    F=diff(Prob_cva(:,i))';
    cva(i)=sum(df.*EE_cp(i,2:end).*F);
end
%% Spread Sensitivities(Delta, Gamma)

[delta]=delta_gamma_sensitivities(zeroCurve,Settle,CDS_Dates,CDS_Spreads,Recoveries,reset,sim_dates,df,EE_cp);

%% Wrong Way Risk


