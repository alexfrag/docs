function PD=findDefaultProb(intensities,Settle,maturities,dates)
res=yearfrac(Settle, maturities,1);
dif=diff([0 res']);
for i=1:length(dates)
    q=1;
    j=1;
    while dates(i)>=maturities(j)
         q=q*exp(-intensities(j)*dif(j));
         j=j+1;
         if j>length(res)
             break;
         end
    end
    
    if j>length(res)
       q=q*exp(-intensities(j-1)*yearfrac(maturities(j-1),dates(i),1));
    elseif j==1
        q=q*exp(-intensities(j)*yearfrac(Settle,dates(i),1));
    else
        q=q*exp(-intensities(j)*yearfrac(maturities(j-1),dates(i),1));
        
    end
    PD(i)=1-q;
end

end