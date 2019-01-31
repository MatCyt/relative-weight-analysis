# libraries
library(relaimpo)
library(yhat)
library(dplyr)

## load data ----




## run Relative Weight Analysis (RWA) with realaimpo

# cookie aggregation
df_cookie_input = df_cookie[, -1]

model_cookie = lm(conversion ~ ., data = df_cookie_input)

rel_cookie_lmg = calc.relimp(model_cookie, type = c("lmg"), rela = T)


# day aggregation
df_day_input = df_day[, -1]

model_day = lm(conversion ~ ., data = df_day_input)

rel_day_lmg = calc.relimp(model_day, type = c("lmg"), rela = T)

## compare different RWA relaimpo versions


## RWA-based attribution


## Compare RWA attribution to markov




