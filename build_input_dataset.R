## libraries ----
library(dplyr)
library(readr)
library(data.table)
library(kableExtra)

## load data ----

# home
df = fread("C:\\Users\\matcyt\\Desktop\\MarketingAttribution_Datasets\\sample_dataset_main.csv")

# work
df = fread("C:\\Users\\mateusz.cytrowski\\Desktop\\MediaProject\\sample_dataset_main.csv")



## Create baseline dataset - input for both RWA and Markov ----
# add relative columns, add variables, change names to hash original dataset

prices = c(15, 20, 25)

# select columns of interest, create sales variable, filter smallest creative name
df_processed = df %>% 
  select(cookie, event, creative_name, conversion, time) %>%
  mutate(creative_name = gsub("WP_sport,turystyka,film_doublebillboard", "WP_other", df$creative_name),
         price = if_else(df$conversion == 1, sample(prices, size = nrow(df), replace = T, prob = c(0.3, 0.4, 0.3)), 0),
         sales = conversion * price,
         impression = ifelse(conversion == 1, 0, 1)) %>%
  filter(creative_name != "Polsat_welcome_screen") %>%
  select(-event, -price)

# split amnet in half - it is taking 80% of conversions, I want more variance in output
amnet = c("Amnet_DTH_all_creatives1", "Amnet_DTH_all_creatives2")
nrow(df_processed[df_processed$creative_name == "Amnet_DTH_all_creatives", ])
df_processed[df_processed$creative_name == "Amnet_DTH_all_creatives", "creative_name"] = sample(amnet, 
                                                                                                nrow(df_processed[df_processed$creative_name == "Amnet_DTH_all_creatives", ]), 
                                                                                                replace = TRUE, 
                                                                                                prob = c(0.6, 0.4))

# replace creative_names with channel names
df_processed$channel = 0

df_processed = df_processed %>%
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

# Create new dimension - creative
df_processed = df_processed %>%
  mutate(creative = sample(c("Creative1", "Creative2" , "Creative3"), size = nrow(df_processed), replace = T, prob = c(0.3, 0.4, 0.3)))

# Hash the cookie values
df_processed$cookie = substr(df_processed$cookie, 4, stop = 10000000)

df_processed$cookie = gsub("0", "l", df_processed$cookie)
df_processed$cookie = gsub("9", "i", df_processed$cookie)

head(df_processed)

## Save the preprocessed file ----

# home
write_csv(df_processed, "C:\\Users\\matcyt\\Desktop\\MarketingAttribution_Datasets\\processed_dataset.csv")

# work
write_csv(df_processed, "C:\\Users\\mateusz.cytrowski\\Desktop\\MediaProject\\processed_dataset.csv")


# Print output structure
df_processed_structure = head(df_processed)

kable(df_processed_structure) %>%
  kable_styling(bootstrap_options = c("striped"), full_width = F) %>%
  row_spec(0, align = "center")


# save sample
df_processed_sample = head(df_processed, 50000)

  # home
  write_csv(df_processed_sample, "C:\\Users\\matcyt\\Desktop\\MarketingAttribution_Datasets\\processed_dataset_sample.csv")

  # work
  write_csv(df_processed_sample, "C:\\Users\\mateusz.cytrowski\\Desktop\\MediaProject\\processed_dataset_sample.csv")
