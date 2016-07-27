%%
settle=datenum('14-Dec-2007')
contract_reset_dates=settle+[90 180 240 360]
reset=4;
maturity=settle+360;
yearfrac(settle,contract_reset_dates,2)
sim_dates=simulationDates;
swaprate=0.0351;
start=settle
Tenor=[3 6 12 60 84 120 240 360]./12; %in months
scen=scenarios(:,:,1);
tau=1/reset;
N=100;
[num_dates,num_tenors]=size(scen);
for i=1:num_dates
    if maturity<sim_dates(i)
        mtm(i)=0;
    else
        zeroCurve = fit(Tenor',scen(i,:)','cubicinterp');
        indx=find(sim_dates(i)<=contract_reset_dates);
        yf=yearfrac(sim_dates(i),contract_reset_dates(indx(1)),2);
        sum= yf*swaprate*DiscFactor(zeroCurve,yf,compounding);
        for j=2:length(indx)
            yf=yearfrac(sim_dates(i),contract_reset_dates(indx(j)),2);
            sum=sum+tau*DiscFactor(zeroCurve,yf,compounding)*swaprate;
        end
        mtm(i)=N*(-DiscFactor(zeroCurve,0,compounding)+DiscFactor(zeroCurve,yearfrac(sim_dates(i),maturity),compounding)+sum);
    end
end
    