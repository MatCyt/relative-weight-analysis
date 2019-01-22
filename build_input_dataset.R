# libraries
library(yhat)
library(relaimpo)
library(dplyr)
library(readr)
library(data.table)

# load data
df = fread("C:\\Users\\matcyt\\Desktop\\MarketingAttribution_Datasets\\sample_dataset_main.csv")

# select columns, add prices, add sales, delete smallest creative name
prices = c(15, 20, 25)

df2 = df %>%
  select(cookie, event, creative_name, conversion, region_name) %>%
  mutate(creative_name = gsub("WP_sport,turystyka,film_doublebillboard", "WP_other", df$creative_name),
         price = if_else(df$conversion == 1, sample(prices, size = nrow(df), replace = T, prob = c(0.3, 0.4, 0.3)), 0),
         sales = conversion * price) %>%
  filter(creative_name != "Polsat_welcome_screen")

# split amnet in half - it is taking 80% of conversions
amnet = c("Amnet_DTH_all_creatives1", "Amnet_DTH_all_creatives2")
nrow(df2[df2$creative_name == "Amnet_DTH_all_creatives", ])
df2[df2$creative_name == "Amnet_DTH_all_creatives", "creative_name"] = sample(amnet, nrow(df2[df2$creative_name == "Amnet_DTH_all_creatives", ]), replace = TRUE, prob = c(0.6, 0.4))

# replace creative_names with channel names
df2$channel = 0

df_initial = df2 %>%
  mutate(channel = replace(channel, creative_name == "Amnet_DTH_all_creatives1", "Display_2"),
         channel = replace(channel, creative_name == "Amnet_DTH_all_creatives2", "PaidSearch_1"),
         channel = replace(channel, creative_name == "Agora_doublebillboard", "Display_1"),
         channel = replace(channel, creative_name == "Polsat_all_banners_CPC", "PaidSearch_2"),
         channel = replace(channel, creative_name == "WP_SG_doublebillboard", "PaidSearch_2"),
         channel = replace(channel, creative_name == "Interia_doublebillboard", "Display_1"),
         channel = replace(channel, creative_name == "Polsat_Double_overlay", "Display_3"),
         channel = replace(channel, creative_name == "WP_other", "Display_3"),
         channel = replace(channel, creative_name == "Interia_rectangle", "Display_1")) %>%
  select(-creative_name)

# create impression column  and delete event and price
df_initial$impression = ifelse(df_initial$conversion == 1, 0, 1)

df_initial$event = NULL
df_initial$price = NULL

###  input 

# delete not required dimension - because of dcast where I'cant "not include it" - any way around it?
df_input = df_initial %>%
  select(-region_name)

# because of dcast we need to separately group conversions and sales and dcast impressions per dimension (like channel)
# and then join those two together. Dcast fucks up other variables in df like conversion and sales

# 1) group input by cookie - sales sum and conversions sum
df_inputgroup = df_input %>%
  select(cookie, conversion, sales) %>%
  group_by(cookie) %>%
  summarise(conversion = sum(conversion),
            sales = sum(sales))

df_inputgroup = as.data.frame(df_inputgroup)

# 2) dcast dimension and aggregate impressions by sum 
df_inputcast = dcast(df_input, cookie ~ channel, fun.aggregate = sum)

# 3) join those two
df_final = df_inputgroup %>%
  full_join(df_inputcast, by = "cookie")

head(df_final) # final dataset



