library(yhat)
library(dplyr)
library(relaimpo)
library(readr)

# Relative Weight Analysis - LMG

model_lm = lm(conversion ~ ., data = model_input) # linear model

rwa_output = calc.relimp(model_lm, type = c("lmg"), rela = F) # calculating RWA based on relaimpo package

rwa_attribution_lmg = as.data.frame(rwa_output@lmg) %>% # processing the output to right format
  rename(relative_weights = 1) %>%
  mutate(channel = gsub("^.*?_", "",row.names(as.data.frame(rwa_output@lmg)))) %>%
  group_by(channel) %>%
  summarise(relative_weights = sum(relative_weights)) %>%
  mutate(relative_conversions = round(relative_weights * (sum(model_input$conversion)),2))

# Dominance Analysis - Shapley regression

ivs_variables = names(model_input[,-1])

dominance_input = aps(model_input, "conversion", ivs_variables)

dominance_output = dominance(dominance_input)

dominance_attribution = as.data.frame(dominance_output$GD) %>% # processing the output to right format
  rename(dominance_weights = 1) %>%
  mutate(channel = gsub("^.*?_", "",row.names(as.data.frame(dominance_output$GD)))) %>%
  group_by(channel) %>%
  summarise(dominance_weights = sum(dominance_weights)) %>%
  mutate(dominance_conversions = round(dominance_weights * (sum(model_input$conversion)),2))

# Merge and compare results

regression_attribution = rwa_attribution %>%
  full_join(dominance_attribution, by = "channel")


rtest = as.data.frame(rwa_output@lmg)
dtest = as.data.frame(dominance_output$GD)

test = cbind(rtest, dtest)
