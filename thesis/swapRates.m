function swapRates=swapRates(zeroCurve,reset,settle,start,maturities,compounding)
start=start-settle;
maturities=maturities-settle;
tau=1/reset;
for i=1:length(maturities)
    sum=0;
    whole_dates=floor(yearfrac(start(i),maturities(i))/tau);
    ts=1:whole_dates;
    ts=ts*tau;
    for j=1:length(ts)
        sum=sum+DiscFactor(zeroCurve,ts(j),compounding)*tau;
    end
    res_tau=yearfrac(start(i),maturities(i))-whole_dates*tau;
    sum=sum+DiscFactor(zeroCurve,yearfrac(start(i),maturities(i)),compounding)*res_tau;
     
    swapRates(i)=(DiscFactor(zeroCurve,start(i),compounding)-DiscFactor(zeroCurve,yearfrac(start(i),maturities(i)),compounding))/sum;
end

end