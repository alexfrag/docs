function f=forward_rate(zeroCurve,dates_start,dates_matures,compounding)
    tau=dates_matures-dates_start; %in years
    if strcmp(compounding,'simple')
        f=(1./tau).*(DiscFactor(zeroCurve,dates_start,compounding)./DiscFactor(zeroCurve,dates_matures,compounding)-1);
    elseif strcmp(compounding,'continuous')
        f=-log(DiscFactor(zeroCurve,dates_matures,compounding)./DiscFactor(zeroCurve,dates_start,compounding))./tau;
    else
        display('No such argument exists');
end