function intensities=findIntensities(market_spreads,Settle,maturities,Rec,zeroCurve,reset)

res=yearfrac(Settle, maturities,1);
dif=diff([0 res']);
L=1-Rec;
%cdsprice(a,b,spread,Lgd,gamma,zeroCurve,resetFreq)
x=[];
gammas=[];
for i=1:length(res)
    gamma=0.05;
    gamma=fzero(@(gamma)cdsprice(0,res(i),market_spreads(i),L,[x gamma*ones(1,dif(i)*reset)],zeroCurve,reset),gamma);
    gammas=[gammas gamma];
    x=[x gamma*ones(1,dif(i)*reset)];
end

intensities=gammas;
% gamma1=fzero(@(gamma1)cdsprice(0,0.5,39.1,L,[gamma1*ones(1,2)],zeroCurve,reset),gamma1);
% gamma2=fzero(@(gamma2)cdsprice(0,1,47.327,L,[gamma1*ones(1,2) gamma2*ones(1,2)],zeroCurve,reset),gamma2);
% gamma3=fzero(@(gamma3)cdsprice(0,2,54.669,L,[gamma1*ones(1,2) gamma2*ones(1,2) gamma3*ones(1,4)],zeroCurve,reset),gamma3);

end