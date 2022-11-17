library(psych)
library(ggm)
library(corrplot)

data <- read.table("Data_traffc.csv", header = TRUE, sep = ",", fill = TRUE)

View(data)
str(data)

data$visitID <- as.factor(data$visitID)
data$clientID <- as.factor(data$clientID)
data$date <- as.Date(data$date, format = "%Y-%m-%d")
data$isNewUser <- as.logical(data$isNewUser)
data$bounce <- as.factor(data$bounce)
data$AdType <- as.factor(data$AdType)
data$BannerGroupId <- as.factor(data$BannerGroupId)
data$BanerId <- as.factor(data$BanerId)
data$deviceCategory <- as.factor(data$deviceCategory)
data$operatingSystem <- as.factor(data$operatingSystem)

summary(subset(data, AdType == 'Search'))
summary(subset(data, AdType == 'Context'))
summary(data)

describe(subset(data, AdType == 'Search'))
describe(subset(data, AdType == 'Context'))
describe(data)

#===============scatter plots
par(mfrow = c(1, 1)) 
plot(data.frame(data$price, data$visitDuration))
plot(data.frame(data$pageViews,data$visitDuration))
plot(data.frame(data$pageViews,data$price))

plot(data.frame(data$visitDuration,data$WatchCount))
plot(data.frame(data$pageViews,data$WatchCount))
plot(data.frame(data$price,data$WatchCount))

# scatter plot matrix for each quantitative columns
par(mfrow = c(1, 1)) 
pairs(~data$price+data$visitDuration+data$WatchCount+data$pageViews)

#===============pies
x<-summary(data$operatingSystem)
labels<-names(x) 
piepercent<- round(100*x/sum(x), 1)
pie(x, piepercent, radius=1, main="Distribution of operating systems", col=rainbow(length(x)), clockwise=TRUE)
legend("topright", labels, cex = 0.8, fill=rainbow(length(x)))

x<-summary(data$deviceCategory)
labels<-names(x) 
piepercent<- round(100*x/sum(x), 1)
pie(x, piepercent, radius=1, main="Distribution of device's category", col=rainbow(length(x)), clockwise=TRUE)
legend("topright", labels, cex = 0.8, fill=rainbow(length(x)))

x<-summary(data$BannerGroupId)
labels<-names(x) 
piepercent<- round(100*x/sum(x), 1)
pie(x, piepercent, radius=1, main="Distribution of BannerGroupId", col=rainbow(length(x)), clockwise=TRUE)
legend("topright", labels, cex = 0.8, fill=rainbow(length(x)))

x<-summary(data$AdType)
labels<-names(x) 
piepercent<- round(100*x/sum(x), 1)
pie(x, piepercent, radius=1, main="Distribution of advertisement's types", col=rainbow(length(x)), clockwise=TRUE)
legend("topright", labels, cex = 0.8, fill=rainbow(length(x)))

#checking percentage of operating System for each advertisement's type
par(mfrow = c(1, 2)) 
y<-subset(data, AdType == "Search") 
x<-table(y$operatingSystem)
labels<-names(x)
piepercent<- round(100*x/sum(x), 1)
pie(x, piepercent, radius=1, main="Search", col=rainbow(length(x)), clockwise=TRUE)
legend("topright", labels, cex = 0.8, fill=rainbow(length(x)))

y<-subset(data, AdType == "Context") 
x<-table(y$operatingSystem)
labels<-names(x)
piepercent<- round(100*x/sum(x), 1)
pie(x, piepercent, radius=1, main="Context", col=rainbow(length(x)), clockwise=TRUE)
legend("topright", labels, cex = 0.8, fill=rainbow(length(x)))

#checking percentage of the bounce for each advertisement type
par(mfrow = c(1, 2))
y<-subset(data, AdType == "Search") 
x<-summary(y$bounce)
labels<-names(x)
piepercent<- round(100*x/sum(x), 1)
pie(x, piepercent, radius=1, main="Search", col=rainbow(length(x)), clockwise=TRUE)
legend("topright", labels, cex = 0.8, fill=rainbow(length(x)))

