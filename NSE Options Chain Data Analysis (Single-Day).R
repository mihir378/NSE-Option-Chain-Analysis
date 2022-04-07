##### NSE Options Chain Data Analysis - Single Day Cross-Sectional #####
library(ggplot2)
library(gridExtra)
library(PerformanceAnalytics)

# Load Data and check Structure
options <- read.csv("XXXXX", header = TRUE)   
str(options)

# Add additional an additional column for ease of use 
x<- 1:length(options$STRIKE.PRICE)
options_new <- cbind.data.frame(options,x)

# In case needed, changed character variables to numeric variables
options_new <- transform(options_new, VOLUME_C = as.numeric(VOLUME_C), 
                         VOLUME_P = as.numeric(VOLUME_P),
                         CHNG.IN.OI_C = as.numeric(CHNG.IN.OI_C),
                         OI_P = as.numeric(OI_P),
                         IV_C = as.numeric(IV_C))
str(options_new)
options_new <- na.fill(options_new,0)

# Change existing dataset to a data frame
options_new <- as.data.frame(options_new)

############## 1. Analyzing the Price Trajectory ####################

# Note: Vertical Line for these graphs has been chosen to be the strike price which 
# acts as the differentiator between in-the-money and out-the-money. 

df_options = subset(options_new,options_new$LTP_C>0 & options_new$LTP_P>0)

ggplot(data = df_options, aes(x, LTP_C)) + 
  geom_line()+  
  geom_smooth(se = F)+
  geom_smooth(method = "lm", col = "red",se = F)+
  geom_vline(xintercept = 68)

ggplot(data = df_options, aes(x, LTP_P)) + 
  geom_line()+  
  geom_smooth()+
  geom_smooth(method = "lm", col = "red")+
  geom_vline(xintercept = 68)


############## 2. Plotting Call vs Put Price and Tangent ####################

#Note: This graphs shows the hyperbolic relationship between the two prices

df_options = subset(options_new,options_new$LTP_C>0 & options_new$LTP_P>0)

ggplot(data = df_options, aes(x=LTP_C, y =LTP_P)) + 
  geom_point()

## Plotting the Tangent Line ###
#Note: Here we take some inspiration from the formula of the tangent line of the function f(x) = 1/x
xincrement <- 60       #LTP of the last in-the-money call option
yincrement <- 63       #LTP of the last out-the-money put option (Same strike as above)
slope <- -(63/60)                                                                

intercept <- 126 
yvalues <- slope*df_options$LTP_C + (2*63)

df_options.1 <- as.data.frame(cbind(df_options,yvalues))

ggplot(df_options.1, aes(x=LTP_C, y =LTP_P))+
  geom_point(size = 1) + 
  labs(title ="Call vs Put Option",x="Call Option Price", y= "Put Option Price") + 
  geom_abline(slope = slope, intercept = intercept, color = "blue", size = 1)


############# 3. Analyzing Returns ######################

#Note (1): Returns can be calculated using the formula CHNG_C/(LTP_C-CHNG_C)
#Note (2): Vertical Lines can be added arbitariy depending on Strike Price of Interest 

mean(options_new$RETURN_C, na.rm = TRUE)
mean(options_new$RETURN_P, na.rm = TRUE)

sd(options_new$RETURN_C, na.rm = TRUE)
sd(options_new$RETURN_P, na.rm = TRUE)

chart.Histogram(options_new$RETURN_C,
                colorset = c('blue'))

chart.Histogram(options_new$RETURN_P,
                colorset = c('blue'))

boxplot(options_new$RETURN_C,options_new$RETURN_P, 
        col = c("yellow","steelblue"))

table.Stats(options_new$RETURN_C, ci=0.95)
table.Stats(options_new$RETURN_P, ci=0.95)

ggplot(data = options_new, aes(x, RETURN_C)) + 
  geom_line() + 
  geom_smooth()+
  geom_vline(xintercept = 59)+
  geom_vline(xintercept = 68, col = "red")+
  geom_vline(xintercept = 70, col = "darkgreen")


ggplot(data = options_new, aes(x, RETURN_P)) + 
  geom_line() + 
  geom_smooth()+
  geom_vline(xintercept = 59)+
  geom_vline(xintercept = 68, col = "red")


########### 4. Plotting trajectory of Change in Price ############

ggplot(data = options_new, aes(x, CHNG_P)) + 
  geom_line()+  
  geom_smooth(se = F)+
  geom_smooth(method = "lm", col = "red", se = F)+
  geom_vline(xintercept = 64)

ggplot(data = options_new, aes(x, CHNG_C)) + 
  geom_line()+  
  geom_smooth(se = F)+
  geom_smooth(method = "lm", col = "red", se = F)+
  geom_vline(xintercept = 64)

########## 5. Showing that higher change in price does not imply higher returns ######

qplot(CHNG_C,RETURN_C,
      data=options_new,
      xlab="Change for Call Options",
      ylab="Return",
      col=TYPE_C)

qplot(CHNG_P,RETURN_P,
      data=options_new,
      xlab="Change for Put Options",
      ylab="Return",
      col=TYPE_C)

