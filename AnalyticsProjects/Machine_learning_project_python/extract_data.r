data<-read.csv("crimedata.csv")
View(data)

data2<-data[, c("communityName","state","PctPopUnderPov","PctUnemployed", "MedNumBR","racepctblack", "TotalPctDiv","racePctWhite", "racePctHisp", "PctNotHSGrad","ViolentCrimesPerPop")] 
write.csv(data2,"crimedata2.csv", row.names = FALSE)
