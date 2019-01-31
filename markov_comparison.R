# libraries
library(dplyr)
library(ChannelAttribution)

# load dataset

# home
df_processed = fread("C:\\Users\\matcyt\\Desktop\\MarketingAttribution_Datasets\\processed_dataset.csv")

# work
df_processed = fread("C:\\Users\\mateusz.cytrowski\\Desktop\\MediaProject\\processed_dataset.csv")

## Prepare the files - Split Paths ----
df_split = df_processed %>%
  group_by(cookie) %>%
  arrange(time) %>%
  mutate(path_no = ifelse(is.na(lag(cumsum(conversion))), 0, lag(cumsum(conversion))) + 1) %>%
  ungroup() %>%
  mutate(path_id = paste0(cookie, path_no))


### Prepare the file - Create the paths ----
df_paths = df_split %>%
  group_by(path_id) %>%
  arrange(time) %>%
  summarise(path = paste(channel, collapse = ">"),
            total_conversions = sum(conversion)) %>%
  ungroup() %>% 
  mutate(null_conversion = ifelse(total_conversions == 1, 0, 1)) # adding information about path that have not led to conversion

### Markov Chain and Heuristic Models ----
markov_attribution <- markov_model(df_paths,
                                   var_path = "path",
                                   var_conv = "total_conversions",
                                   var_value = NULL,
                                   order = 2, # higher order markov chain
                                   var_null = "null_conversion",
                                   out_more = TRUE)


heuristic_attribution <- heuristic_models(df_paths,
                                          var_path = "path",
                                          var_conv = "total_conversions")



### Prepare final joint dataset ----

# Join attribution results
campaign_attribution = merge(markov_attribution$result, heuristic_attribution)

# Change the name of markov results column
names(campaign_attribution)[names(campaign_attribution) == "total_conversions"] = "markov_result"

#### Calculate ROAS and CPA
campaign_attribution = 
  campaign_attribution %>%
  mutate(chanel_weight = (markov_result / sum(markov_result)),
         cost_weight = (total_cost / sum(total_cost)),
         roas = chanel_weight / cost_weight,
         optimal_budget = total_cost * roas,
         CPA = total_cost / markov_result)


