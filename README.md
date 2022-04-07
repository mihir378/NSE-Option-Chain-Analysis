# NSE Options Chain Data Analysis (Single Day)
The National Stock Exchnage of India publishes Options and Futures data for a range of securities and the NIFTY index across different expiry dates. 
The aim of this analysis document is to make use of R-Studio to study the movement of different variables published as part of the dataset for a given expiry date
and deduce potential relationships between those variables. 

Additionally, results from the code provided can also be utilised to practically observe some of the core theoretical results that emerge from the study of derivative 
securites in the field of Financial Mathematics. Some of the major results include showing the convexity of Put and Option prices as a function of the Strike Price, 
the hyperbolic relationship between Put and Call Prices, higher relative bid-ask spreads for in-the-money call and put options, a smile-like trajectory of 
implied volatility, etc. 

Following are the 10 points of analysis that have been conducted:

  1. Analyzing the Price Trajectory of Call and Put Options
  2. Plotting Call vs Put Price and Tangent
  3. Analyzing Returns 
  4. Plotting trajectory of Change in Price
  5. Showing that higher change in price does not imply higher returns
  6. Relative Bid-Ask Spread (Liquidity Measure)
  7. Combined graph for Volume, Open Interest and Change in Open Interest
  8. Relationship between OI and Volume
  9. Relationship between OI, VOLUME and CHNG.IN.OI and RBAS (Price)
  10. Non-Constant (Smile Like) Trajectory of Implied Volatility IV


**Note (1):** The codes have been creating in mind, keeping in mind that the data has been collected for a single-day as part of the wider time series and thus fits 
the scope of being deemed as a cross-sectional analysis across different stirke prices.

**Note (2):** A list of all variables is provided as part of the code. Additionally, I have also attached an example of a clean dataset that is analysed in .csv format.  
