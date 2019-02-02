# libraries
library(relaimpo)
library(yhat)
library(dplyr)
library(data.table)
library(ggplot2)

## load data ----

# home - cookie
df_cookie = fread("C:\\Users\\matcyt\\Desktop\\MarketingAttribution_Datasets\\df_cookie.csv")
# work - cookie
df_cookie = fread("C:\\Users\\mateusz.cytrowski\\Desktop\\MediaProject\\df_cookie.csv")

# home - day
df_day = fread("C:\\Users\\matcyt\\Desktop\\MarketingAttribution_Datasets\\df_day.csv")
# work - day
df_day = fread("C:\\Users\\mateusz.cytrowski\\Desktop\\MediaProject\\df_day.csv")

# Markov - Home
markov_heuristics_attribution = fread("C:\\Users\\matcyt\\Desktop\\MarketingAttribution_Datasets\\markov_heuristics_attribution.csv")

markov_removal_effect = fread("C:\\Users\\matcyt\\Desktop\\MarketingAttribution_Datasets\\markov_removal_effect.csv")


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

## compare different RWA relaimpo versions
cookie_lmg = as.data.frame(rwa_cookie@lmg) %>%
  mutate(channel = row.names(as.data.frame(rwa_cookie@lmg)))
day_lmg = as.data.frame(rwa_day@lmg) %>%
  mutate(channel = row.names(as.data.frame(rwa_day@lmg)))

rwa_coefficients = cookie_lmg %>%
  full_join(day_lmg)
  
rwa_coef_melted = melt(rwa_coefficients, id.vars = ("channel"))

g_compared_aggregation = ggplot(rwa_coef_melted, aes(x = channel, y = value, fill = variable)) + 
  geom_bar(stat = "identity", width = 0.5, position = position_dodge(width = 0.7))  +
  scale_fill_manual(labels = c("RWA Cookie", "RWA Day"), values = c("#48ACF0", "#0CA4A5")) +
  theme_minimal() +
  theme(axis.text.x = element_text(size = 10, angle = 30, hjust = 0.6, face = "bold")) +
  theme(panel.grid.major.x = element_blank()) +
  geom_text(aes(label = round(value, 2)), 
            fontface = "bold", size = 3.5, 
            vjust = -0.5, position = position_dodge(width = 0.75)) +
  labs(x = "channel", y = "R2 explained") +
  theme(plot.title = element_text(hjust = 0.5))

g_compared_aggregation

## RWA-based attribution
conversions_sum = sum(df_processed$conversion)

rwa_attribution = rwa_coefficients %>%
  mutate(rwa_day_result = rwa_day@lmg * conversions_sum,
         rwa_cookie_result = rwa_cookie@lmg * conversions_sum) %>%
  select(channel, rwa_cookie_result, rwa_day_result)

## Compare RWA with Markov Chain
weight_comparison = rwa_coefficients %>%
  full_join(markov_removal_effect, by = c("channel" = "channel_name"))

conversion_comparison = rwa_attribution %>%
  full_join(markov_heuristics_attribution, by = c("channel" = "channel_name"))

# compare full attribution results (conversions)
conversion_melted = melt(conversion_comparison, id.vars = ("channel"))

g_conversion_melted = ggplot(conversion_melted, aes(x = channel, y = value, fill = variable)) + 
  geom_bar(stat = "identity", width = 0.5, position = position_dodge(width = 0.7)) +
  scale_fill_manual(values = c("#F29C2E", "#EFCA08", "#3590F3", "#15B097", "#5FDD9D", "#8AE6B7")) +
  theme_minimal() +
  theme(axis.text.x = element_text(size = 10, angle = 30, hjust = 0.6, face = "bold")) +
  theme(panel.grid.major.x = element_blank()) +
  labs(x = "channel", y = "conversions") +
  theme(plot.title = element_text(hjust = 0.5))

g_conversion_melted