y<-subset(data, AdType == "Context") 
x<-summary(y$bounce)
labels<-names(x)
piepercent<- round(100*x/sum(x), 1)
pie(x, piepercent, radius=1, main="Context", col=rainbow(length(x)), clockwise=TRUE)
legend("topright", labels, cex = 0.8, fill=rainbow(length(x)))

#checking percentage of bounce for each banner
par(mfrow = c(3, 4)) 
y<-subset(data, BannerGroupId==4903443479) 
x<-table(y$bounce)
labels<-names(x)
piepercent<- round(100*x/sum(x), 1)
pie(x, piepercent, radius=1, main="4903443479", col=rainbow(length(x)), clockwise=TRUE)
legend("topright", labels, cex = 0.8, fill=rainbow(length(x)))

y<-subset(data, BannerGroupId==4884206335) 
x<-table(y$bounce)
piepercent<- round(100*x/sum(x), 1)
pie(x, piepercent, radius=1, main="4884206335", col=rainbow(length(x)), clockwise=TRUE)
legend("topright", labels, cex = 0.8, fill=rainbow(length(x)))

y<-subset(data, BannerGroupId==4903443648) 
x<-table(y$bounce)
labels<-names(x)
piepercent<- round(100*x/sum(x), 1)
pie(x, piepercent, radius=1, main="4903443648", col=rainbow(length(x)), clockwise=TRUE)
legend("topright", labels, cex = 0.8, fill=rainbow(length(x)))

y<-subset(data, BannerGroupId==4884206336) 
x<-table(y$bounce)
labels<-names(x)
piepercent<- round(100*x/sum(x), 1)
pie(x, piepercent, radius=1, main="4884206336", col=rainbow(length(x)), clockwise=TRUE)
legend("topright", labels, cex = 0.8, fill=rainbow(length(x)))

y<-subset(data, BannerGroupId==4884206327) 
x<-table(y$bounce)
labels<-names(x)
piepercent<- round(100*x/sum(x), 1)
pie(x, piepercent, radius=1, main="4884206327", col=rainbow(length(x)), clockwise=TRUE)
legend("topright", labels, cex = 0.8, fill=rainbow(length(x)))

y<-subset(data, BannerGroupId==4884206329) 
x<-table(y$bounce)
labels<-names(x)
piepercent<- round(100*x/sum(x), 1)
pie(x, piepercent, radius=1, main="4884206329", col=rainbow(length(x)), clockwise=TRUE)
legend("topright", labels, cex = 0.8, fill=rainbow(length(x)))

y<-subset(data, BannerGroupId==4884206328) 
x<-table(y$bounce)
labels<-names(x)
piepercent<- round(100*x/sum(x), 1)
pie(x, piepercent, radius=1, main="4884206328", col=rainbow(length(x)), clockwise=TRUE)
legend("topright", labels, cex = 0.8, fill=rainbow(length(x)))

y<-subset(data, BannerGroupId==4884206317) 
x<-table(y$bounce)
labels<-names(x)
piepercent<- round(100*x/sum(x), 1)
pie(x, piepercent, radius=1, main="4884206317", col=rainbow(length(x)), clockwise=TRUE)
legend("topright", labels, cex = 0.8, fill=rainbow(length(x)))

y<-subset(data, BannerGroupId==4903443480) 
x<-table(y$bounce)
labels<-names(x)
piepercent<- round(100*x/sum(x), 1)
pie(x, piepercent, radius=1, main="4903443480", col=rainbow(length(x)), clockwise=TRUE)
legend("topright", labels, cex = 0.8, fill=rainbow(length(x)))

y<-subset(data, BannerGroupId==4903443478) 
x<-table(y$bounce)
labels<-names(x)
piepercent<- round(100*x/sum(x), 1)
pie(x, piepercent, radius=1, main="4903443478", col=rainbow(length(x)), clockwise=TRUE)
legend("topright", labels, cex = 0.8, fill=rainbow(length(x)))

