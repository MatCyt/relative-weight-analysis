# libraries
if (!require("pacman")) install.packages("pacman")
pacman::p_load(data.table, dplyr, readr, kableExtra)

## load datasets ----
df_processed = fread("../processed_dataset.csv")


### Preprocess dataset for RWA format ----

dependent_variable = "conversion"
impact_variable = "impression"
selected_dimension = "channel"

## Approach 1 - Full Data Grouped by Cookie ----
# because of (current) dcast limitations I need to split datasets, process separately and join them

# dependent variable sum by cookie
df_input1_cookie = as.data.frame(df_processed %>%
                            select(cookie, dependent_variable) %>%
                            group_by(cookie) %>%
                            summarise_all(sum))

# dcast independent variable
df_input2_cookie = df_processed %>%
  select(cookie, selected_dimension, impact_variable)

df_input2_cookie = dcast(df_input2_cookie, paste("cookie ~", selected_dimension), value.var = impact_variable, fun.aggregate = sum)

# join both input sources
df_cookie = df_input1_cookie %>%
  full_join(df_input2_cookie, by = "cookie")



## Approach 2 - Aggregated data - grouped by day ----

# dependent variable sum by day
df_input1_day = as.data.frame(df_processed %>%
                            select(time, dependent_variable) %>%
                            mutate(day = as.Date(time)) %>%
                            group_by(day) %>%
                            select(-time) %>%
                            summarise_all(sum))

# dcast independent variable
df_input2_day = df_processed %>%
  select(time, selected_dimension, impact_variable) %>%
  mutate(day = as.Date(time)) %>%
  select(-time)

df_input2_day = dcast(df_input2_day, paste("day ~", selected_dimension), value.var = impact_variable, fun.aggregate = sum)

# join both input sources
df_day = df_input1_day %>%
  full_join(df_input2_day, by = "day")


## Print output structure ----
df_cookie_structure = head(df_cookie, 3)
df_day_structure = head(df_day, 3)

kable(df_cookie_structure) %>%
  kable_styling(bootstrap_options = c("striped"), full_width = F) %>%
  row_spec(0, align = "center")

kable(df_day_structure) %>%
  kable_styling(bootstrap_options = c("striped"), full_width = F) %>%
  row_spec(0, align = "center")


## Save the sample (cookie only due to size) ----
df_cookie_sample = head(df_processed, 50000)

write_csv(df_cookie_sample, "../df_cookie_sample.csv")

## Save the files ----

# cookie level aggregation
write_csv(df_cookie, "../df_cookie.csv")
# day level aggregation
write_csv(df_day, "../df_day.csv")
