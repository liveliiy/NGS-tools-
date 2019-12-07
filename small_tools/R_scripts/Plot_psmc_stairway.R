library(ggplot2)
library(MASS)
library(scales)
library(RColorBrewer)
path <- "~/Desktop/PSMC_MSMC_SMCPP/psmc_LIR/"
fileNames <- dir(path,pattern = "*.table")
tmpname <- strsplit(fileNames,split = "\\.")
filePath <- sapply(fileNames, function(x){paste(path,x,sep = '/')})
tmp<-paste(tmpname[[1]][1])
psmcdata<-data.frame(label=tmp,read.table(filePath[1],header = TRUE))
for(i in 2:length(filePath)){
  tmp<-paste(tmpname[[i]][1])
  newdata <- data.frame(label=tmp,read.table(filePath[i],header = TRUE))
  psmcdata<-rbind(psmcdata,newdata)
}
part1<-psmcdata[psmcdata$lineshape %in% "thin",]
part2<-psmcdata[psmcdata$lineshape %in% "thick",]
psmcdata_new<-rbind(part1,part2)
psmc <- psmcdata_new

path <- "~/Desktop/stairway_tmp/C/"
fileNames <- dir(path,pattern = "*.final.summary$")
tmpname <- strsplit(fileNames,split = "\\.")
filePath <- sapply(fileNames, function(x){paste(path,x,sep = '/')})
tmp<-paste(tmpname[[1]][1])
data<-data.frame(label=tmp,read.table(filePath[1],header = TRUE))

data1 <- data.frame(year = c(data$year,psmc$time),
                    Ne_median = c(data$Ne_median,psmc$N*10000),
                    label = c(as.character(data$label),as.character(psmc$label)),
                    Ne_2.5. = c(data$Ne_2.5.,rep(NA,dim(psmc)[1])),
                    Ne_97.5. = c(data$Ne_97.5.,rep(NA,dim(psmc)[1])),
                    lineshape = c(rep("thick",dim(data)[1]),as.character(psmc$lineshape)),
                    linesize = c(rep(1,dim(data)[1]),psmc$linesize),
                    index = c(as.character(data$label),as.character(psmc$index)),
                    pop = c(rep("stairway_plot",dim(data)[1]),as.character(psmc$pop))
)

#LP1 <- part1[part1$label %in% "LP",]
#LP2 <- part2[part2$label %in% "LP",]
#LP<-rbind(LP1,LP2)
q<-ggplot(data1)+
  geom_ribbon(aes(x=year, ymin=Ne_2.5., ymax=Ne_97.5.,fill=label), alpha=.1) +
  geom_step(aes(x=year,y=Ne_median,group = index,colour=pop,alpha=lineshape,size=linesize))+
  geom_step(aes(x=year,y=Ne_2.5.,group = index,colour=pop),lty=2,lwd=0.5,alpha=0.3)+
  geom_step(aes(x=year,y=Ne_97.5.,group = index,colour=pop),lty=2,lwd=0.5,alpha=0.3)+
  scale_x_log10(limits = c(100,NA), breaks = trans_breaks("log10",function(x) 10^x,n=4))+
  annotation_logticks(base = 10,sides = "b")+
  coord_cartesian(ylim = c(1000,200000),xlim = c(100,10000000))+
  scale_color_manual(values = c("#0072B2","#D55E00","black"))+
  scale_alpha_manual(values=c(1,0.5),guide=FALSE)+
  scale_fill_brewer(palette="#0072B2","#D55E00","grey")+
  scale_size(range = c(0.05,0.8),guide=FALSE)
psmc_plot<-q+theme_bw()+xlab("years")+ylab("effective population size Ne")+theme(panel.border = element_blank(),panel.grid.major = element_blank(),panel.grid.minor = element_blank(),axis.line = element_line(colour = "black"))
psmc_plot



q<-ggplot(data1)+
  geom_ribbon(aes(x=year, ymin=Ne_2.5., ymax=Ne_97.5.,fill=label), alpha=.1) +
  geom_step(aes(x=year,y=Ne_median,group = label,colour=label))+
  geom_step(aes(x=year,y=Ne_2.5.,group = label,colour=label),lty=2,lwd=0.5,alpha=0.3)+
  geom_step(aes(x=year,y=Ne_97.5.,group = label,colour=label),lty=2,lwd=0.5,alpha=0.3)+
  #scale_color_manual(values = c("#0072B2","#009E73","#D55E00","#E69F00","#56B4E9","#CC79A7"))+
  scale_x_log10(limits = c(100,NA), breaks = trans_breaks("log10",function(x) 10^x,n=4))+
  annotation_logticks(base = 10,sides = "b")+
  scale_fill_brewer(palette="Set1")+
  scale_color_brewer(palette="Set1")+
  coord_cartesian(ylim = c(2000,100000),xlim = c(100,10000000))+
  facet_grid(label ~ .)
#scale_color_manual(values = c("#0072B2","#009E73","#D55E00","#E69F00","#56B4E9","#CC79A7"))
stairway<-q+theme_bw()+xlab("years")+ylab("effective population size Ne")+theme(panel.border = element_blank(),panel.grid.major = element_blank(),panel.grid.minor = element_blank(),axis.line = element_line(colour = "black"))
stairway

q<-ggplot(psmcdata_new)+
  geom_step(aes(x=time,y=N*10000,group = index,colour=pop,alpha=lineshape,size=linesize))+
  scale_x_log10(limits = c(100,NA), breaks = trans_breaks("log10",function(x) 10^x,n=4))+
  annotation_logticks(base = 10,sides = "b")+
  coord_cartesian(ylim = c(1000,30000),xlim = c(10000,10000000))+
  scale_color_manual(values = c("#D55E00","#0072B2"))+
  scale_alpha_manual(values=c(1,0.5),guide=FALSE)+
  scale_size(range = c(0.05,0.8),guide=FALSE)
psmc<-q+theme_bw()+xlab("years")+ylab("effective population size Ne")+theme(panel.border = element_blank(),panel.grid.major = element_blank(),panel.grid.minor = element_blank(),axis.line = element_line(colour = "black"))
psmc






