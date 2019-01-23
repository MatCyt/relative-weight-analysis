# relative weight analysis


# yhat (?)
rwlOut<-rlw(df_final,"sales",c("Display_1","Display_2","Display_3", "PaidSearch_1", "PaidSearch_2"))


# relimp
df_final = df_final %>%
  select(-conversion, -cookie)

df_final$cookie = NULL

model = lm(sales ~ ., data = df_final)

relweight_lmg = calc.relimp(model, type = c("lmg"), rela = T)



#  TODO can you compare those results with markov results?
#  TODO understand what relative weight analysis is doing - read the articles
#  TODO understand the package


str(relweight_lmg)

sum(relweight_lmg@lmg)

relweight_lmg@lmg[1] / sum(relweight_lmg@lmg)
