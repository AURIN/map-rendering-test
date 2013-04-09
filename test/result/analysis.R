setwd("/usr/var/projects/aurin/git/map-rendering-test/test/result")
pbc.df<-read.table("pbc.csv",header=T, sep=",")
pbc.mod=PointsPerSec~Size+Npoints+Type+Precision+Dataset+Generalization+Compression+Npoints+Ngeoms
pairs(pbc.mod, pbc.df)



