# relative weight analysis


# yhat (?)
rwlOut<-rlw(df_final,"sales",c("Display_1","Display_2","Display_3", "PaidSearch_1", "PaidSearch_2"))


# relimp
model = lm(conversion ~ Display_1 + Display_2 + Display_3 + PaidSearch_1 + PaidSearch_2, data = df_final)

relweight_lmg = calc.relimp(model, type = c("lmg"), rela = FALSE)



#  TODO can you compare those results with markov results?
#  TODO understand what relative weight analysis is doing - read the articles
#  TODO understand the package