#===============Histograms
#for each quantitative columns
par(mfrow = c(2, 2)) 
hist(data$price, main="price")
hist(data$visitDuration, main="visit duration")
hist(data$WatchCount, main="watch count")
hist(data$pageView, main="page views")

#Histograms with conditions for visit duration
par(mfrow = c(2, 2)) 
y<-subset(data, AdType == "Search" & isNewUser==TRUE) 
x<-(y$visitDuration)
hist(x)

y<-subset(data, AdType == "Search" & isNewUser==FALSE) 
x<-(y$visitDuration)
hist(x)

y<-subset(data, AdType == "Context" & isNewUser==TRUE) 
x<-(y$visitDuration)
hist(x)

y<-subset(data, AdType == "Context" & isNewUser==FALSE) 
x<-(y$visitDuration)
hist(x)

#===============boxplot
par(mfrow = c(1, 1))
boxplot(data$price~data$AdType, main="boxplot", ylab="price", xlab="Advertisement type")

par(mfrow = c(1, 1))
boxplot(data$price~data$AdType, main="boxplot", ylab="Visit duration", xlab="Advertisement type")

#===============barplot
par(mfrow = c(1, 2)) 

#mean of visit duration for each operating system
labels<-names(tapply(data$visitDuration, data$operatingSystem, mean, na.rm = TRUE))
barplot(tapply(data$visitDuration, data$operatingSystem, mean, na.rm = TRUE), col=rainbow(7))
legend("topleft", labels, cex = 0.8, fill=rainbow(7))

#mean of visit duration for each BannerGroupId
x <- tapply(data$visitDuration, data$BannerGroupId, mean, na.rm = TRUE)
labels<-names(x)
barplot(x, col=rainbow(length(x)))
legend("topright",  inset=0.02,labels, cex = 0.8, fill = rainbow(length(x)))


#===============Correlation analysis

#chi-square test
data_search = subset(data, AdType == 'Search')
chisq.test(table(data_search$BanerId,data_search$bounce))

data_context = subset(data, AdType == 'Context')
chisq.test(table(data_context$BanerId,data_context$bounce))

#Fisher's exact test
data_search = subset(data, AdType == 'Search')
fisher.test(table(data_search$BanerId,data_search$bounce),  simulate.p.value=TRUE, B = 10000)

data_context = subset(data, AdType == 'Context')
fisher.test(table(data_context$BanerId,data_context$bounce), simulate.p.value=TRUE,  B = 10000)

#correlation between quantitative variables depending on the type of advertisement
M <- data_search[,unlist(lapply(data, is.numeric))]
N1<-cor(M,use="pairwise.complete.obs")
N2<-cor(M,use="pairwise.complete.obs",method="spearman")
N3<-cor(M,use="pairwise.complete.obs",method="kendall")


M <- data_context[,unlist(lapply(data, is.numeric))]
N1<-cor(M,use="pairwise.complete.obs")
N2<-cor(M,use="pairwise.complete.obs",method="spearman")
N3<-cor(M,use="pairwise.complete.obs",method="kendall")


#===============partial correlation
M <- data[,unlist(lapply(data, is.numeric))]
pcor(c(2, 4, 1, 3), cov(M)) 

#===============heatmap
M <- data_search[,unlist(lapply(data, is.numeric))]
N1<-cor(M,use="pairwise.complete.obs")

M <- data_context[,unlist(lapply(data, is.numeric))]
N1<-cor(M,use="pairwise.complete.obs")

par(mfrow = c(1, 1)) 
col <- colorRampPalette(c("#BB4444", "#EE9988", "#FFFFFF", "#77AADD", "#4477AA"))
corrplot(N1, method="color", col=NULL,  
         type="upper", order="hclust", 
         addCoef.col = "black", tl.col="black", tl.srt=45,
         sig.level = 0.01, insig = "blank",
         diag=FALSE 
)


#===============p-value for correlation
cor.test(data_search$pageViews, data_search$WatchCount)
cor.test(data_context$pageViews, data_context$WatchCount)
