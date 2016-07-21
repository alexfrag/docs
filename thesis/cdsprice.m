function price=cdsprice(a,b,spread,Lgd,gamma,zeroCurve,resetFreq)
frac=1/resetFreq;
T=a:frac:b;
spread=spread/100/100;
j=(b-a)*resetFreq;
Gamma_j=zeros(1,j+1);
for i=2:(j+1)
Gamma_j(i)=Gamma_j(i-1)+frac*gamma(i-1);
end
Protect_Leg=0;
Premium_Leg_a=0;
Premium_Leg_b=0;
for i=1:j
  Premium_Leg_a=Premium_Leg_a+gamma(i)*quad(@(u)Premium_Leg(u,Gamma_j(i),gamma(i),zeroCurve,T(i)),T(i),T(i+1));
  Premium_Leg_b=Premium_Leg_b+exp(-Gamma_j(i))*feval(zeroCurve,T(i+1))*frac;
  Protect_Leg=Protect_Leg+gamma(i)*quad(@(u)ProtectionLeg(u,Gamma_j(i),gamma(i),zeroCurve,T(i)),T(i),T(i+1));
end

price=spread*(Premium_Leg_a+Premium_Leg_b)-Lgd*Protect_Leg;
end
%cdsprice(0,1,spread,0.4,gamma,fitobject,4)
