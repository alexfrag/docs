function defaultProb=findDefProb(market_spreads,maturities,L,gamma0,fitobject)
% gamma1=.05;
% gamma2=.05;
% sa=[39.1 47.327  54.669  63.894  72.652 77.16];
Zero_Time = [.5 1 2 3 4 5]';
Zero_Rate = [1.35 1.43 1.9 2.47 2.936 3.311]'/100
fitobject=fit(Zero_Time,Zero_Rate,'cubicinterp')
L=0.6;
gamma3=0.05;
% PEURC=feval(fitobject,[1/360:1/360:5]);
% gamma1=fzero(@(gamma1)CDS(0,0.5,sa(1)/100/100,L,gamma1*ones(1,3),PEURC),gamma1);
% gamma2=fzero(@(gamma1)CDS(0,1,sa(2)/100/100,L,[gamma1*ones(1,3) gamma2*ones(1,3)],PEURC),gamma2);
end
cdsprice(a,b,spread,Lgd,gamma,zeroCurve,resetFreq)
gamma1=fzero(@(gamma1)cdsprice(0,0.5,39.1,L,[gamma1*ones(1,2)],fitobject,4),gamma1);
gamma2=fzero(@(gamma2)cdsprice(0,1,47.327,L,[gamma1*ones(1,2) gamma2*ones(1,2)],fitobject,4),gamma2);
gamma3=fzero(@(gamma3)cdsprice(0,2,54.669,L,[gamma1*ones(1,2) gamma2*ones(1,2) gamma3*ones(1,4)],fitobject,4),gamma3);