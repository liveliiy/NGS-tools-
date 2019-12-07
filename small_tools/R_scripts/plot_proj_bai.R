newjiangshui<-jiangshui[-c(17:19),]
newTemp<-Temperature[-c(17:19),]
plotjiangshui <- function(data,place,xvalue,meandata,shapedata,sddata,xname,yname){
  ggplot(data)+theme_bw()+
  theme(panel.grid.major=element_blank(),panel.grid.minor=element_blank(),axis.text.x = element_text(size = 15),axis.text.y = element_text(size = 15),axis.title.x =element_text(size=20),axis.title.y = element_text(size = 20),legend.title=element_blank())+
  geom_point(aes(x=xvalue,y=meandata,shape=shapedata,colour=shapedata),size=8)+
  scale_shape_manual(values = c(16,0,0))+
  scale_color_manual(values = c("red","red","yellow"))+
  geom_errorbar(aes(x=xvalue,ymin=meandata-sddata,ymax=meandata+sddata,colour=shapedata),width=.2,size=0.25)+
  scale_x_continuous(limits = c(floor(min(xvalue)-1),ceiling(max(xvalue)+1)))+
  annotate(geom = "text",x=xvalue,y=meandata+sddata+15,label=place)+
  labs(x=xname,y=yname)
}
plottemperature <- function(data,place,xvalue,meandata,shapedata,sddata,xname,yname){
  ggplot(data)+theme_bw()+
    theme(panel.grid.major=element_blank(),panel.grid.minor=element_blank(),axis.text.x = element_text(size = 15),axis.text.y = element_text(size = 15),axis.title.x =element_text(size=20),axis.title.y = element_text(size = 20),legend.title=element_blank())+
    geom_point(aes(x=xvalue,y=meandata,shape=shapedata,colour=shapedata),size=8)+
    scale_shape_manual(values = c(16,0,0))+
    scale_color_manual(values = c("red","red","yellow"))+
    geom_errorbar(aes(x=xvalue,ymin=meandata-sddata,ymax=meandata+sddata,colour=shapedata),width=.2,size=0.25)+
    scale_x_continuous(limits = c(floor(min(xvalue)-1),ceiling(max(xvalue)+1)))+
    annotate(geom = "text",x=xvalue,y=meandata+sddata+5,label=place)+
    labs(x=xname,y=yname)
}
plotcv <- function(data,place,xvalue,meandata,shapedata,xname,yname){
  ggplot(data)+theme_bw()+
    theme(panel.grid.major=element_blank(),panel.grid.minor=element_blank(),axis.text.x = element_text(size = 15),axis.text.y = element_text(size = 15),axis.title.x =element_text(size=20),axis.title.y = element_text(size = 20),legend.title=element_blank())+
    geom_point(aes(x=xvalue,y=meandata,shape=shapedata,colour=shapedata),size=8)+
    scale_shape_manual(values = c(16,0,0))+
    scale_color_manual(values = c("red","red","yellow"))+
    scale_x_continuous(limits = c(floor(min(xvalue)-1),ceiling(max(xvalue)+1)))+
    annotate(geom = "text",x=xvalue,y=meandata+0.012,label=place)+
    labs(x=xname,y=yname)
}
######################################################################
data=newjiangshui
place=newjiangshui$place
xvalue=newjiangshui$Longtitude
xvalue1=newjiangshui$Latitude
meandata=newjiangshui$mean_rain8to20summer
cvdata=newjiangshui$cv_rain8to20summer
shapedata=newjiangshui$Life
sddata=newjiangshui$sd_rain8to20summer
xname="Longtitude"
xname1="Latitude"
yname="precipitation 8to20summer"
yname1="cv precipitation 8to20summer"
plotjiangshui(xvalue=xvalue,meandata=meandata,sddata=sddata,xname=xname,yname=yname,shapedata=shapedata,data=data,place=place)
plotjiangshui(xvalue=xvalue1,meandata=meandata,sddata=sddata,xname=xname1,yname=yname,shapedata=shapedata,data=data,place=place)
plotcv(data = data,place = place,xvalue = xvalue,meandata = cvdata,shapedata = shapedata,xname =xname,yname = yname1)
plotcv(data = data,place = place,xvalue = xvalue1,meandata = cvdata,shapedata = shapedata,xname =xname1,yname = yname1)
###########################################################################
data=newTemp
place=newTemp$place
xvalue=newTemp$Longtitude
xvalue1=newTemp$Latitude
meandata=newTemp$mean_TempExtLowsummer
cvdata=newTemp$cv_TempExtLowsummer
shapedata=newTemp$Life.history.COLOR
sddata=newTemp$sd_TempExtLowsummer
xname="Longtitude"
xname1="Latitude"
yname="temperature TempExtLowsummer"
yname1="cv temperature TempExtLowsummer"
tmpname<-paste(yname,xname,sep = "_")
image<-paste(tmpname,".tiff",sep = "")
setwd("~/Desktop/bai_temperature/")
tiff(file = image,width=1500, height=444)
plottemperature(xvalue=xvalue,meandata=meandata,sddata=sddata,xname=xname,yname=yname,shapedata=shapedata,data=data,place=place)
dev.off()
tmpname<-paste(yname,xname1,sep = "_")
image<-paste(tmpname,".tiff",sep = "")
setwd("~/Desktop/bai_temperature/")
tiff(file = image,width=1500, height=444)
plottemperature(xvalue=xvalue1,meandata=meandata,sddata=sddata,xname=xname1,yname=yname,shapedata=shapedata,data=data,place=place)
dev.off()
tmpname<-paste(yname1,xname,sep = "_")
image<-paste(tmpname,".tiff",sep = "")
setwd("~/Desktop/bai_temperature/")
tiff(file = image,width=670, height=444)
plotcv(data = data,place = place,xvalue = xvalue,meandata = cvdata,shapedata = shapedata,xname =xname,yname = yname1)
dev.off()
tmpname<-paste(yname1,xname1,sep = "_")
image<-paste(tmpname,".tiff",sep = "")
setwd("~/Desktop/bai_temperature/")
tiff(file = image,width=670, height=444)
plotcv(data = data,place = place,xvalue = xvalue1,meandata = cvdata,shapedata = shapedata,xname =xname1,yname = yname1)
dev.off()
###########################################################################

######################################################
plottemperature(xvalue=xvalue,meandata=meandata,sddata=newTemp$sd_TempAve,xname="Longtitude",yname="temperature average",shapedata=newTemp$Life.history.COLOR,data=newTemp,place=newTemp$place)
plotcv(xvalue=xvalue,meandata=newjiangshui$cv_rain20to8,xname="Longtitude",yname="precipitation 8to20",shapedata=newjiangshui$Life,data=newjiangshui,place=newjiangshui$place)



#######################################################################
plotjiangshui(xvalue=newjiangshui$Longtitude,meandata=newjiangshui$mean_rain20to8,sddata=newjiangshui$sd_rain8to20,xname="Longtitude",yname="precipitation 8to20",shapedata=newjiangshui$Life,data=newjiangshui,place=newjiangshui$place)
plottemperature(xvalue=newTemp$Longtitude,meandata=newTemp$mean_TempAve,sddata=newTemp$sd_TempAve,xname="Longtitude",yname="temperature average",shapedata=newTemp$Life.history.COLOR,data=newTemp,place=newTemp$place)
plotcv(xvalue=newjiangshui$Longtitude,meandata=newjiangshui$cv_rain20to8,xname="Longtitude",yname="precipitation 8to20",shapedata=newjiangshui$Life,data=newjiangshui,place=newjiangshui$place)
