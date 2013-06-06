#
# Loads data
#
setwd("/usr/var/projects/aurin/git/map-rendering-test/test/result")

# Limited bandwidth data
pbc14.df<-read.table("20130503results-e-512k.pbc.14.csv",header=T, sep=",")
pbc15.df<-read.table("20130506results-e-512k.pbc.15.csv",header=T, sep=",")
pbc16.df<-read.table("20130503results-e-512k.pbc.16.csv",header=T, sep=",")
pbc17.df<-read.table("20130507results-e-512k.pbc.17.csv",header=T, sep=",")
pbc18.df<-read.table("20130508results-e-512k.pbc.18.csv",header=T, sep=",")
pbc19.df<-read.table("20130508results-e-512k.pbc.19.csv",header=T, sep=",")
pbc20.df<-read.table("20130510results-e-512k.pbc.20.csv",header=T, sep=",")
pbc21.df<-read.table("20130515results-e-512k.pbc.21.csv",header=T, sep=",")

pbc22.df<-read.table("20130601results-e-512k-HTTP.pbc.22.csv",header=T, sep=",")
pbc23.df<-read.table("20130601results-e-512k-HTTP.pbc.23.csv",header=T, sep=",")
pbc24.df<-read.table("20130602results-e-512k-HTTP.pbc.24.csv",header=T, sep=",")
pbc25.df<-read.table("20130602results-e-512k-HTTP.pbc.25.csv",header=T, sep=",")
pbc27.df<-read.table("20130603results-e-512k-HTTP.pbc.27.csv",header=T, sep=",")
pbc29.df<-read.table("20130603results-e-512k-HTTP.pbc.29.csv",header=T, sep=",")
pbc26.df<-read.table("20130604results-e-512k-HTTP.pbc.26.csv",header=T, sep=",")
pbc28.df<-read.table("20130606results-e-512k-HTTP.pbc.28.csv",header=T, sep=",")


cols<-cbind("Type", "Precision","Dataset", "Generalization", "Compression", "Size", "Npoints", "Ngeoms","Time","PointsPerSec")
names(pbc14.df)<-cols
names(pbc15.df)<-cols
names(pbc16.df)<-cols
names(pbc17.df)<-cols
names(pbc18.df)<-cols
names(pbc19.df)<-cols
names(pbc20.df)<-cols
names(pbc21.df)<-cols
names(pbc22.df)<-cols
names(pbc23.df)<-cols
names(pbc24.df)<-cols
names(pbc25.df)<-cols
names(pbc26.df)<-cols
names(pbc27.df)<-cols
names(pbc28.df)<-cols
names(pbc29.df)<-cols

pbc.df<-rbind(pbc14.df, pbc15.df, pbc16.df, pbc17.df, pbc18.df, pbc19.df, pbc20.df, pbc21.df)
pbch.df<-rbind(pbc22.df, pbc23.df, pbc24.df, pbc25.df, pbc26.df, pbc26.df, pbc28.df, pbc29.df)

# Data clean-up
pbc.df<-pbc.df[pbc.df$Npoints<25000,]
pbch.df<-pbch.df[pbch.df$Npoints<25000,]
pbch.df$Protocol<-"http"
pbc.df$Protocol<-"https"
pbc.df<-rbind(pbc.df, pbch.df)

# Recodification of variables as factors
pbc.df$Precision<-as.factor(pbc.df$Precision) 
pbc.df$Generalization<-as.factor(pbc.df$Generalization)
pbc.df$Compression<-as.factor(pbc.df$Compression)
pbc.df$Protocol<-as.factor(pbc.df$Protocol)

#
# xtab to check that every combination of values have been tested
#
xtabs(~Precision+Generalization+Compression+Protocol, pbc.df)

#
# First analysis to spot anomalies
#
by(pbc.df, pbc.df$Precision, summary)
by(pbc.df, pbc.df$Generalization, summary)
by(pbc.df, pbc.df$Compression, summary)
by(pbc.df, pbc.df$Protocol, summary)



t.test(pbc.df$Time[pbc.df$Compression=="true"] ,pbc.df$Time[pbc.df$Compression=="false"], conf.level=0.99)



#
# Definition of analytical functions
#
pbcLm<-function (df, models) {
  #par(mfrow = c(length(models), 1))
  par(mfrow = c(2, 2))
  lapply(models, function(mod) {
        mod$lm<-lm(mod$mod, df)
#        plot(df[,mod$x], df[,mod$y], col="green", pch=20, main=mod$title, xlab="")
#        points(df[,mod$x], fitted(mod$lm), col="black", pch=20, xlab="")
        print(cat("---------------", mod$title, "---------------"))
        plot(mod$lm, main=mod$title)
        print(summary(mod$lm))
        "OK"
      })
}

#
# Data summaries
#
summary(pbc.df)
by(pbc.df, pbc.df$Precision, summary)


