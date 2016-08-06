# -*- coding: utf-8 -*-
"""
Created on Thu Aug  4 12:27:29 2016

@author: alex
"""

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from scipy.stats import norm
from sklearn import neighbors
import sys
import argparse
class CodingTest:
    
    def __init__(self):
        self.args=lambda:None
        self.args.tradesPath=""
        self.args.PricesPath=""
        
        self.args.debug=False
    
    def equity_curve(self):
        """
        Construction of the equity(wealth) curve
        
        """
        Dates= self.trades['date'].unique()
        
        #extract the proxy prices and compute daily returns
        spy=self.prices[['date','SPY.P']].set_index('date')
        spy=spy.loc[Dates]
        self.proxy_returns=np.array(spy.pct_change()).squeeze()
        self.proxy_returns=self.proxy_returns[1:]
        
        #portfolio value at each time step
        value_long=np.zeros(len(Dates))
        value_short=np.zeros(len(Dates))
       
        #portfolio return at each time step
        self.ret_long=np.zeros(len(Dates)-1)
        self.ret_short=np.zeros(len(Dates)-1)
        self.total_returns=np.zeros(len(Dates)-1)
        
        #portfolio return at each time step
        profit_long=np.zeros((len(Dates)-1))
        profit_short=np.zeros((len(Dates)-1))
        
        #create a dataframe which will hold our daily positions(contain the stock quatities)
        h=self.prices.columns[1:]
        df=pd.DataFrame(np.zeros((1,len(h))), columns=h)
        w1=0
        w2=0
        for indx,date in enumerate(Dates):
            #extract trades for this particular date
            curr_trades=self.trades[self.trades.date==date]
            qty=np.array(curr_trades.qty)
            ric=list(curr_trades.ric)
            
            #extract stock closing prices for this particular date
            stock_prices=self.prices[self.prices.date==date]
            stock_prices=stock_prices.drop('date', axis=1)
            
            if indx>0: #we cannot compute returns for the very first date
               
                dollar_value=np.array(df)*np.array(stock_prices)
                tot_val_long=np.nansum(dollar_value[dollar_value>0]) #evaluate only long positions
                total_val_short=np.nansum(dollar_value[dollar_value<0]) #evaluate only short positions
                
                # compute the returns for long and short positions seperetly: Price(end)/Price(start) -1
                self.ret_long[indx-1]=tot_val_long/value_long[indx-1]-1
                self.ret_short[indx-1]=-(total_val_short/value_short[indx-1]-1)
                self.total_returns[indx-1]=w1*self.ret_long[indx-1]+w2*self.ret_short[indx-1]
                
                # compute the profit for long and short positions seperetly
                profit_long[indx-1]= tot_val_long-value_long[indx-1]
                profit_short[indx-1]=total_val_short-value_short[indx-1]
                
               
               
            # update the quantities for each stock
            for i,stocks in enumerate(ric):
                df[stocks]=df[stocks]+qty[i]
            
            # current postition (closing)value at this time step
            curr_value=np.array(df)*np.array(stock_prices)
            value_long[indx]=np.nansum(curr_value[curr_value>0])
            value_short[indx]=np.nansum(curr_value[curr_value<0])
            tot=value_long[indx]+abs(value_short[indx])
            w1=value_long[indx]/tot
            w2=abs(value_short[indx])/tot
            
        
        fig = plt.figure()
        
        
        ax1=fig.add_subplot(111, xlabel='Dates',ylabel='Profit in $',title='Equity curve')
        self.eqCurve=pd.Series(profit_long+profit_short, index=Dates[1:]).cumsum()
        self.eqCurve.plot(ax=ax1)
        
#        ax1=fig.add_subplot(211, xlabel='Dates',ylabel='Profit in $ (long)',title='Equity curve')
#        self.eqCurve_long=pd.Series(profit_long, index=Dates[1:]).cumsum()
#        self.eqCurve_long.plot(ax=ax1)
        
