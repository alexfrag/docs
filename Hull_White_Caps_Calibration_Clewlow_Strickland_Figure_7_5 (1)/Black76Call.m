function y = Black76Call(F,K,T,v,P,PutCall)

d1 = (log(F/K) + 0.5*v^2*T)/v/sqrt(T);
d2 = d1 - v*sqrt(T); 

if strcmp(PutCall,'C')
	y = P*(F*normcdf(d1) - K*normcdf(d2));
else
	y = P*K*normcdf(-d2) - P*normcdf(-d1);
end
