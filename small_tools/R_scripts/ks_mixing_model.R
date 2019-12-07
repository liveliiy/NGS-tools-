###read data file##################################################
setwd("~/Desktop/dingym_ks/")
data <- read.table("Rch_ks.txt",header=T)[,1]
###plot preparation################################################
par(mfrow=c(3,1))
bbk=0.01
bb2=1/bbk
n<-5000
lenll<-10
plotEXP <- function(ss,pp){
  theoreticalData<- rexp(round(pp * n), rate = 1/ss)
  theoreticalDensity <- dexp(theoreticalData,rate = 1/ss)
  lines(smooth.spline(theoreticalData, theoreticalDensity))
  theoreticalData[which.max(theoreticalDensity)]###mode#####
  segments(theoreticalData[which.max(theoreticalDensity)],0,theoreticalData[which.max(theoreticalDensity)],max(theoreticalDensity),col="firebrick",lwd=2)
  return(ss)
}
plotNorm <- function(mm,ss,pp){
  theoreticalData<- rnorm(round(pp * n), mean = mm, sd = ss)
  theoreticalDensity <- dnorm(theoreticalData,mean = mm, sd = ss)
  lines(smooth.spline(theoreticalData, theoreticalDensity))
  theoreticalData[which.max(theoreticalDensity)]
  segments(theoreticalData[which.max(theoreticalDensity)],0,theoreticalData[which.max(theoreticalDensity)],max(theoreticalDensity),col="firebrick",lwd=2)
  return(mm)
}
plotLogNorm <- function(mm,ss,pp){
  theoreticalData<- rlnorm(round(pp * n), meanlog = mm, sdlog = ss)
  theoreticalDensity <- dlnorm(theoreticalData,meanlog = mm, sdlog = ss)
  lines(smooth.spline(theoreticalData, theoreticalDensity))
  theoreticalData[which.max(theoreticalDensity)]
  segments(theoreticalData[which.max(theoreticalDensity)],0,theoreticalData[which.max(theoreticalDensity)],max(theoreticalDensity),col="firebrick",lwd=2)
  return(exp(mm))
}
plotGamma <- function(mm,ss,pp){
  theoreticalData<- rgamma(round(pp * n), shape =  mm, scale = 1/ss)
  theoreticalDensity <- dgamma(theoreticalData,shape =  mm, scale = 1/ss)
  lines(smooth.spline(theoreticalData, theoreticalDensity))
  theoreticalData[which.max(theoreticalDensity)]
  segments(theoreticalData[which.max(theoreticalDensity)],0,theoreticalData[which.max(theoreticalDensity)],max(theoreticalDensity),col="firebrick",lwd=2)
  return(mm/ss)
}
###data file 1#########################################################

###Exp + Normal distribution#################################################
a<-c(1,0.01401816,0.1384009,0.04869164,0.2872618,0.1027218,0.717256,0.1765025)
b<-c(0.06633553,0.3864855,0.359452,0.187727)
x <- data
x <- x[x>0 & x<5]
e<-hist(x,breaks=seq(0.0,max(x)+bbk,by=bbk),plot=F)
e$counts = e$counts*bb2/sum(e$counts)
plot(e,xlim=c(0,1),ylim=c(1,lenll),col="lightgrey",ylab="Density",xlab="Pair-wise Distance",main="Pair-wise distance of data (Exp + normal)")
segments(median(x,na.rm=T),0,median(x,na.rm=T),lenll,col="blue",lty=3,lwd=3)
medi=NA
###Plot K components###################################################
medi[1] <- plotEXP(a[2],b[1])
medi[2] <- plotNorm(a[3],a[4],b[2])
medi[3] <- plotNorm(a[5],a[6],b[3])
medi[4] <- plotNorm(a[7],a[8],b[4])
###par legend###########################################################
pars <- c(median(x,na.rm=T),medi[1],medi[2],medi[3],medi[4])
pars <- (pars/((2.06e-9)*2))/1000000
pars <- round(pars,digits=2)
nams <- c("Obs: ","K1: ","K2: ","K3: ","K4: ")
pcts <- c(" ", paste("(p=",round(b*100,digits=1),"%",")",sep=""))
pars <- paste(nams,pars," Ma ",pcts,sep="")
legend("topright", pars)