#        ax2=fig.add_subplot(212, xlabel='Dates',ylabel='Profit in $ (short)')
#        self.eqCurve_short=pd.Series(profit_short, index=Dates[1:]).cumsum()
#        self.eqCurve_short.plot(ax=ax2)
        
        plt.show()
    
    @staticmethod 
    def Drawdown(equity_curve,Dates):
        
        """Calculates the Drawdown Curve given the equity curve and a set of dates"""
        
        high_water_mark=[0]
        drawdown=pd.Series(index=Dates)
        for i in range(1,len(equity_curve)):
            high_water_mark.append(max(high_water_mark[i-1], equity_curve[i]))
            drawdown[i]=high_water_mark[i]-equity_curve[i]
        return np.max(drawdown),drawdown
    
    def performance_metrics(self):
        """
        Compute Sharpe ratio, Hit ratio, Maximum DrawDown, Average holding period
        
        """
        
        # Make sure that the user has run the method  equity_curve before this one
        try:
            self.total_returns
            self.eqCurve
            self.proxy_returns
        except AttributeError:
            print("A mandatory instant attribute for this method has not defined. Run equity_curve first.")
            sys.exit(0)
        
        Dates=self.trades['date'].unique()
         
        # Sharpe Ratio
        # definition=(E(R)-E(R_proxy))/std(E(R)-E(R_proxy))       
        
        Sharpe_ratio=(np.mean(self.total_returns)-np.mean(self.proxy_returns)) /(np.std(self.total_returns)-np.std(self.proxy_returns))
        print('THE COMPUTED SHARPE RATIO IS: %f \n'%Sharpe_ratio)
            
        # Hit Ratio
        #Definition:number of periods with positive alphas divided by the total number of periods
        num_periods=len(Dates)-1
        hits_total=np.sum(self.total_returns>self.proxy_returns)
        hit_ratio_total=float(hits_total)/num_periods
        print('THE COMPUTED HIT RATIO IS: %f \n'%hit_ratio_total)
        
        # Drawdown Curve/Maximum Drawdown for long and short positions separately
         
        max_drawdown,drawdown=self.Drawdown(self.eqCurve,Dates)
        print('THE COMPUTED MAX DRAWDOWN IS: %f \n'%max_drawdown)
        
#        max_drawdown_long,drawdown_long=self.Drawdown(self.eqCurve_long,Dates)
#        max_drawdown_short,drawdown_short=self.Drawdown(self.eqCurve_short,Dates)
#        
        fig = plt.figure()
        ax1=fig.add_subplot(111, xlabel='Dates',ylabel='DrawDown',title='DrawDown Curve')
        self.drawdown=pd.Series(drawdown, index=Dates[1:])
        self.drawdown.plot(ax=ax1)
        
#        ax1=fig.add_subplot(211, xlabel='Dates',ylabel='DrawDown',title='DrawDown Curve')
#        self.eqCurve_long=pd.Series(drawdown_long, index=Dates[1:])
#        self.eqCurve_long.plot(ax=ax1)
        
