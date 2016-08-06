function [total_exp exp_cp]=compute_exposures(prices_mtm,swap_counterparty,netting)
% computes the exposure, for each counterparty and in total for the
% portfolio,for each scenario seperetly.
% swap_counterparty= counterpartiesXdates

[num_swaps num_dates]=size(prices_mtm);
if netting==true
    c=unique(swap_counterparty);
    for i=1:length(c)
        idx=find(swap_counterparty==c(i));
        x=sum(prices_mtm(idx,:));
        y=zeros(1,num_dates);
        exp_cp(i,:)=max(x,y);
    end
    total_exp=sum(exp_cp);
        
elseif netting==false
    c=unique(swap_counterparty);
    for i=1:length(c)
        idx=find(swap_counterparty==c(i));
        x=prices_mtm(idx,:);
        y=zeros(size(x));
        exp_cp(i,:)=sum(max(x,y));
    end
     total_exp=sum(exp_cp);  
    
else
    disp('netting should be set either to True or False')
    return;

end
    
end