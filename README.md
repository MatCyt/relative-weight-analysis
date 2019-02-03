# Marketing-Attribution_Markov-Chain

Applying Relative Weight Analysis to marketing attribution problem in R.

### Marketing Attribution and Regression
Relative Weight Analysis (RWA) is a regression based approach to tackle marketing attribution problem.
A more detailed description of marketing attribution can be found in my other repository about Markov Chain. Regardless of the method used
the challenge in marketing analytics remains the same - undertand and analyze the impact of different variables 
(like spending on different media channels) on desired outcome (like conversions or overall sales).

Regular multiple regression is a method often used to tackle this challenge. It brings information about importance/strength of independent
variables through their significance and coefficients. There is however an important thing to keep in mind while interpreting regression results :
> "every coefficient is the amount of change in the outcome when one variable value is increased by a unit **while all other variables remain constant**"

The last part refers to the fact the coefficients won't be much of a help for us if the independent variables are correlated with each 
other which is often a case in relation between marketing campaigns. 

### Relative Weight Analysis
Relative Weight Analysis is one of the methods (together with Dominance Analysis) that can deal with the multicollinearity
issue. Detailed explanation about the method itself in general and marketing attribution context can be found in the links at the end.
The main goal of RWA (and DA) is to isolate the impact each of the variables have on R2 based on the results of linear model.

For the purpose of this repository I've calculated the model on two datasets with different level of aggregated information. 
Original dataset had a format of cookie level set representing detailed campaign data with structure presented below.
The preprocessing and creating the model input can be found in *data_process_RWA.R*.

<p align="center">
  <img src="https://github.com/MatCyt/relative-weight-analysis/blob/master/img/original_dataset_structure.png"
       width="670" height="120">

First one was a cookie-level dataset representing the overal exposure of each user to different channels and total amount of user conversions. 

<p align="center">
  <img src="https://github.com/MatCyt/relative-weight-analysis/blob/master/img/cookie_input_structure.png"
       width="670" height="120">

Second one on much higher level represented a conversion and impression aggregation on daily level. Both sets represent different information granularity available in everyday marketing analytics work. Their samples can be found in datasets folder.

<p align="center">
  <img src="https://github.com/MatCyt/relative-weight-analysis/blob/master/img/day_input_structure.png"
       width="670" height="120">

RWA can be applied in R easily through a great relaimpo package as you can see in the code below. It takes as input a results of linear model and returns a set of characteristics
including the breakdown of R2 by each of variables. The RWA function can take several different types based on the theoretical background
behind it. They are all presented in package documentation linked at the end. For simplicity the "lmg" type used in this example is the
one recommended by the package authors.

``` R
## run Relative Weight Analysis (RWA) with realaimpo

# Linear Model and RWA on cookie level data
df_cookie_input = df_cookie[, -1]

model_cookie = lm(conversion ~ ., data = df_cookie_input)
summary(model_cookie)

rwa_cookie = calc.relimp(model_cookie, type = c("lmg"), rela = T)


# Linear Model and RWA on day level data
df_day_input = df_day[, -1]

model_day = lm(conversion ~ ., data = df_day_input)
summary(model_day)

rwa_day = calc.relimp(model_day, type = c("lmg"), rela = T)
 ```

As you can see the difference in data aggregation influence the results of linear model (12% of variance explained for cookie level set compared
to over 60% in day level aggregation) and final results of performance attributed to each channel:

<p align="center">
  <img src="https://github.com/MatCyt/relative-weight-analysis/blob/master/img/compare_aggregation_RWA.png" alt="Aggregation Level"
       width="480" height="370">

Finally the graph below compares results of actuall attribution on real data (channel weights applied to conversion numbers) between 
different methods: RWA on daily level, RWA on cookie level, Markov Chain and classic heuristics models (calculated in *markov_chain_comparison.R*).
Looking at it I am more and more convinced with the final solution ensembling different approaches since contrary to 
classic ML classification problem there is no easy metric-driven way to answer the question which ones of those is closes to "truth".

<p align="center">
  <img src="https://github.com/MatCyt/relative-weight-analysis/blob/master/img/attribution_methods_comparison.png" alt="Attribution Comparison">









