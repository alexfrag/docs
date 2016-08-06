function [total_EE EE_cp]=compute_EE(total_portfolio_exp,exp_cp)
[num_scen num_dates]=size(total_portfolio_exp);
total_EE=sum(total_portfolio_exp)/num_scen;
for i=1:size(exp_cp,1)
    EE_cp(i,:)=sum(squeeze(exp_cp(i,:,:))')/num_scen;
end
end