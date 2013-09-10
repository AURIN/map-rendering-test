#
# Etc....
#

#
# Plots GeoJSON vs TopoJSON size
#
setwd("/usr/var/projects/aurin/git/map-rendering-test/test/result")   
jt.df<-read.table("json-vs-tjson.csv",header=T, sep=",")


#
# Plots mean time and throughput against: Precision, Generalization, Compression and Protocol
#
mTH05T15<-mean(pbc.df$Time[pbc.df$Generalization==0.05 & pbc.df$Compression=="true" & pbc.df$Precision==15 & pbc.df$Protocol=="http"])
mTH05F15<-mean(pbc.df$Time[pbc.df$Generalization==0.05 & pbc.df$Compression=="false" & pbc.df$Precision==15 & pbc.df$Protocol=="http"])
mTH05T04<-mean(pbc.df$Time[pbc.df$Generalization==0.05 & pbc.df$Compression=="true" & pbc.df$Precision==4 & pbc.df$Protocol=="http"])
mTH05F04<-mean(pbc.df$Time[pbc.df$Generalization==0.05 & pbc.df$Compression=="false" & pbc.df$Precision==4 & pbc.df$Protocol=="http"])
mTH01T15<-mean(pbc.df$Time[pbc.df$Generalization==0.01 & pbc.df$Compression=="true" & pbc.df$Precision==15 & pbc.df$Protocol=="http"])
mTH01F15<-mean(pbc.df$Time[pbc.df$Generalization==0.01 & pbc.df$Compression=="false" & pbc.df$Precision==15 & pbc.df$Protocol=="http"])
mTH01T04<-mean(pbc.df$Time[pbc.df$Generalization==0.01 & pbc.df$Compression=="true" & pbc.df$Precision==4 & pbc.df$Protocol=="http"])
mTH01F04<-mean(pbc.df$Time[pbc.df$Generalization==0.01 & pbc.df$Compression=="false" & pbc.df$Precision==4 & pbc.df$Protocol=="http"])

mTS05T15<-mean(pbc.df$Time[pbc.df$Generalization==0.05 & pbc.df$Compression=="true" & pbc.df$Precision==15 & pbc.df$Protocol=="https"])
mTS05F15<-mean(pbc.df$Time[pbc.df$Generalization==0.05 & pbc.df$Compression=="false" & pbc.df$Precision==15 & pbc.df$Protocol=="https"])
mTS05T04<-mean(pbc.df$Time[pbc.df$Generalization==0.05 & pbc.df$Compression=="true" & pbc.df$Precision==4 & pbc.df$Protocol=="https"])
mTS05F04<-mean(pbc.df$Time[pbc.df$Generalization==0.05 & pbc.df$Compression=="false" & pbc.df$Precision==4 & pbc.df$Protocol=="https"])
mTS01T15<-mean(pbc.df$Time[pbc.df$Generalization==0.01 & pbc.df$Compression=="true" & pbc.df$Precision==15 & pbc.df$Protocol=="https"])
mTS01F15<-mean(pbc.df$Time[pbc.df$Generalization==0.01 & pbc.df$Compression=="false" & pbc.df$Precision==15 & pbc.df$Protocol=="https"])
mTS01T04<-mean(pbc.df$Time[pbc.df$Generalization==0.01 & pbc.df$Compression=="true" & pbc.df$Precision==4 & pbc.df$Protocol=="https"])
mTS01F04<-mean(pbc.df$Time[pbc.df$Generalization==0.01 & pbc.df$Compression=="false" & pbc.df$Precision==4 & pbc.df$Protocol=="https"])

