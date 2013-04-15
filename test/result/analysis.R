setwd("/usr/var/projects/aurin/git/map-rendering-test/test/result")
pbc.df<-read.table("pbc.csv",header=T, sep=",")
pbc.df<-read.table("pbc-128kbps.csv",header=T, sep=",")
#pbc.df<-pbc.df[-c(2,3,83,4,272,333),] # Gets rid of outliers
#pbc.df<-pbc.df[pbc.df$Npoints < 25000,] # Gets rid of extreme values
pbc.mod=PointsPerSec~Size+Npoints+Type+Precision+Dataset+Generalization+Compression+Npoints+Ngeoms
pbc.modP=Npoints~Generalization+Ngeoms
pbc.modS=Size~Precision+Compression+Npoints+Ngeoms
pbc.modT=PointsPerSec~Npoints
pbc.modTlog=PointsPerSec~log(Npoints)

pbc.modT.lm= lm(pbc.modT, pbc.df)
pbc.modTlog.lm= lm(pbc.modTlog, pbc.df)


# pairs(pbc.modP, pbc.df)
#plot(pbc.df$Npoints[pbc.df$Npoints<10000], pbc.df$PointsPerSec[pbc.df$Npoints<10000])
#plot(pbc.df$Size, pbc.df$PointsPerSec)
#plot(pbc.df$Size, pbc.df$Time)
#plot(pbc.df$Npoints, pbc.df$PointsPerSec)

par(mfrow = c(3, 1))
plot(pbc.df$Size, pbc.df$PointsPerSec, col="green")

plot(pbc.df$Npoints, pbc.df$PointsPerSec, col="green")
points(pbc.df$Npoints, fitted(pbc.modT.lm))
summary(pbc.modT)
plot(pbc.df$Npoints, pbc.df$PointsPerSec, col="green")
points(pbc.df$Npoints, fitted(pbc.modTlog.lm))
summary(pbc.modTlog)



par(mfrow = c(2, 2))
plot(pbc.modT.lm)

par(mfrow = c(2, 2))
plot(pbc.modTlog.lm)

mean(pbc.df$PointsPerSec)
