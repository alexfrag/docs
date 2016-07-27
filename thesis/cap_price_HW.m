function price=cap_price_HW(params,maturities,zeroCurve,strike,Notional,reset,compounding)
alpha = params(1);
sigma = params(2);
tau=1/reset;
X=1/(1+strike*tau);

for j=1:length(maturities)
    cap=0;
    maturity=maturities(j);
    times=0:tau:maturity;
    for i=2:maturity*reset
        cap=cap+ZBP(times(i),times(i+1),X,zeroCurve,alpha,sigma,compounding);
    end
    price(j)=Notional*cap;
end

end

function ZBP=ZBP(t_prev,t_cur,X,zeroCurve,alpha,sigma,compounding)
B=1/alpha*(1-exp((-alpha*(t_cur-t_prev))));
sigmaP=sigma*sqrt((1-exp(-2*alpha*(t_prev-0)))/(2*alpha))*B;
h= (1/sigmaP) * log(DiscFactor(zeroCurve,t_cur,compounding)/(DiscFactor(zeroCurve,t_prev,compounding)*X))+sigmaP/2;

d1 =-h+sigmaP;
d2 =-h; 

ZBP=X*DiscFactor(zeroCurve,t_prev,compounding)*normcdf(d1,0,1)-DiscFactor(zeroCurve,t_cur,compounding)*normcdf(d2,0,1);

end