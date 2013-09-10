#
# analysis.R
#

setwd("/usr/var/projects/aurin/git/map-rendering-test/test/result")   
source("functions.R")
pbc.df<-pbc.load()

#
# Add a derived variable
#
pbc.df$SizePerGeom<-(pbc.df$Size / pbc.df$Ngeoms)

#
# xtab to check that every combination of values have been tested
#
xtabs(~Precision+Generalization+Compression+Protocol, pbc.df)


#
# Model definitions
#
pbcPoGe <-list("mod"=Npoints~Ngeoms, "x"="Npoints", "y"="Ngeoms", title="Npoints(Ngeoms)")
pbcPoSz <-list("mod"=Npoints~Size, "x"="Npoints", "y"="Size", title="Npoints(Size)")
pbcTiSzCom <-list("mod"=Time~Size+Compression, "x"="Size", "y"="Time", title="Time(Size+Compression)")
pbcTiPoCom <-list("mod"=Time~Npoints+Compression, "x"="Npoints" , "y"="Time", title="Time(Npoints+Compression)")
pbcTiGeCom <-list("mod"=Time~Ngeoms+Compression, "x"="Ngeoms", "y"="Time", title="Time(Ngeoms+Compression)")
pbcTiSzGen <-list("mod"=Time~Size+Generalization, "x"="Size", "y"="Generalization", title="Time(Size+Generalization)")
pbcTiPoGen <-list("mod"=Time~Npoints+Generalization, "x"="Npoints" , "y"="Generalization", title="Time(Npoints+Generalization)")
pbcTiGeGen <-list("mod"=Time~Ngeoms+Generalization, "x"="Ngeoms", "y"="Generalization", title="Time(Ngeoms+Generalization)")
pbcTrTi <-list("mod"=PointsPerSec~Time, "x"="PointsPerSec", "y"="Time", title="PointsPerSec(Time)")
pbcTrSz <-list("mod"=PointsPerSec~Size, "x"="PointsPerSec", "y"="Size", title="PointsPerSec(Size)")
pbcTrSzGen <-list("mod"=PointsPerSec~Size+Generalization, "x"="Size", "y"="Throughput", title="Throughput(Size+Generalization)")
pbcTrPoGen <-list("mod"=PointsPerSec~Npoints+Generalization, "x"="Npoints" , "y"="Throughput", title="Throughput(Npoints+Generalization)")
pbcTrGeGen <-list("mod"=PointsPerSec~Ngeoms+Generalization, "x"="Ngeoms", "y"="Throughput", title="Throughput(Ngeoms+Generalization)")

pbcSizePoFeGenComp <-list("mod"=Size~Ngeoms+Npoints+Generalization+Compression, "x"="Ngeoms", "y"="Size", title="Size(Ngeoms+Npoints+Generalization+Compression)")
pbcSizePoFeComp<-list("mod"=Size~Ngeoms+Npoints+Compression, "x"="Ngeoms", "y"="Size", title="Size(Ngeoms+Npoints+Compression)")

#
# Liniear models analysis 
# NOTE: run them one by one ! 
#

pbcLm(pbc.df, list(pbcPoGe))
pbcLm(pbc.df, list(pbcPoSz))

pbcLm(pbc.df, list(pbcTiSzCom))
pbcLm(pbc.df, list(pbcTiPoCom))
pbcLm(pbc.df, list(pbcTiGeCom))

pbcLm(pbc.df, list(pbcTiSzGen))
pbcLm(pbc.df, list(pbcTiPoGen))
pbcLm(pbc.df, list(pbcTiGeGen))

pbcLm(pbc.df, list(pbcTrTi))

pbcLm(pbc.df, list(pbcTrSz))

pbcLm(pbc.df, list(pbcTrSzGen))
pbcLm(pbc.df, list(pbcTrPoGen))
pbcLm(pbc.df, list(pbcTrGeGen))

#
# Computes means of Throughput and Time
#
pbc.mtih<-rbind(
    compMeanTime(pbc.df, 0.05, "true", 15, "http"),
    compMeanTime(pbc.df, 0.05, "true", 4, "http"),
    compMeanTime(pbc.df, 0.05, "false", 15, "http"),
    compMeanTime(pbc.df, 0.05, "false", 4, "http"),
    compMeanTime(pbc.df, 0.01, "true", 15, "http"),
    compMeanTime(pbc.df, 0.01, "true", 4, "http"),
    compMeanTime(pbc.df, 0.01, "false", 15, "http"),
    compMeanTime(pbc.df, 0.01, "false", 4, "http")
)

