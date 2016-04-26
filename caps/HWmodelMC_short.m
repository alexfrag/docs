%% Input parameters

T=10;               %time horizon for Monte Carlo simulation (years)
numsteps=360;       %no. of time points per year (choose even number)
dt=1/numsteps;      %timestep size (years)
nsteps=numsteps*T;  %no. of time points in a path
npaths=10000;       %no. of Monte Carlo paths/simulations

% Input zero coupon bond curve
inputrates= ...
[0.50	0.00465000
1.00	0.00409446
2.00	0.00442813
3.00	0.00555560
4.00	0.00746453
5.00	0.00960987
6.00	0.01167396
7.00	0.01366151
8.00	0.01544121
9.00	0.01698286
10.00	0.01836848
11.00	0.01960868
12.00	0.02071576
15.00	0.02312037];

%% Interpolated zero and forward rates

% Current xIBOR rate
ft=inputrates(1,2);

% Interpolation of zero rates
ratesdata(:,1)=(0:dt:inputrates(end,1))'; % times t
ratesdata(:,2)=...
    interp1(inputrates(:,1),inputrates(:,2),ratesdata(:,1),'spline',ft);
    % Syntax: New y's as function of original x's and y's, spline type and
    % extrapolation values (flat xIBOR rate).

% Calculate disc. factors and forward rates from zero rates
ratesdata(:,4)=exp(-ratesdata(:,1).*ratesdata(:,2));                % disc.
ratesdata(2:end,3)=(ratesdata(1:end-1,4)./ratesdata(2:end,4)-1)/dt; % fwd.
ratesdata(1,3)=ft; % set 1st obs=flat rate.

% Plot zero and fwd. rates
figure
plot(ratesdata(2:end,1),100*ratesdata(2:end,2), ...
     ratesdata(2:end,1),100*ratesdata(2:end,3), ...
     inputrates(2:end,1),100*inputrates(2:end,2),'o');
legend('Interpolated zero rates','Forward rates','Zero rates','location','northwest')

%% Calibration of parameters - STEP 1 Initialization

% Based on Brigo-Mercurio, section 3.3.2 and Hull, 30.3+30.8
% Using a number of predefined functions and two parameters, price a cap.
% Correct way: The other way! Given prices, find parameters.

% Input cap maturities, strike rates and prices
capprices= ...
[1.00	0.0021	0.0006
2.00	0.0029	0.0025
3.00	0.0060	0.0058
4.00	0.0078	0.0114
5.00	0.0098	0.0193
6.00	0.0118	0.0286
7.00	0.0136	0.0385
8.00	0.0152	0.0488
9.00	0.0166	0.0590
10.00	0.0178	0.0691];
capmats=capprices(:,1);
strike=capprices(:,2);
marketprices=capprices(:,3);

% Initialize vectors
modelprices=zeros(10,1);
capdata=cell(10,1);

% Choose discount factors and forward rates from imported rates.
t=ratesdata(1:nsteps+1,1);
Disc=ratesdata(1:nsteps+1,4);
Fwd=ratesdata(1:nsteps+1,3);
clear inputrates ratesdata

% Set initial parameters for calibration (spot starting caps)
DiscAnchor=Disc(1,1);
FAnchor=Fwd(1,1);
RAnchor=ft;

%% Calibration of parameters - STEP 2 Optimization

% Goal: Calibrate mean reversion and volatility parameters a and sigma.
% Comparison: Cap prices for uncalibrated model
xvec=[0.75;0.05];
[uncalprices,~]=...
    Calibration(xvec,capmats,t,Disc,DiscAnchor,FAnchor,RAnchor,strike);

% Set options
options=optimset('tolfun',1e-11);
% Call function for curve fit via least squares (minimizes SSE)
[xCurrent,~,FVAL,~,OUTPUT,~,~] = ...
    lsqcurvefit(@(xvec,capmats) ...
    Calibration(xvec,capmats,t,Disc,DiscAnchor,FAnchor,RAnchor,strike), ...
    [0.75;0.0005],capmats,marketprices, ...
    [0,0],[],options);
% Syntax:
% 1. Define variable vector and x-axis values.
% 2. Call function using variable, x-values and other parameters,
% 3. Type initial variable guesses, x-values and target y-values
% 4. Set options: lower/upper bounds (here none), other via "optimset"

% Save values from calibrated model, incl. caplets for each cap as check.
[calprices,calcaps]=...
  Calibration(xCurrent,capmats,t,Disc,DiscAnchor,FAnchor,RAnchor,strike);
a=xCurrent(1,1);
sigma=xCurrent(2,1);

% Plot market prices against uncalibrated and calibrated model
figure
plot(capmats, 10000*uncalprices, ...
     capmats, 10000*calprices, ...
     capmats, 10000*marketprices, 'o')
legend('Uncalibrated model','Calibrated model','Market prices','location','northwest')

%% Monte Carlo simulation of r

% If errors: Try different a and sigma, e.g. 0 (deterministic)
% sigma=0.005
% a=realmin % Ho-Lee model has a=0 (undefined, use "realmin")

% Calculate theta(t) vector. Last term ignored (numerically problematic).
dF=Fwd(2:nsteps+1,:)-Fwd(1:nsteps,:); % change in forward rates
    % Note: F(t-1) due to mean reversion part of the drift: 
    % theta(t)-a*r(t-1)~=F'(t)+a(F(t-1)-r(t-1))
theta=dF+a*Fwd(1:nsteps); %+(sigma^2/(2*a))*(1-exp(-2*a*t)); (ignored)

% % Make random matrix dz (scaled by timestep size)
% Fast, but requires a lot of memory.
% dz=randn(npaths,nsteps)*sqrt(dt); 

% Initialize r and dr matrices and set r(t=0).
r=zeros(npaths,nsteps+1);
r(:,1)=ft;
dr=zeros(npaths,nsteps);

% Generate interest rate paths by looping over columns.
echo off
for i=1:nsteps,
    % Random vector dz (slow, but requires less memory)
    dz=randn(npaths,1)*sqrt(dt);
    % 1: Calculate increments dr=(theta-ar)dt+?dz
    dr(:,i)=theta(i)-a*r(:,i)*dt+sigma*dz(:,1);%dz(:,i);
    % 2: Cumulate r by: r(t+1)=r(t)+dr(t)
    r(:,i+1)=r(:,i)+dr(:,i);
end
echo on

% Save results and clear variables
% dr=dr(1:100,1:100);
clear dz dr theta
% meanr=r;
meanr=mean(r);
r=r(1:100,:);

% Plot the simulation
xaxis=(0:dt:nsteps*dt);
figure
subplot(2,2,1) % 10 simulations of r
plot(xaxis,100*r(1:10,:))
subplot(2,2,2) % Many simulations of r
plot(xaxis,100*r)
subplot(2,2,[3 4]) % Big lower plot
plot(xaxis,100*meanr,xaxis,100*Fwd.')
legend('Mean r','Forward rates','location','northwest')
mtit('Monte Carlo simulation of rates r') % major title across subplots