lapply(list(
#        list(df=pbc.df, title="PBC"), 
#        list(df=pbc04.df, title="PBC04"),
#        list(df=pbc05.df, title="PBC05"),        
#        list(df=pbc06.df, title="PBC06"),        
#        list(df=pbc07.df, title="PBC07"),        
#        list(df=pbc08.df, title="PBC08"),        
#        list(df=pbc09.df, title="PBC09"),        
#        list(df=pbc10.df, title="PBC10")        
    ), function(e) {
      sprintf("----------------------------------")
      sprintf(e$title)
#          by(e$df$Time, e$df$Precision, summary)
      by(e$df$PointsPerSec, e$df$Precision, summary)
    })

#
# Analysis of correlation between time and, size, points and geometries
#

# Effects of precision on time
by(pbc.df$Time, pbc.df$Precision, summary)
by(pbc.df$PointsPerSec, pbc.df$Precision, summary)

pbcTiSz <-list("mod"=Time~Size, "x"="Size", "y"="Time", title="Time(Size)")
pbcTiPo <-list("mod"=Time~Npoints, "x"="Npoints" , "y"="Time", title="Time(Npoints)")
pbcTiGe <-list("mod"=Time~Ngeoms, "x"="Ngeoms", "y"="Time", title="Time(Ngeoms)")

pbcTiSzPre <-list("mod"=Time~Size+Precision, "x"="Size", "y"="Time", title="Time(Size+Precision)")
pbcTiPoPre <-list("mod"=Time~Npoints+Precision, "x"="Npoints" , "y"="Time", title="Time(Npoints+Precision)")
pbcTiGePre <-list("mod"=Time~Ngeoms+Precision, "x"="Ngeoms", "y"="Time", title="Time(Ngeoms+Precision)")

pbcLm(pbc.df, list(pbcTiSz))
pbcLm(pbc.df, list(pbcTiPo))
pbcLm(pbc.df, list(pbcTiGe))

pbcLm(pbc.df, list(pbcTiSzPre))
pbcLm(pbc.df, list(pbcTiPoPre))
pbcLm(pbc.df, list(pbcTiGePre))



pbc.df.prec4<-pbc.df[pbc.df$Precision==4,]
summary(pbc.df.prec4)
pbcLm(pbc.df.prec4, 
    list( 
        list("mod"=PointsPerSec~log(Npoints), "x"=pbc.df.prec4$Npoints, "y"=pbc.df.prec4$PointsPerSec) 
    ))

pbc.df.prec15<-pbc.df[pbc.df$Precision==15,]
summary(pbc.df.prec15)
pbcLm(pbc.df.prec15, 
    list( 
        list("mod"=PointsPerSec~log(Npoints), "x"=pbc.df.prec15$Npoints, "y"=pbc.df.prec15$PointsPerSec) 
    ))

# Analyzes correlation between throughput and, size, points and geometries
par(mfrow = c(3, 1))
plot(pbc.df$Points, pbc.df$PointsPerSec, col="green", pch=20)
plot(pbc.df$Ngeoms, pbc.df$PointsPerSec, col="green", pch=20)
plot(pbc.df$Size, pbc.df$PointsPerSec, col="green", pch=20)




# TODO
plot(pbc.df$Points[pbc.df$Precision==4], pbc.df$Size[pbc.df$Precision==4], col="green",xlim=c(0,25000))
points(pbc.df$Points[pbc.df$Precision==15], pbc.df$Size[pbc.df$Precision==15], col="red",xlim=c(0,25000))

plot(pbc.df$Points[pbc.df$Precision==4], pbc.df$PointsPerSec[pbc.df$Precision==4], col="green")
points(pbc.df$Points[pbc.df$Precision==15], pbc.df$PointsPerSec[pbc.df$Precision==15], col="red")

plot(pbc.df$Size, pbc.df$PointsPerSec, col="green")
plot(pbc.df$Npoints, pbc.df$PointsPerSec, col="green")

t.test(pbc.df$Size~pbc.df$Precision)
#points(pbc.df$Npoints, fitted(pbc.modT.lm))
#summary(pbc.modT)
#plot(pbc.df$Npoints, pbc.df$PointsPerSec, col="green")
#points(pbc.df$Npoints, fitted(pbc.modTlog.lm))
#summary(pbc.modTlog)

#plot(pbc.df$Npoints, pbc.df$PointsPerSec, col="green")
points(pbc.df$Npoints, fitted(pbc.modTSlog.lm))
summary(pbc.modTSlog)

par(mfrow = c(2, 2))
plot(pbc.modT.lm)

par(mfrow = c(2, 2))
plot(pbc.modTlog.lm)

mean(pbc.df$PointsPerSec)

par(mfrow = c(2, 1))
plot(pbc.df.prec15$Npoints, pbc.df.prec15$Time, col="black", pch=20)
points(pbc.df.prec4$Npoints, pbc.df.prec4$Time, col="green", pch=20)
plot(pbc.df.prec15$Npoints, pbc.df.prec15$PointsPerSec, col="black", pch=20)
points(pbc.df.prec4$Npoints, pbc.df.prec4$PointsPerSec, col="green", pch=20)