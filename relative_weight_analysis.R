# libraries
library(relaimpo)
library(yhat)
library(dplyr)

## load data ----




## run Relative Weight Analysis (RWA) with realaimpo
df_final = df_final %>%
  select(-conversion, -cookie)

df_final$cookie = NULL

model = lm(sales ~ ., data = df_final)

relweight_lmg = calc.relimp(model, type = c("lmg"), rela = T)

## compare different RWA relaimpo versions


## RWA-based attribution


## Compare RWA attribution to markov




