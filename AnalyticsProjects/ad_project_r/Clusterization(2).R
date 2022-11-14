library("clusterSim")
library("gplots")
library("factoextra")
library("NbClust")

#read csv
data<-read.csv("Data_traffc.csv")
View(data)

#converting data by deleting outliers
mis_data <- subset(data, visitDuration > 400)
View(mis_data)

new_data <- subset(data, visitDuration < 400)
new_data <- new_data[3:21]
View(new_data)
unique(new_data$clientID)

nrow(new_data)

#normalization
maxs <- apply(new_data[,16:18], 2, max)
mins <- apply(new_data[,16:18], 2, min)
data1 <- scale(new_data[,16:18], center = mins, scale = maxs - mins)
View(data1)

#clusterization by Ward method 
dist.prog <- dist(data1, method = "maximum")
clust.prog <- hclust(dist.prog, "ward.D2")
clust.prog

#draw the tree
plot(clust.prog, hang = -1)
rect.hclust(clust.prog, k=4, border="red")


#heatmap
dist.prog1 <- function(x) dist(x, method="maximum")
clust.prog1 <- function(x) hclust(x, "ward.D2")
hv3 <- heatmap.2(data1, distfun=dist.prog1, hclustfun=clust.prog1)

#cophenetic correlation
d2<-cophenetic(clust.prog)
cor(dist.prog,d2)

# means and number of rows in each cluster 
gr_Ward_4 <- cutree(clust.prog, k=4)
new_data <- cbind(new_data, gr_Ward_4)
View(new_data)

colMeans(new_data[groups==1, 16:19])
colMeans(new_data[groups==2, 16:19])
colMeans(new_data[groups==3, 16:19])
colMeans(new_data[groups==4, 16:19])

nrow(new_data[groups==1, 16:19])
nrow(new_data[groups==2, 16:19])
nrow(new_data[groups==3, 16:19])
nrow(new_data[groups==4, 16:19])


#k - means clusterization
dim(data1)
summ.1 = kmeans(data1, 4, iter.max = 100)
gr <- summ.1$cluster
colMeans(new_data[gr == 1,16:19])
colMeans(new_data[gr == 2,16:19])
colMeans(new_data[gr == 3,16:19])
colMeans(new_data[gr == 4,16:19])

nrow(new_data[gr == 1,16:19])
nrow(new_data[gr == 2,16:19])
nrow(new_data[gr == 3,16:19])
nrow(new_data[gr == 4,16:19])


#Graph within groups sum of squares
wss <- (nrow(data1)-1)*sum(apply(data1,2,var))
for (i in 2:15) 
  wss[i] <- kmeans(data1,centers=i)$tot.withinss
plot(1:15, wss, type="b", xlab="Number of Clusters", ylab="Within groups sum of squares")

# Graph between groups sum of squares
wss <- 0
for (i in 2:15) wss[i] <- kmeans(data1, centers=i)$betweenss
plot(1:15, wss, type="b", xlab="Number of Clusters", ylab="Betweenss groups sum of squares")

#circles
summ.1 = kmeans(data1, 4, iter.max = 100)
p4 <- fviz_cluster(summ.1, data =data1, ellipse.type = "norm", show.clust.cent = TRUE, ellipse = TRUE)
p4

#quality indices
res.nbclust <- NbClust(data1, distance = "maximum", min.nc = 2, max.nc = 9, method = "ward.D2", index ="all")
res.nbclust$All.index
res.nbclust$Best.nc
res.nbclust$Best.partition
#====
final_data <- cbind(new_data, gr_Ward_4)

write.csv(final_data, "Data_for_tree", row.names = FALSE)
