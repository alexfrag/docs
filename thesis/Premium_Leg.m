function result=Premium_Leg(u,Gamma_j,gamma,fitobject,low_bound)
   result=exp(-Gamma_j-gamma.*(u-low_bound)).*feval(fitobject,u)'.*(u-low_bound);