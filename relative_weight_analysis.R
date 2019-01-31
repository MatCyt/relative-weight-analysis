# libraries
library(relaimpo)
library(yhat)
library(dplyr)
library(data.table)

## load data ----


# home - cookie
df_cookie = fread("C:\\Users\\matcyt\\Desktop\\MarketingAttribution_Datasets\\df_cookie.csv")
# work - cookie
df_cookie = fread("C:\\Users\\mateusz.cytrowski\\Desktop\\MediaProject\\df_cookie.csv")

# home - day
df_day = fread("C:\\Users\\matcyt\\Desktop\\MarketingAttribution_Datasets\\df_day.csv")
# work - day
df_day = fread("C:\\Users\\mateusz.cytrowski\\Desktop\\MediaProject\\df_day.csv")


## run Relative Weight Analysis (RWA) with realaimpo

# RWA on cookie level
df_cookie_input = df_cookie[, -1]

model_cookie = lm(conversion ~ ., data = df_cookie_input)

rel_cookie_lmg = calc.relimp(model_cookie, type = c("lmg"), rela = T)


# RWA on day level
df_day_input = df_day[, -1]

model_day = lm(conversion ~ ., data = df_day_input)

rel_day_lmg = calc.relimp(model_day, type = c("lmg"), rela = T)

## compare different RWA relaimpo versions


## RWA-based attribution


## Compare RWA attribution to markov




