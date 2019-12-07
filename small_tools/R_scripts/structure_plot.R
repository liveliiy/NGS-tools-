setwd("~/Desktop/南京林业大学psmc/LIR_PCA_ADM_structure/new_structure/LIR_CLUMPP/")
k3 <- read.table("K3.table1",header = F,row.names = 1)
list <- read.table("list1",header = F)
#barplot(t(as.matrix(k3)),col = c("#0072B2","#009E73","#D55E00"),border="black",space=0)
data <- data.frame(ind = rep(row.names(k3),3),
                   num = c(k3$V2,k3$V3,k3$V4),
                   group = c(rep("NORTH AMERICIAN",dim(k3)[1]),rep("EAST CHINA",dim(k3)[1]),rep("WEST CHINA",dim(k3)[1]))
)
list <- as.character(list$V1)
data$ind <- factor(data$ind,levels=list)
library(ggplot2)
ggplot(data,aes(x=ind,weight = num,fill=group))+geom_bar()+
  scale_fill_manual(values = c("#0072B2","#009E73","#D55E00"))+
  theme(axis.text.x = element_text(angle = 90, hjust = 0.5, vjust = 0.5))+
  ylab("Frequency")+labs(fill="pop")+xlab("")



########################K2############################################################
setwd("~/Desktop/南京林业大学psmc/LIR_PCA_ADM_structure/new_structure/LIR_CLUMPP/")
k2 <- read.table("K2.table",header = F,row.names = 1)
list <- read.table("list1",header = F)
data <- data.frame(ind = rep(row.names(k2),2),
                   num = c(k2$V2,k2$V3),
                   group = c(rep("CHINA",dim(k2)[1]),rep("NORTH AMERICIAN",dim(k2)[1]))
)
list <- as.character(list$V1)
data$ind <- factor(data$ind,levels=list)
library(ggplot2)
ggplot(data,aes(x=ind,weight = num,fill=group))+geom_bar()+
  scale_fill_manual(values = c("#0072B2","#009E73"))+
  theme(axis.text.x = element_text(angle = 90, hjust = 0.5, vjust = 0.5))+
  ylab("Frequency")+labs(fill="")+xlab("")
