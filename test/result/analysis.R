#
# Loads data
#
setwd("/usr/var/projects/aurin/git/map-rendering-test/test/result")
pbc.df<-read.table("pbc.csv",header=T, sep=",")
pbc04.df<-read.table("20130417results-pbc.04.csv",header=T, sep=",")
pbc05.df<-read.table("20130417results-pbc.05.csv",header=T, sep=",")
pbc06.df<-read.table("20130417results-pbc.06.csv",header=T, sep=",")
#pbc07.df<-read.table("20130417results-pbc.07.csv",header=T, sep=",")
pbc.df<-rbind(pbc.df, pbc04.df, pbc05.df, pbc06.df)

# Data clean-up
pbc.df<-pbc.df[pbc.df$Npoints < 25000 & pbc.df$Time < 2,] # Gets rid of extreme values
pbc.df<-pbc.df[-c(333, 844),] # Gets rid of outliers

# Data recoding
pbc.df$Precision<-as.factor(pbc.df$Precision) # Transforms Precision in a factor

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

#
# Analysis of correlation between time and, size, points and geometries
#

# Effects of precision on time
by(pbc.df$Time, pbc.df$Precision, summary)

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
