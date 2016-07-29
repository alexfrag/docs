function IRS_Price(zeroCurve,start,maturities,swaprate,Notional,reset,compounding)
maturities=maturities-start;
tau=1/reset;
start=0;
for i=1:length(maturities)
    whole_dates=floor(yearfrac(start,maturities(i),2)/tau);
    sum=0;
    ts=1:whole_dates;
    ts=ts*tau;
    for j=1:length(ts)
        sum=sum+tau*swaprate*DiscFactor(zeroCurve,ts(j),compounding);
    end
    res_tau=yearfrac(start(i),maturities(i),2)-whole_dates*tau
    sum=sum+res_tau*swaprate*DiscFactor(zeroCurve,yearfrac(start,maturities(i),2),compounding);
    
    
    RFS(i)=Notional*(-DiscFactor(zeroCurve,start,compounding)+DiscFactor(zeroCurve,yearfrac(start,maturities(i),2),compounding)+sum);
end

end


% settle=datenum('14-Dec-2007')
% contract_reset_dates=settle+[90:90:15*90];
% reset=4;
% maturity=settle+15*90;
% yearfrac(settle,contract_reset_dates,2)
% sim_dates=simulationDates;
% swaprate=kk;
% start=settle;
% Tenor=[3 6 12 60 84 120 240 360]./12; %in months
% scen=scenarios(:,:,1);
% tau=1/reset;
% N=100000;
% [num_dates,num_tenors]=size(scen);
% for i=1:num_dates
%     if maturity<sim_dates(i)
%         mtm(i)=0;
%     else
%         zeroCurve = fit(Tenor',scen(i,:)','cubicinterp');
%         indx=find(sim_dates(i)<=contract_reset_dates);
%         yf=yearfrac(sim_dates(i),contract_reset_dates(indx(1)),2);
%         sum= yf*swaprate*DiscFactor(zeroCurve,yf,compounding);
%         for j=2:length(indx)
%             yf=yearfrac(sim_dates(i),contract_reset_dates(indx(j)),2);
%             sum=sum+tau*DiscFactor(zeroCurve,yf,compounding)*swaprate;
%         end
%         mtm(i)=N*(-DiscFactor(zeroCurve,0,compounding)+DiscFactor(zeroCurve,yearfrac(sim_dates(i),maturity,2),compounding)+sum);
%     end
% end
%     
