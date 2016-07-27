function cap_prices=cap_price_blk(cap_volatilities,maturities,strike,notional,zeroCurve,reset)
rows = length(cap_volatilities); 
cap_prices = ones(rows,1);
tau=1/reset;
cap = zeros(1,rows);
for i=1:rows
    tms=0:tau:maturities(i);
    for j=1:maturities(i)*reset
        sigma=cap_volatilities(i);
        DF=DiscFactor(zeroCurve,tms(j+1),'continuous');
        F=forward_rate(zeroCurve,tms(j),tms(j+1),'continuous');
        cpl=DF*tau*caplet_price_blk(strike,F,sigma,tms(j),tau);
        cap(i)=cap(i)+cpl;
    end
end
cap_prices=notional*cap;
end

function cpl_price=caplet_price_blk(K,F,cap_vol,T,tau)
u= cap_vol*sqrt(T);
Nd1 = normcdf(((log(F/K)+u^2 /2)/u),0,1);
Nd2 = normcdf(((log(F/K)-u^2 /2)/u),0,1);
cpl_price=F*Nd1-K*Nd2;
end