mPH05T15<-mean(pbc.df$PointsPerSec[pbc.df$Generalization==0.05 & pbc.df$Compression=="true" & pbc.df$Precision==15 & pbc.df$Protocol=="http"])
mPH05F15<-mean(pbc.df$PointsPerSec[pbc.df$Generalization==0.05 & pbc.df$Compression=="false" & pbc.df$Precision==15 & pbc.df$Protocol=="http"])
mPH05T04<-mean(pbc.df$PointsPerSec[pbc.df$Generalization==0.05 & pbc.df$Compression=="true" & pbc.df$Precision==4 & pbc.df$Protocol=="http"])
mPH05F04<-mean(pbc.df$PointsPerSec[pbc.df$Generalization==0.05 & pbc.df$Compression=="false" & pbc.df$Precision==4 & pbc.df$Protocol=="http"])
mPH01T15<-mean(pbc.df$PointsPerSec[pbc.df$Generalization==0.01 & pbc.df$Compression=="true" & pbc.df$Precision==15 & pbc.df$Protocol=="http"])
mPH01F15<-mean(pbc.df$PointsPerSec[pbc.df$Generalization==0.01 & pbc.df$Compression=="false" & pbc.df$Precision==15 & pbc.df$Protocol=="http"])
mPH01T04<-mean(pbc.df$PointsPerSec[pbc.df$Generalization==0.01 & pbc.df$Compression=="true" & pbc.df$Precision==4 & pbc.df$Protocol=="http"])
mPH01F04<-mean(pbc.df$PointsPerSec[pbc.df$Generalization==0.01 & pbc.df$Compression=="false" & pbc.df$Precision==4 & pbc.df$Protocol=="http"])

mPS05T15<-mean(pbc.df$PointsPerSec[pbc.df$Generalization==0.05 & pbc.df$Compression=="true" & pbc.df$Precision==15 & pbc.df$Protocol=="https"])
mPS05F15<-mean(pbc.df$PointsPerSec[pbc.df$Generalization==0.05 & pbc.df$Compression=="false" & pbc.df$Precision==15 & pbc.df$Protocol=="https"])
mPS05T04<-mean(pbc.df$PointsPerSec[pbc.df$Generalization==0.05 & pbc.df$Compression=="true" & pbc.df$Precision==4 & pbc.df$Protocol=="https"])
mPS05F04<-mean(pbc.df$PointsPerSec[pbc.df$Generalization==0.05 & pbc.df$Compression=="false" & pbc.df$Precision==4 & pbc.df$Protocol=="https"])
mPS01T15<-mean(pbc.df$PointsPerSec[pbc.df$Generalization==0.01 & pbc.df$Compression=="true" & pbc.df$Precision==15 & pbc.df$Protocol=="https"])
mPS01F15<-mean(pbc.df$PointsPerSec[pbc.df$Generalization==0.01 & pbc.df$Compression=="false" & pbc.df$Precision==15 & pbc.df$Protocol=="https"])
mPS01T04<-mean(pbc.df$PointsPerSec[pbc.df$Generalization==0.01 & pbc.df$Compression=="true" & pbc.df$Precision==4 & pbc.df$Protocol=="https"])
mPS01F04<-mean(pbc.df$PointsPerSec[pbc.df$Generalization==0.01 & pbc.df$Compression=="false" & pbc.df$Precision==4 & pbc.df$Protocol=="https"])

my = c(mTH05T15, mTH05F15, mTH05T04, mTH05F04, mTH01T15, mTH01F15, mTH01T04, mTH01F04, mTS05T15, mTS05F15, mTS05T04, mTS05F04, mTS01T15, mTS01F15, mTS01T04, mTS01F04)
mx = c(mPH05T15, mPH05F15, mPH05T04, mPH05F04, mPH01T15, mPH01F15, mPH01T04, mPH01F04, mPS05T15, mPS05F15, mPS05T04, mPS05F04, mPS01T15, mPS01F15, mPS01T04, mPS01F04)
mlabs = c("H05T15", "H05F15", "H05T04", "H05F04", "H01T15", "H01F15", "H01T04", "H01F04", "S05T15", "S05F15", "S05T04", "S05F04", "S01T15", "S01F15", "S01T04", "S01F04") 

plot(mx, my, ylab = "Time (s)", xlab = "Throughput (pts/s)", col="blue")
title("Mean Time vs Throughput", cex.main = 1,   font.main= 2, col.main= "blue")

require(maptools)
pointLabel(mx, my, labels = paste("  ", mlabs, "  ", sep=""), cex=0.7)

#
# Plot median time and throughput against: Precision, Generalization, Compression and Protocol
#

