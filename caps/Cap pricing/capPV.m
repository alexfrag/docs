function [capPV, caplets]= ...
 capPV(a,tenor,tvector,Disc,anchorT,startT,endT,DiscAnchor,FAnchor,RAnchor,sigma,X)
% Function to value an interest rate cap on unit notional (N=1)
% Calculates price of caplets via "ZCB_put"-function and sums the caplets.
% First output is cap value, second output is matrix of caplets.
% Inputs (in asc. order):
%   a           mean reversion parameter
%   tenor       tenor in years, e.g. 0.5
%   tvector     vector of times t, used to look up row for disc. factors
%   Disc        vector of disc. factors (look up row index via t-vector)
%   anchor,     anchor date for calculation
%   start, end  of cap, years
%   DiscAnchor  Disc. factor, fwd. rate and short rate for anchor date.
%   FAnchor     -"-
%   RAnchor     -"-
%   sigma       volatility parameter
%   X           strike rate (=cap rate), 

% Initialize matrix
caplets=zeros(endT/tenor,5);

% Value each caplet
% Number of caplets depends on tenor and duration.
for i=1:endT/tenor,
    % Column 1+2: Start/end times in years. Used as input.
    caplets(i,1)=(i-1)*tenor;
    caplets(i,2)=i*tenor;
    % Column 3+4: Discount factors at start/end times. Used as input.
    % Find row index by looking up the start/end times in the t-vector.
    caplets(i,3)=Disc(find(tvector==caplets(i,1)),1);
    caplets(i,4)=Disc(find(tvector==caplets(i,2)),1);
    % Calls function for valuing a single caplet.
    if caplets(i,1)>=startT,
    caplets(i,5)=(1+X*tenor)* ... 
        ZCB_put(a,anchorT,caplets(i,1),caplets(i,2), ...
                DiscAnchor,caplets(i,3),caplets(i,4), ... 
                sigma,FAnchor,RAnchor,1/(1+X*tenor));
    end
end

% Valuing cap as sum of caplets in column 5, ignoring first caplet.
capPV=sum(caplets(2:end,5));