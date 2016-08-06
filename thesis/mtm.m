function mtm=mtm(scen,Tenor,sim_dates,settle,maturity,swaprate,reset,Notional,compounding,type)
% Tenor(in years)
% sim_dates(matlab datenum form)
% maturity (matlab datenum form)

contract_reset_dates=[settle:floor(360/reset):maturity];
contract_reset_dates=contract_reset_dates(2:end);
tau=1/reset;
[num_dates,num_tenors]=size(scen);
    for i=1:length(sim_dates)
        if maturity<sim_dates(i)
            mtm(i)=0;
        else
            zeroCurve = fit(Tenor,scen(i,:)','cubicinterp');
            indx=find(sim_dates(i)<=contract_reset_dates);
            yf=yearfrac(sim_dates(i),contract_reset_dates(indx(1)),2);
            sum= yf*swaprate*DiscFactor(zeroCurve,yf,compounding);
            for j=2:length(indx)
                yf=yearfrac(sim_dates(i),contract_reset_dates(indx(j)),2);
                sum=sum+tau*DiscFactor(zeroCurve,yf,compounding)*swaprate;
            end
%             if sim_dates(i)<=contract_reset_dates(end)
%                 res_tau=yearfrac(contract_reset_dates(end),maturity,1);
%             else
%                 res_tau=yearfrac(sim_dates(i),maturity,1);
%             end
%             sum=sum+res_tau*DiscFactor(zeroCurve,yearfrac(sim_dates(i),maturity,1),compounding)*swaprate;
            if strcmp(type,'Payer')
                mtm(i)=Notional*(DiscFactor(zeroCurve,0,compounding)-DiscFactor(zeroCurve,yearfrac(sim_dates(i),maturity,1),compounding)-sum);
            elseif strcmp(type,'Receiver')
                mtm(i)=Notional*(-DiscFactor(zeroCurve,0,compounding)+DiscFactor(zeroCurve,yearfrac(sim_dates(i),maturity,1),compounding)+sum);
            else
                disp('No such IRS type');
            end
        end
    end
    
end
    