pbc.mtis<-rbind(
    compMeanTime(pbc.df, 0.05, "true", 15, "https"),
    compMeanTime(pbc.df, 0.05, "true", 4, "https"),
    compMeanTime(pbc.df, 0.05, "false", 15, "https"),
    compMeanTime(pbc.df, 0.05, "false", 4, "https"),
    compMeanTime(pbc.df, 0.01, "true", 15, "https"),
    compMeanTime(pbc.df, 0.01, "true", 4, "https"),
    compMeanTime(pbc.df, 0.01, "false", 15, "https"),
    compMeanTime(pbc.df, 0.01, "false", 4, "https")
)

pbc.mppsh<-rbind(
    compMeanPPS(pbc.df, 0.05, "true", 15, "http"),
    compMeanPPS(pbc.df, 0.05, "true", 4, "http"),
    compMeanPPS(pbc.df, 0.05, "false", 15, "http"),
    compMeanPPS(pbc.df, 0.05, "false", 4, "http"),
    compMeanPPS(pbc.df, 0.01, "true", 15, "http"),
    compMeanPPS(pbc.df, 0.01, "true", 4, "http"),
    compMeanPPS(pbc.df, 0.01, "false", 15, "http"),
    compMeanPPS(pbc.df, 0.01, "false", 4, "http")
)

pbc.mppss<-rbind(
    compMeanPPS(pbc.df, 0.05, "true", 15, "https"),
    compMeanPPS(pbc.df, 0.05, "true", 4, "https"),
    compMeanPPS(pbc.df, 0.05, "false", 15, "https"),
    compMeanPPS(pbc.df, 0.05, "false", 4, "https"),
    compMeanPPS(pbc.df, 0.01, "true", 15, "https"),
    compMeanPPS(pbc.df, 0.01, "true", 4, "https"),
    compMeanPPS(pbc.df, 0.01, "false", 15, "https"),
    compMeanPPS(pbc.df, 0.01, "false", 4, "https")
)

#
# Plots Time vs Throughput
#
plot(pbc.mppsh[,2], pbc.mtih[,2], ylab = "Time (s)", xlab = "Throughput (pts/s)", col="blue",
    xlim=c(4000,11000), ylim=c(0.15, 0.7))
pointLabel(pbc.mppsh[,2], pbc.mtih[,2], labels = paste("  ", pbc.mtih[,1], "  ", sep=""), cex=0.7)

points(pbc.mppss[,2], pbc.mtis[,2], col="red")
pointLabel(pbc.mppss[,2], pbc.mtis[,2], labels = paste("  ", pbc.mtis[,1], "  ", sep=""), cex=0.7)

title("Mean Time vs Throughput", cex.main = 1,   font.main= 2)

#
# T-test Time means of different combination of factors
#
t.test(pbcSel(pbc.df, 0.01, "false", 15, "http")$Time, 
    pbcSel(pbc.df, 0.01, "false", 15, "https")$Time)

#
# T-tests
# Largest differences in mean Time
#
t.test(pbcSel(pbc.df, 0.01, "false", 15, "http")$Time, 
    pbcSel(pbc.df, 0.01, "false", 15, "https")$Time)

t.test(pbcSel(pbc.df, 0.01, "false", 4, "http")$Time, 
    pbcSel(pbc.df, 0.01, "false", 4, "https")$Time)

#
# Largest differences in mean Throughput
#
t.test(pbcSel(pbc.df, 0.05, "true", 15, "http")$PointsPerSec, 
    pbcSel(pbc.df, 0.05, "true", 15, "https")$PointsPerSec)

t.test(pbcSel(pbc.df, 0.05, "true", 4, "http")$PointsPerSec, 
    pbcSel(pbc.df, 0.05, "true", 4, "https")$PointsPerSec)

#
#T-test shows no significant difference between largest differences in time and largest difference in throughput, all results fall within the 95% confidence interval.
#

#
# T-test for largest difference between generalization
#
t.test(pbcSel(pbc.df, 0.01, "false", 15, "https")$PointsPerSec, 
    pbcSel(pbc.df, 0.05, "false", 15, "https")$PointsPerSec)

t.test(pbcSel(pbc.df, 0.01, "false", 15, "https")$Time, 
    pbcSel(pbc.df, 0.05, "false", 15, "https")$Time)

t.test(pbcSel(pbc.df, 0.01, "true", 15, "https")$PointsPerSec, 
    pbcSel(pbc.df, 0.05, "true", 15, "https")$PointsPerSec)

