setwd("/usr/var/projects/aurin/git/map-rendering-test/test/result")
pbc.df<-read.table("pbc.csv",header=T, sep=",")

pbc.mod=PointsPerSec~Size+Npoints+Type+Precision+Dataset+Generalization+Compression+Npoints+Ngeoms
pbc.modP=Npoints~Generalization+Ngeoms
pbc.modS=Size~Precision+Compression+Npoints+Ngeoms
pbc.modT=PointsPerSec~Size+Npoints


# pairs(pbc.modP, pbc.df)
#plot(pbc.df$Npoints[pbc.df$Npoints<10000], pbc.df$PointsPerSec[pbc.df$Npoints<10000])
#plot(pbc.df$Size, pbc.df$PointsPerSec)
#plot(pbc.df$Npoints, pbc.df$Time)
#plot(pbc.df$Size, pbc.df$Time)
plot(pbc.df$Npoints[pbc.df$Npoints<2000], pbc.df$PointsPerSec[pbc.df$Npoints<2000])
hist(pbc.df$Npoints)
avg(pbc.df$Npoints)
hist(pbc.df$Npoints[pbc.df$Npoints<10000])