dTH05T15<-median(pbc.df$Time[pbc.df$Generalization==0.05 & pbc.df$Compression=="true" & pbc.df$Precision==15 & pbc.df$Protocol=="http"])
dTH05F15<-median(pbc.df$Time[pbc.df$Generalization==0.05 & pbc.df$Compression=="false" & pbc.df$Precision==15 & pbc.df$Protocol=="http"])
dTH05T04<-median(pbc.df$Time[pbc.df$Generalization==0.05 & pbc.df$Compression=="true" & pbc.df$Precision==4 & pbc.df$Protocol=="http"])
dTH05F04<-median(pbc.df$Time[pbc.df$Generalization==0.05 & pbc.df$Compression=="false" & pbc.df$Precision==4 & pbc.df$Protocol=="http"])
dTH01T15<-median(pbc.df$Time[pbc.df$Generalization==0.01 & pbc.df$Compression=="true" & pbc.df$Precision==15 & pbc.df$Protocol=="http"])
dTH01F15<-median(pbc.df$Time[pbc.df$Generalization==0.01 & pbc.df$Compression=="false" & pbc.df$Precision==15 & pbc.df$Protocol=="http"])
dTH01T04<-median(pbc.df$Time[pbc.df$Generalization==0.01 & pbc.df$Compression=="true" & pbc.df$Precision==4 & pbc.df$Protocol=="http"])
dTH01F04<-median(pbc.df$Time[pbc.df$Generalization==0.01 & pbc.df$Compression=="false" & pbc.df$Precision==4 & pbc.df$Protocol=="http"])

dTS05T15<-median(pbc.df$Time[pbc.df$Generalization==0.05 & pbc.df$Compression=="true" & pbc.df$Precision==15 & pbc.df$Protocol=="https"])
dTS05F15<-median(pbc.df$Time[pbc.df$Generalization==0.05 & pbc.df$Compression=="false" & pbc.df$Precision==15 & pbc.df$Protocol=="https"])
dTS05T04<-median(pbc.df$Time[pbc.df$Generalization==0.05 & pbc.df$Compression=="true" & pbc.df$Precision==4 & pbc.df$Protocol=="https"])
dTS05F04<-median(pbc.df$Time[pbc.df$Generalization==0.05 & pbc.df$Compression=="false" & pbc.df$Precision==4 & pbc.df$Protocol=="https"])
dTS01T15<-median(pbc.df$Time[pbc.df$Generalization==0.01 & pbc.df$Compression=="true" & pbc.df$Precision==15 & pbc.df$Protocol=="https"])
dTS01F15<-median(pbc.df$Time[pbc.df$Generalization==0.01 & pbc.df$Compression=="false" & pbc.df$Precision==15 & pbc.df$Protocol=="https"])
dTS01T04<-median(pbc.df$Time[pbc.df$Generalization==0.01 & pbc.df$Compression=="true" & pbc.df$Precision==4 & pbc.df$Protocol=="https"])
dTS01F04<-median(pbc.df$Time[pbc.df$Generalization==0.01 & pbc.df$Compression=="false" & pbc.df$Precision==4 & pbc.df$Protocol=="https"])

dPH05T15<-median(pbc.df$PointsPerSec[pbc.df$Generalization==0.05 & pbc.df$Compression=="true" & pbc.df$Precision==15 & pbc.df$Protocol=="http"])
dPH05F15<-median(pbc.df$PointsPerSec[pbc.df$Generalization==0.05 & pbc.df$Compression=="false" & pbc.df$Precision==15 & pbc.df$Protocol=="http"])
dPH05T04<-median(pbc.df$PointsPerSec[pbc.df$Generalization==0.05 & pbc.df$Compression=="true" & pbc.df$Precision==4 & pbc.df$Protocol=="http"])
dPH05F04<-median(pbc.df$PointsPerSec[pbc.df$Generalization==0.05 & pbc.df$Compression=="false" & pbc.df$Precision==4 & pbc.df$Protocol=="http"])
dPH01T15<-median(pbc.df$PointsPerSec[pbc.df$Generalization==0.01 & pbc.df$Compression=="true" & pbc.df$Precision==15 & pbc.df$Protocol=="http"])
dPH01F15<-median(pbc.df$PointsPerSec[pbc.df$Generalization==0.01 & pbc.df$Compression=="false" & pbc.df$Precision==15 & pbc.df$Protocol=="http"])
dPH01T04<-median(pbc.df$PointsPerSec[pbc.df$Generalization==0.01 & pbc.df$Compression=="true" & pbc.df$Precision==4 & pbc.df$Protocol=="http"])
dPH01F04<-median(pbc.df$PointsPerSec[pbc.df$Generalization==0.01 & pbc.df$Compression=="false" & pbc.df$Precision==4 & pbc.df$Protocol=="http"])