######### 6. Relative Bid-Ask Spread (Liquidity Measure) #######
# Note: RBAS_C / RBAS_P = (A-B)/0.5*(A+B) where A and B are the respectice Ask and Bid Prices provided in the data

ggplot(data = options_new, aes(x, RBAS_c)) + 
  geom_line()+
  geom_hline(yintercept=mean(options_new$RBAS_P), col = "steelblue")+
  geom_hline(yintercept=0)+
  geom_vline(xintercept = 64, col = "red")

ggplot(data = options_new, aes(x, RBAS_P)) + 
  geom_line()+
  geom_hline(yintercept=mean(options_new$BASQ_P), col = "steelblue")+
  geom_hline(yintercept=0)+
  geom_vline(xintercept = 60, col = "red")+
  geom_vline(xintercept = 64, col = "green")

## Excercise: Try similar calculaton using Bid and Ask Quantity? ##

######### 7. Combined graph for Volume, Open Interest and Change in Open Interest #######

#Note: This graph is extremely pivotal in understanding the sentiment of the market.
#How?: (a) High OI + Volume show strike prices of interest.
#      (b) +Ve Change in OI for Call Options -> More writing (selling of Call Options) -> Bearish sentiment
#      (c) -ve Chnage in OI for Call Options -> More buying by writers -> Bullish Sentiment 
# Similar to (b) and (c), the inverse arguments hold for put options

###### CALL ######

p1 <- ggplot(data=options_new, aes(x,VOLUME_C)) +
  geom_bar(stat="identity", fill = "steelblue")+
  geom_hline(yintercept = mean(options_new$VOLUME_C), col = "red")+
  geom_vline(xintercept = 64)+
  geom_vline(xintercept = 68, col="red")

p2 <- ggplot(data=options_new, aes(x,OI_C)) +
  geom_bar(stat="identity", fill = "steelblue")+
  geom_hline(yintercept = mean(options_new$VOLUME_C), col = "red")+
  geom_vline(xintercept = 64)+
  geom_vline(xintercept = 68, col="red")

p3 <- ggplot(data = options_new, aes(x, CHNG.IN.OI_C)) + 
  geom_line() + 
  geom_smooth(se = F)+
  geom_vline(xintercept = 64, col = "red")+
  geom_vline(xintercept = 68, col = "green")+
  geom_vline(xintercept = 70, col="red")

plot <- grid.arrange(p1,p2,p3,
                     ncol = 1, nrow = 3)

###### PUT ######

p4 <- ggplot(data=options_new, aes(x,VOLUME_P)) +
  geom_bar(stat="identity", fill = "steelblue")+
  geom_hline(yintercept = mean(options_new$VOLUME_P), col = "red")+
  geom_vline(xintercept = 64, col = "red")+
  geom_vline(xintercept = 68, col = "green")

p5 <- ggplot(data=options_new, aes(x,OI_P)) +
  geom_bar(stat="identity", fill = "steelblue")+
  geom_hline(yintercept = mean(options_new$VOLUME_P), col = "red")+
  geom_vline(xintercept = 64, col = "red")+
  geom_vline(xintercept = 68, col = "green")

p6 <- ggplot(data = options_new, aes(x, CHNG.IN.OI_P)) + 
  geom_line() + 
  geom_smooth(se = F)+
  geom_vline(xintercept = 64, col = "red")+
  geom_vline(xintercept = 68, col = "green")+
  geom_vline(xintercept = 59, col = "red")

plot <- grid.arrange(p4,p5,p6,
                     ncol = 1, nrow = 3)


######### 8. Relationship between OI and Volume ##########

ggplot(data = options_new, aes(x=OI_P, y =VOLUME_P)) + 
  geom_point()+
  geom_smooth(method="lm")

ggplot(data = options_new, aes(x=OI_C, y =VOLUME_C)) + 
  geom_point()+
  geom_smooth(method="lm")

fit1 <- lm(VOLUME_C~OI_C, data=options_new)
summary(fit1)
plot(fit1)


######### 9. Relationship between OI, VOLUME and CHNG.IN.OI and RBAS   ##########
#Note: Studying this relatioship helps us understand whether or not there is higher liquidity 
#for options which have higher open interest/volume (proxy for demand/supply)

ggplot(data = options_new, aes(x=VOLUME_C, y =RBAS_C)) +    #Similar result using OI_C/CHNG.IN.OI_C
  geom_point()+
  geom_smooth(method="lm", se=F)+
  geom_smooth(col = "red", se=F)
cor.test(options_new$VOLUME_C,options_new$RBAS_C)

ggplot(data = options_new, aes(x=vOLUME_P, y =RBAS_P)) +    #Similar result using OI_P/CHNG.IN.OI_P
  geom_point()+
  geom_smooth(method="lm", se=F)+
  geom_smooth(col = "red", se=F)
cor.test(options_new$VOLUME_C,options_new$RBAS_C)


########### 10. Non-Constant (Smile Like) Trajectory of Implied Volatility IV #############
df_options = subset(options_new,options_new$IV_C>0)

ggplot(data = df_options, aes(x, IV_C)) + 
  geom_line()+
  geom_smooth()

# Make sure to change the subset formula above to incorporate "IV_P>0"
ggplot(data = df_options, aes(x, IV_P)) + 
  geom_line()+
  geom_smooth()

