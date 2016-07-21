function P=DiscFactor(zeroCurve,T,compounding)
 if strcmp(compounding,'continuous')
       P=exp(-feval(zeroCurve,T).*T);
 elseif strcmp(compounding,'simple')
       P=1./(1+feval(zeroCurve,T).*T);
 else
       display('No such argument exists');
end