dPS05T15<-median(pbc.df$PointsPerSec[pbc.df$Generalization==0.05 & pbc.df$Compression=="true" & pbc.df$Precision==15 & pbc.df$Protocol=="https"])
dPS05F15<-median(pbc.df$PointsPerSec[pbc.df$Generalization==0.05 & pbc.df$Compression=="false" & pbc.df$Precision==15 & pbc.df$Protocol=="https"])
dPS05T04<-median(pbc.df$PointsPerSec[pbc.df$Generalization==0.05 & pbc.df$Compression=="true" & pbc.df$Precision==4 & pbc.df$Protocol=="https"])
dPS05F04<-median(pbc.df$PointsPerSec[pbc.df$Generalization==0.05 & pbc.df$Compression=="false" & pbc.df$Precision==4 & pbc.df$Protocol=="https"])
dPS01T15<-median(pbc.df$PointsPerSec[pbc.df$Generalization==0.01 & pbc.df$Compression=="true" & pbc.df$Precision==15 & pbc.df$Protocol=="https"])
dPS01F15<-median(pbc.df$PointsPerSec[pbc.df$Generalization==0.01 & pbc.df$Compression=="false" & pbc.df$Precision==15 & pbc.df$Protocol=="https"])
dPS01T04<-median(pbc.df$PointsPerSec[pbc.df$Generalization==0.01 & pbc.df$Compression=="true" & pbc.df$Precision==4 & pbc.df$Protocol=="https"])
dPS01F04<-median(pbc.df$PointsPerSec[pbc.df$Generalization==0.01 & pbc.df$Compression=="false" & pbc.df$Precision==4 & pbc.df$Protocol=="https"])

my = c(dTH05T15, dTH05F15, dTH05T04, dTH05F04, dTH01T15, dTH01F15, dTH01T04, dTH01F04, dTS05T15, dTS05F15, dTS05T04, dTS05F04, dTS01T15,  
    dTS01F15, dTS01T04, dTS01F04)
mx = c(dPH05T15, dPH05F15, dPH05T04, dPH05F04, dPH01T15, dPH01F15, dPH01T04, dPH01F04, dPS05T15, dPS05F15, dPS05T04, dPS05F04, dPS01T15,  
    dPS01F15, dPS01T04, dPS01F04)
mlabs = c("H05T15", "H05F15", "H05T04", "H05F04", "H01T15", "H01F15", "H01T04", "H01F04", "S05T15", "S05F15", "S05T04", "S05F04", "S01T15",  
    "S01F15", "S01T04", "S01F04") 

plot(mx, my, ylab = "Time (s)", xlab = "Throughput (pts/s)", col="blue")
title("Median Time vs Throughput", cex.main = 1,   font.main= 2, col.main= "blue")

require(maptools)
pointLabel(mx, my, labels = paste("  ", mlabs, "  ", sep=""), cex=0.7)

#
# Size vs Time and Size vs Throughput distributions
#

plot(pbc14.df$Size, pbc14.df$Time, col="blue", pch=20, xlim=c(0,2500000), ylim=c(0, 9.5))
plot(pbc15.df$Size, pbc15.df$Time, col="blue", pch=20, xlim=c(0,2500000), ylim=c(0, 9.5))
plot(pbc16.df$Size, pbc16.df$Time, col="blue", pch=20, xlim=c(0,2500000), ylim=c(0, 9.5))
plot(pbc17.df$Size, pbc17.df$Time, col="blue", pch=20, xlim=c(0,2500000), ylim=c(0, 9.5))
plot(pbc18.df$Size, pbc18.df$Time, col="blue", pch=20, xlim=c(0,2500000), ylim=c(0, 9.5))
plot(pbc19.df$Size, pbc19.df$Time, col="blue", pch=20, xlim=c(0,2500000), ylim=c(0, 9.5))
plot(pbc20.df$Size, pbc20.df$Time, col="blue", pch=20, xlim=c(0,2500000), ylim=c(0, 9.5))
plot(pbc21.df$Size, pbc21.df$Time, col="blue", pch=20, xlim=c(0,2500000), ylim=c(0, 9.5))
plot(pbc22.df$Size, pbc22.df$Time, col="blue", pch=20, xlim=c(0,2500000), ylim=c(0, 9.5))
plot(pbc23.df$Size, pbc23.df$Time, col="blue", pch=20, xlim=c(0,2500000), ylim=c(0, 9.5))
plot(pbc24.df$Size, pbc24.df$Time, col="blue", pch=20, xlim=c(0,2500000), ylim=c(0, 9.5))
plot(pbc25.df$Size, pbc25.df$Time, col="blue", pch=20, xlim=c(0,2500000), ylim=c(0, 9.5))
plot(pbc26.df$Size, pbc26.df$Time, col="blue", pch=20, xlim=c(0,2500000), ylim=c(0, 9.5))
plot(pbc27.df$Size, pbc27.df$Time, col="blue", pch=20, xlim=c(0,2500000), ylim=c(0, 9.5))
plot(pbc28.df$Size, pbc28.df$Time, col="blue", pch=20, xlim=c(0,2500000), ylim=c(0, 9.5))
plot(pbc29.df$Size, pbc29.df$Time, col="blue", pch=20, xlim=c(0,2500000), ylim=c(0, 9.5))

