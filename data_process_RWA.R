# libraries
library(readr)
library(data.table)
library(kableExtra)
library(readr)

## load datasets ----

# home
df_processed = fread("C:\\Users\\matcyt\\Desktop\\MarketingAttribution_Datasets\\processed_dataset.csv")

# work
df_processed = fread("C:\\Users\\matcyt\\Desktop\\MarketingAttribution_Datasets\\processed_dataset.csv")



## Preprocess dataset for RWA format ----

# delete not required dimension - because of dcast where I'cant "not include it" - any way around it?
df_input = df_initial 


# because of dcast we need to separately group conversions and sales and dcast impressions per dimension (like channel)
# and then join those two together. Dcast fucks up other variables in df like conversion and sales

# 1) group input by cookie - sales sum and conversions sum
df_inputgroup = df_input %>%
  select(cookie, conversion, sales) %>%
  group_by(cookie) %>%
  summarise(conversion = sum(conversion),
            sales = sum(sales))

df_inputgroup = as.data.frame(df_inputgroup)

selected_dimension = "channel"

# 2) dcast dimension and aggregate impressions by sum 
df_inputcast = df_input %>%
  select(cookie, selected_dimension, impression)
df_inputcast = dcast(df_inputcast, cookie ~ df_inputcast[,selected_dimension] ,fun.aggregate = sum)

# 3) join those two
df_final = df_inputgroup %>%
  full_join(df_inputcast, by = "cookie")

head(df_final) # final dataset

test = head(df_final)

## Create the table to visualize the data format ----

## Save the sample ----

## Save the files ----

