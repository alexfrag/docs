function [delta]=delta_gamma_sensitivities(zeroCurve,Settle,CDS_Dates,CDS_Spreads,Recoveries,reset,sim_dates,df,EE_cp)
epsilon=1;
tilts=[-50:10:50];
[num_dates num_counterparties]=size(CDS_Spreads);
for k=1:length(tilts)
    
    CDS_Spreads_tilted=CDS_Spreads+tilts(k);
    
    for i=1:num_counterparties
        
          intensities(:,i)=findIntensities(CDS_Spreads(:,i),Settle,CDS_Dates,Recoveries(i),zeroCurve,reset);
          intensities_epsilon_plus(:,i)=findIntensities(CDS_Spreads_tilted(:,i),Settle,CDS_Dates,Recoveries(i),zeroCurve,reset);

%         intensities(:,i)=findIntensities(CDS_Spreads_tilted(:,i),Settle,CDS_Dates,Recoveries(i),zeroCurve,reset);
%         intensities_epsilon_plus(:,i)=findIntensities(CDS_Spreads_tilted(:,i)+epsilon,Settle,CDS_Dates,Recoveries(i),zeroCurve,reset);
%         intensities_epsilon_minus(:,i)=findIntensities(CDS_Spreads_tilted(:,i)-epsilon,Settle,CDS_Dates,Recoveries(i),zeroCurve,reset);

          Prob_cva(:,i)=findDefaultProb(intensities(:,i),Settle,CDS_Dates,sim_dates);
          Prob_cva_epsilon_plus(:,i)=findDefaultProb(intensities_epsilon_plus(:,i),Settle,CDS_Dates,sim_dates);
%         Prob_cva(:,i)=findDefaultProb(intensities(:,i),Settle,CDS_Dates,sim_dates);
%         Prob_cva_epsilon_plus(:,i)=findDefaultProb(intensities_epsilon_plus(:,i),Settle,CDS_Dates,sim_dates);
%         Prob_cva_epsilon_minus(:,i)=findDefaultProb(intensities_epsilon_minus(:,i),Settle,CDS_Dates,sim_dates);
    end

    for i=1:num_counterparties
        F=diff(Prob_cva(:,i))';
        F_plus=diff(Prob_cva_epsilon_plus(:,i))';
%         F_minus=diff(Prob_cva_epsilon_minus(:,i))';
        cva(i)=sum(df.*EE_cp(i,2:end).*F);
        cva_epsilon_plus(i)=sum(df.*EE_cp(i,2:end).*F_plus);
%         cva_epsilon_minus(i)=sum(df.*EE_cp(i,2:end).*F_minus);
    end
    
    delta(k)=(sum(cva_epsilon_plus)-sum(cva))/epsilon;
%     gamma(k)=(sum(cva_epsilon_plus)-2*sum(cva)+sum(cva_epsilon_minus))/(epsilon^2);
end
    
end