plot(pbc14.df$Size, pbc14.df$PointsPerSec, col="blue", pch=20, xlim=c(0,2500000), ylim=c(0, 25500))
plot(pbc15.df$Size, pbc15.df$PointsPerSec, col="blue", pch=20, xlim=c(0,2500000), ylim=c(0, 25500))
plot(pbc16.df$Size, pbc16.df$PointsPerSec, col="blue", pch=20, xlim=c(0,2500000), ylim=c(0, 25500))
plot(pbc17.df$Size, pbc17.df$PointsPerSec, col="blue", pch=20, xlim=c(0,2500000), ylim=c(0, 25500))
plot(pbc18.df$Size, pbc18.df$PointsPerSec, col="blue", pch=20, xlim=c(0,2500000), ylim=c(0, 25500))
plot(pbc19.df$Size, pbc19.df$PointsPerSec, col="blue", pch=20, xlim=c(0,2500000), ylim=c(0, 25500))
plot(pbc20.df$Size, pbc20.df$PointsPerSec, col="blue", pch=20, xlim=c(0,2500000), ylim=c(0, 25500))
plot(pbc21.df$Size, pbc21.df$PointsPerSec, col="blue", pch=20, xlim=c(0,2500000), ylim=c(0, 25500))
plot(pbc22.df$Size, pbc22.df$PointsPerSec, col="blue", pch=20, xlim=c(0,2500000), ylim=c(0, 25500))
plot(pbc23.df$Size, pbc23.df$PointsPerSec, col="blue", pch=20, xlim=c(0,2500000), ylim=c(0, 25500))
plot(pbc24.df$Size, pbc24.df$PointsPerSec, col="blue", pch=20, xlim=c(0,2500000), ylim=c(0, 25500))
plot(pbc25.df$Size, pbc25.df$PointsPerSec, col="blue", pch=20, xlim=c(0,2500000), ylim=c(0, 25500))
plot(pbc26.df$Size, pbc26.df$PointsPerSec, col="blue", pch=20, xlim=c(0,2500000), ylim=c(0, 25500))
plot(pbc27.df$Size, pbc27.df$PointsPerSec, col="blue", pch=20, xlim=c(0,2500000), ylim=c(0, 25500))
plot(pbc28.df$Size, pbc28.df$PointsPerSec, col="blue", pch=20, xlim=c(0,2500000), ylim=c(0, 25500))
plot(pbc29.df$Size, pbc29.df$PointsPerSec, col="blue", pch=20, xlim=c(0,2500000), ylim=c(0, 25500))

#
# Generates histograms of Throughput and Time for each configuration, limited to less than 2 seconds.
#
hist(pbc22.df$PointsPerSec, breaks=100)
hist(pbc23.df$PointsPerSec, breaks=100)
hist(pbc24.df$PointsPerSec, breaks=100)
hist(pbc25.df$PointsPerSec, breaks=100)
hist(pbc26.df$PointsPerSec, breaks=100)
hist(pbc27.df$PointsPerSec, breaks=100)
hist(pbc28.df$PointsPerSec, breaks=100)
hist(pbc29.df$PointsPerSec, breaks=100)

hist(subset(pbc22.df, Time<1.5)$Time, breaks=100)
hist(subset(pbc23.df, Time<1.5)$Time, breaks=100)
hist(subset(pbc24.df, Time<1.5)$Time, breaks=100)
hist(subset(pbc25.df, Time<1.5)$Time, breaks=100)
hist(subset(pbc26.df, Time<1.5)$Time, breaks=100)
hist(subset(pbc27.df, Time<1.5)$Time, breaks=100)
hist(subset(pbc28.df, Time<1.5)$Time, breaks=100)
hist(subset(pbc29.df, Time<1.5)$Time, breaks=100)



