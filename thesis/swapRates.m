function swap_Rates=swapRates(zeroCurve,resets,start,maturities,compounding)

tau=1./resets;
for i=1:length(maturities)
    sum=0;
    whole_dates=floor(yearfrac(start(i),maturities(i),1)/tau(i));
    ts=1:whole_dates;
    ts=ts*tau(i);
    for j=1:length(ts)
        sum=sum+DiscFactor(zeroCurve,ts(j),compounding)*tau(i);
    end
    res_tau=yearfrac(start(i),maturities(i),1)-whole_dates*tau(i);
    sum=sum+DiscFactor(zeroCurve,yearfrac(start(i),maturities(i),1),compounding)*res_tau;
     
    swap_Rates(i)=(DiscFactor(zeroCurve,0,compounding)-DiscFactor(zeroCurve,yearfrac(start(i),maturities(i),1),compounding))/sum;
end

end