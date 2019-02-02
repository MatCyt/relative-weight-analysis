# libraries
library(dplyr)
library(ChannelAttribution)
library(readr)

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

# Join attribution results and markov removal effect 
markov_heuristics_attribution = merge(markov_attribution$result, heuristic_attribution)

markov_removal_effect = markov_attribution$removal_effects

# Change the name of markov results column
names(markov_heuristics_attribution)[names(markov_heuristics_attribution) == "total_conversions"] = "markov_result"

# Save the results for comparison with RWA
write_csv(markov_heuristics_attribution, "C:\\Users\\matcyt\\Desktop\\MarketingAttribution_Datasets\\markov_heuristics_attribution.csv") #home
write_csv(markov_removal_effect, "C:\\Users\\matcyt\\Desktop\\MarketingAttribution_Datasets\\markov_removal_effect.csv") #home