t.test(pbcSel(pbc.df, 0.01, "true", 15, "https")$Time, 
    pbcSel(pbc.df, 0.05, "true", 15, "https")$Time)

t.test(pbcSel(pbc.df, 0.01, "true", 4, "https")$PointsPerSec, 
    pbcSel(pbc.df, 0.05, "true", 4, "https")$PointsPerSec)

t.test(pbcSel(pbc.df, 0.01, "true", 4, "https")$Time, 
    pbcSel(pbc.df, 0.05, "true", 4, "https")$Time)

#
# Plots of Point vs Size in Http and Https
#
pbch.df<-rbind(pbc22.df, pbc23.df, pbc24.df, pbc25.df, pbc26.df, pbc27.df, pbc28.df, pbc29.df)
pbcs.df<-rbind(pbc14.df, pbc15.df, pbc16.df, pbc17.df, pbc18.df, pbc19.df, pbc20.df, pbc21.df)

plot(pbch.df$Points, pbch.df$Size, col="blue", pch=20, xlim=c(0,32500), ylim=c(0, 1100000))
plot(pbcs.df$Points, pbcs.df$Size, col="blue", pch=20, xlim=c(0,32500), ylim=c(0, 1100000))

#
#Plots of Points and Sizes in Http vs Https
#
plot((
          pbc.df$Points[pbc.df$Generalization==0.05 & pbc.df$Compression=="true" & pbc.df$Precision==15 & pbc.df
                  $Protocol=="http"]), 
    (pbc.df$Points[pbc.df$Generalization==0.05 & pbc.df$Compression=="true" & pbc.df$Precision==15 & pbc.df
                  $Protocol=="https"]), col="blue", pch=20, xlim=c(0,20000), ylim=c(0,20000), 
    ylab = "Http Points", xlab = "Https Points")


plot((
          pbc.df$Size[pbc.df$Generalization==0.05 & pbc.df$Compression=="true" & pbc.df$Precision==15 & pbc.df		                $Protocol=="http"]), 
    (pbc.df$Size[pbc.df$Generalization==0.05 & pbc.df$Compression=="true" & pbc.df$Precision==15 & pbc.df                  	$Protocol=="https"]), col="blue", pch=20, xlim=c(0,1200000), ylim=c(0,1200000), 
    ylab = "Http Size", xlab = "Https Size")

#
# Comparison between Size vs Time in Http and Https configurations
#
plot(pbc14.df$Size, pbc14.df$Time, col="blue", pch=20, xlim=c(0,620000), ylim=c(0,2.5), 
    ylab = "Time", xlab = "Size")
title("0.05, false, 15, Https", cex.main = 1,   font.main= 2, col.main= "blue")

plot(pbc22.df$Size, pbc22.df$Time, col="blue", pch=20, xlim=c(0,620000), ylim=c(0,2.5), 
    ylab = "Time", xlab = "Size")
title("0.05, false, 15, Http", cex.main = 1,   font.main= 2, col.main= "blue")

plot(pbc20.df$Size, pbc20.df$Time, col="blue", pch=20, xlim=c(0,620000), ylim=c(0,2.5), 
    ylab = "Time", xlab = "Size")
title("0.01, true, 4, Https", cex.main = 1,   font.main= 2, col.main= "blue")

plot(pbc29.df$Size, pbc29.df$Time, col="blue", pch=20, xlim=c(0,620000), ylim=c(0,2.5), 
    ylab = "Time", xlab = "Size")
title("0.01, true, 4, Http", cex.main = 1,   font.main= 2, col.main= "blue")

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
# Json vs TJson
#
jt.df<-read.table("json-vs-tjson.csv",header=T, sep=",")
plot(jt.df$jsize, jt.df$tsize)

#
# Bytes per geoms based on Precision and Generalization
#
mod<-aov((Size/Ngeoms)~Generalization*Precision, pbc.df)
summary(mod)
print(model.tables(mod, "means"), digits=3)

#
# Points per sec based on Size per point
#
mod<-lm(PointsPerSec~SizePerGeom, pbc.df)
summary(mod)
plot(pbc.df$SizePerGeom, pbc.df$PointsPerSec)
lines(mod$fitted, col="blue")

#
# Points per sec by Compression, Protocol and SizePerGeom
#
mod<-lm(PointsPerSec~Compression*Protocol+SizePerGeom, pbc.df)
summary(mod)
plot(pbc.df$SizePerGeom, pbc.df$PointsPerSec)
lines(mod$fitted, col="blue")
