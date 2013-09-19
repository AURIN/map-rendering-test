#
# analysis.R
#

#
# Loads, cleans and defines variables 
#
setwd("/usr/var/projects/aurin/git/map-rendering-test/test/result")   
source("functions.R")
pbc.df<-pbc.load()

#
# xtab to check that every combination of values have been tested
#
xtabs(~Precision+Generalization+Compression+Protocol, pbc.df)

#
# Distributtion graphs
par(mfrow=c(2,2))
png(file="/tmp/dist1.png",width=400,height=350)
hist(pbc.df$Time, n=100, main="Time")
dev.off()
png(file="/tmp/dist2.png",width=400,height=350)
hist(pbc.df$Ngeoms, n=100, main="N. of geometries")
dev.off()
png(file="/tmp/dist3.png",width=400,height=350)
hist(pbc.df$Size, n=100, main="Size")
dev.off()
png(file="/tmp/dist4.png",width=400,height=350)
hist(pbc.df$GeomsPerSec, n=100, main="Geometries per sec")
dev.off()

#
# 
# Json vs TJson
#
jt.df<-read.table("json-vs-tjson.csv",header=T, sep=",")
plot(jt.df$jsize, jt.df$tsize)

#
# Ngeoms by Size per geom
#
plot(pbc.df$Ngeoms, pbc.df$SizePerGeom, cex=0.1, xlab="N of geometries", ylab="Size per geometry")

df1<-subset(pbc.df, Generalization == "0.01" & Precision == 4)
df2<-subset(pbc.df, Generalization == "0.05" & Precision == 4)
df3<-subset(pbc.df, Generalization == "0.01" & Precision == 15)
df4<-subset(pbc.df, Generalization == "0.05" & Precision == 15)

par(mfrow=c(2,2))
plot(df1$Ngeoms, df1$SizePerGeom, cex=0.1, col="darkgreen", ylim=c(0,2000), xlim=c(0,1000), main="Gen 0.01, Prec 4")
plot(df2$Ngeoms, df2$SizePerGeom, cex=0.1, col="cyan", ylim=c(0,2000), xlim=c(0,1000), main="Gen 0.05, Prec 4")
plot(df3$Ngeoms, df3$SizePerGeom, cex=0.1, col="red", ylim=c(0,2000), xlim=c(0,1000), main="Gen 0.01, Prec 15")
plot(df4$Ngeoms, df4$SizePerGeom, cex=0.1, col="blue", ylim=c(0,2000), xlim=c(0,1000), main="Gen 0.05, Prec 15")

#
# Points per geom based on Generalization
#
mod<-aov(Npoints~Generalization, pbc.df)
summary(mod)
print(model.tables(mod, "means"), digits=3)

#
# Size per geom based on Precision and Generalization
#
mod<-aov(SizePerGeom~Generalization+Precision, pbc.df)
summary(mod)
print(model.tables(mod, "means"), digits=3)

#
# Geoms per sec by compression, protocol and size per geometry 
#
df1<-subset(pbc.df, Compression == "true" & Protocol == "http")
df2<-subset(pbc.df, Compression == "false" & Protocol == "http")
df3<-subset(pbc.df, Compression == "true" & Protocol == "https")
df4<-subset(pbc.df, Compression == "false" & Protocol == "https")

# Computes LM
modGeom<-lm(GeomsPerSec~Compression*Protocol+SizePerGeom, pbc.df)
summary(modGeom)

# Plots individual points by combination of factors
par(mfrow=c(2,2))
plot(df1$SizePerGeom, df1$GeomsPerSec, col="red", cex=0.2, ylim=c(0,2000), main="Compr, HTTP", xlab="Size per geom", ylab="Geoms per sec")
points(df1$SizePerGeom, predict(modGeom, df1), cex=0.2)
plot(df2$SizePerGeom, df2$GeomsPerSec, col="blue", cex=0.2, ylim=c(0,2000), main="NoCompr, HTTP", xlab="Size per geom", ylab="Geoms per sec")
points(df2$SizePerGeom, predict(modGeom, df2),  cex=0.2)
plot(df3$SizePerGeom, df3$GeomsPerSec, col="darkgreen", cex=0.2, ylim=c(0,2000), main="Compr, HTTPS", xlab="Size per geom", ylab="Geoms per sec")
points(df3$SizePerGeom, predict(modGeom, df3), cex=0.2)
plot(df4$SizePerGeom, df4$GeomsPerSec, col="darkviolet", cex=0.2, ylim=c(0,2000), main="NoCompr, HTTPS", xlab="Size per geom", ylab="Geoms per sec")
points(df4$SizePerGeom, predict(modGeom, df4), cex=0.2)

# Combinaes in one plot 
par(mfrow=c(1,1))
png(file="/tmp/lm.png",width=400,height=350)
plot(pbc.df$SizePerGeom, pbc.df$GeomsPerSec, col="black", cex=0.2, ylim=c(0,2000), main="Blue HTTP, Green HTTPS", xlab="Size per geom", ylab="Geoms per sec")
points(df1$SizePerGeom, predict(modGeom, df1), cex=0.2, col="lightblue")
points(df2$SizePerGeom, predict(modGeom, df2), cex=0.2, col="blue")
points(df3$SizePerGeom, predict(modGeom, df3), cex=0.2, col="darkgreen")
points(df4$SizePerGeom, predict(modGeom, df4), cex=0.2, col="green")
dev.off()

