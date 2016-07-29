function sim_dates=generate_sim_dates(Settle,Maturity)

% first 3 months weekly
months=3;
sim_dates_weekly=[0:7:7*4*months];
sim_dates_weekly=Settle*ones(1,length(sim_dates_weekly))+sim_dates_weekly;

% next 9 months monthly
months=9;
sim_dates_monthly=[0:30:months*30];
sim_dates_monthly=sim_dates_monthly(2:end);
sim_dates_monthly=sim_dates_weekly(end)*ones(1,length(sim_dates_monthly))+sim_dates_monthly;

quarters_tot=floor((Maturity-sim_dates_monthly(end))/90);
sim_dates_quarterly=[0:90:quarters_tot*90];
sim_dates_quarterly=sim_dates_quarterly(2:end);
sim_dates_quarterly=sim_dates_monthly(end)*ones(1,length(sim_dates_quarterly))+sim_dates_quarterly;

if (quarters_tot==(Maturity-sim_dates_monthly(end))/90)
    sim_dates=[sim_dates_weekly sim_dates_monthly sim_dates_quarterly];
else
    sim_dates=[sim_dates_weekly sim_dates_monthly sim_dates_quarterly Maturity];
end