#        ax2=fig.add_subplot(212, xlabel='Dates',ylabel='DrawDown (short)')
#        self.eqCurve_short=pd.Series(drawdown_short, index=Dates[1:])
#        self.eqCurve_short.plot(ax=ax2)
        
        plt.show()
        
        return Sharpe_ratio,hit_ratio_total,max_drawdown
        
    def alpha_curve(self):
        """
        Compute and generate the alpha curve plot
        
        """
        
         # Make sure that the user has run the method equity_curve before this one
        try:
            self.ret_long
            self.ret_short
            self.proxy_returns
        except AttributeError:
            print("A mandatory instant attribute for this method has not defined. Run equity_curve first.")
            sys.exit(0)
   
        data_long=self.ret_long-self.proxy_returns
        data_short=self.ret_short-self.proxy_returns
        
        # Fit a normal distribution to the data
        mu_long=np.mean(data_long)
        std_long=np.std(data_long)
        mu_short= np.mean(data_short)
        std_short= np.std(data_short)
        
        fig = plt.figure()
        
        ax1 = fig.add_subplot(211)
        ax1.hist(data_long,bins=20,normed=1)
        xmin=np.amin(data_long) 
        xmax=np.amax(data_long) 
        x=np.linspace(xmin, xmax, 200)
        p=norm.pdf(x,mu_long,std_long)
        ax1.plot(x,p,'k',linewidth=2)
        ax1.set_title("Gaussian fit and Histogram(alpha decay)")
        ax1.set_xlabel("Alpha Value")
        ax1.set_ylabel("Density(Long)")
        
        ax2=fig.add_subplot(212)
        ax2.hist(data_short,bins=20,normed=1)
        xmin=np.amin(data_short) 
        xmax=np.amax(data_short) 
        x=np.linspace(xmin, xmax, 200)
        p=norm.pdf(x,mu_short,std_short)
        ax2.plot(x,p,'k',linewidth=2)
        ax2.set_xlabel("Alpha Value")
        ax2.set_ylabel("Density(short)")
       
        plt.show()
    def indicator_test(self):
    
        """ 
        Check if the trading indicators (level,sig1,sig2,sig3) could be used to predict excess returns
        
        My idea here was:
        
        1)For each stock trade in the tradesList.csv file to find its settlement and closing date. 
          Then compute the return between those dates.    
        2) Use the dates computed from the previous step, to find the return for the SPY.P proxy
        3) Compute the excess returns for each individual stock.
        4) Create a binary array, with 1's indicate positive excess returs and 0's negative excess returns.
        5) Normalize the feature vector to have mean of 0 and variance of 1
        6) Split your dataset in  a trainning and testing set.
        7) Train the K-NN using the training set and the test it using the testing set
        
        """

        features=np.empty((0,4))
        labels=np.array([])
        unique_stocks=self.trades['ric'].unique()
        unique_stocks=unique_stocks.tolist()
        
        #Remove the SPY.P stock since we don't have signal indicators for it
        unique_stocks.remove('SPY.P')
        
        spy=self.prices[['date','SPY.P']].set_index('date')
       
        # steps 1-4
        for i,stock in enumerate(unique_stocks):
            
            pos=self.trades.ric==stock
            df=self.trades[pos]
            for indx in df.trdIx.unique():
                df_stock=df.loc[df['trdIx'] == indx]
                if len(df_stock)<2:
                    continue
                qty=np.array(df_stock.qty)
                price=np.array(df_stock.price)
                if qty[0]>0:
                    stock_return= abs((qty[1]*price[1])/(qty[0]*price[0]))-1
                else:
                    stock_return= abs((qty[0]*price[0])/(qty[1]*price[1]))-1
                
                proxy_prices=np.array(spy.loc[df_stock.date])
                proxy_return=proxy_prices[1]/proxy_prices[0]-1
                
                labels=np.append(labels,stock_return>proxy_return)
                feature_vector=np.array([[df_stock.level.iloc[0],df_stock.sig1.iloc[0],df_stock.sig2.iloc[0],df_stock.sig3.iloc[0]]])
                features=np.append(features,feature_vector, axis=0)
         
        # normalize features having zero mean and variance of 1
        f_m=np.mean(features,axis=0)
        f_s=np.std(features,axis=0)
        features=(features-f_m)/f_s
        
        # Run the k-nearest neighbours classifier
        neighbor=5
        clf = neighbors.KNeighborsClassifier(neighbor)
        clf.fit(features[:1200,:], labels[:1200])
        z=clf.predict(features[1201:,:])
        res=z==labels[1201:]
        
        print('THE SIGNALS PREDICT EXCESS RETURNS WITH ACCURACY: %f \n'%(float(np.sum(res))/len(res)))
        

    
    def readCSV(self):
        """Reads the CSV files and stores them to a pandas dataframe"""
       
        try:
            self.trades=pd.read_csv(self.args.tradesPath)
            self.prices=pd.read_csv(self.args.PricesPath)
            self.prices=self.prices.rename(columns={'Unnamed: 0': 'date'})

        except Exception as e:
            print(e)
            sys.exit(0)
    
    def run(self):
        """The main method which wraps all the previous defined functionalities""" 
        
        self.readCSV()
        self.equity_curve()
        sharpe_ratio, hit_ratio,max_drawdown=self.performance_metrics()
        self.alpha_curve()
        self.indicator_test()
        
        
def main():
    
    parser = argparse.ArgumentParser(description='Coding Test')
    parser.add_argument("tradesPath", help="Provide the path for the tradeList.csv file")
    parser.add_argument("PricesPath", help="Provide the path for the prices.csv file")
    
    #parser.add_argument("--debug", dest="debug", default=False, action="store_true", help="enable debugging")
    args = parser.parse_args()
    
    app=CodingTest()
    app.args = args
    app.run()
    
if __name__ == '__main__':
	main()