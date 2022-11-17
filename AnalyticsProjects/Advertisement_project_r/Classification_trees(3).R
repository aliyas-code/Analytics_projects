library(rpart)
library(rpart.plot)
library(rattle)
library(RColorBrewer)
library(caTools)
library(partykit)
library(caret)
library(e1071)

#read
#Data_for_tree
df <- read.csv("/Data_for_tree.csv")
df$gr_Ward_4<-as.factor(df$gr_Ward_4)

df$startURL<-as.factor(df$startURL)
df$lastPlatform<-as.factor(df$lastPlatform)
#df$BanerId<-as.factor(df$BanerId)

df$startURL <- unclass(df$startURL)
df$lastPlatform <- unclass(df$lastPlatform)
View(df)

#split test and train
split <- sample.split(df$gr_Ward_4, SplitRatio = 0.8)

train<- subset(df, split == TRUE)
test<- subset(df, split == FALSE)

#CART tree
df_tree <- rpart(gr_Ward_4~BanerId + pageViews, data = train)

fancyRpartPlot(df_tree, palettes=c("Blues", "Reds"))
unique(df$BannerName)

#predict train
PredictCART1 = predict(df_tree, newdata = train, type = 'class')
PredictCART1
table(train$gr_Ward_4, PredictCART1)

#predict test
PredictCART1 = predict(df_tree, newdata = test, type = 'class')
PredictCART1
table(test$gr_Ward_4, PredictCART1)

#Graph of the change in the relative accuracy of the tree depending on cp
plotcp(df_tree)

#CV
number=30
fitControl <- trainControl(method="cv", number=30)
#cp = [0.001;0.2], find optimal cp
cartGrid <- expand.grid(.cp=(1:200)*0.001)
train(gr_Ward_4~BanerId + pageViews, data=df, method="rpart", trControl=fitControl, tuneGrid=cartGrid)

df_tree_cv <- rpart(gr_Ward_4~BanerId + pageViews,
                    data = df, method = "class",
                    control=rpart.control(cp = 0.009))

fancyRpartPlot(df_tree_cv, palettes=c("Greys", "Oranges","Blues", "Reds"))

PredictCART3 <- predict(df_tree_cv, newdata = df, type="class")
table(df$gr_Ward_4, PredictCART3)
plotcp(df_tree_cv)

nrow(df)