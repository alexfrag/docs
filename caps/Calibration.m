function [Calibration,caps]=...
    Calibration(xvec,xaxis,tvector,Disc,DiscAnchor,FAnchor,RAnchor,strike)
% Sample function for calibrating cap market for t=1:10
% Runs a loop for valuing caps - see function "capPV".

% Extract variables from x-vector. 
a=xvec(1);
sigma=xvec(2);

% Initialize vector
modelprices=zeros(10,1);
caplets=cell(10,1);

% Run loop for valuing 10 caps.
for maturity=1:xaxis(end,1)
    [modelprices(maturity,1),caplets{maturity}]= ...
     capPV(a,0.5,tvector,Disc,0,0,maturity, ...
         DiscAnchor,FAnchor,RAnchor,sigma,strike(maturity,1));
end

% Saves output.
Calibration=modelprices;
caps=caplets;