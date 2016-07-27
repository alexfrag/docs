numScenarios=10;
Settle = datenum('14-Dec-2007');

months=3;
sim_dates_weekly=[0:7:7*4*months];
sim_dates_weekly=Settle*ones(1,length(res))+sim_dates_weekly;


months=9;
sim_dates_monthly=[0:30:months*30];
sim_dates_monthly=sim_dates_monthly(2:end);
sim_dates_monthly=sim_dates_weekly(end)*ones(1,length(sim_dates_monthly))+sim_dates_monthly;


sim_dates=[sim_dates_weekly sim_dates_monthly];

yearfrac(Settle,sim_dates,2)

dt = diff(yearfrac(Settle,simulationDates,1));
nPeriods = numel(dt);

scenarios = hw1.simTermStructs(nPeriods, 'nTrials',numScenarios, 'deltaTime',dt);