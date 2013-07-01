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

pbc30.df<-read.table("20130617results-e-512k-HTTP.pbc.30.csv",header=T, sep=",")
pbc31.df<-read.table("20130618results-e-512k-HTTP.pbc.31.csv",header=T, sep=",")

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

# Used only to double-check HTTP data 
# names(pbc30.df)<-cols
# names(pbc31.df)<-cols

pbc.df<-rbind(pbc14.df, pbc15.df, pbc16.df, pbc17.df, pbc18.df, pbc19.df, pbc20.df, pbc21.df)
pbch.df<-rbind(pbc22.df, pbc23.df, pbc24.df, pbc25.df, pbc26.df, pbc27.df, pbc28.df, pbc29.df)

# Data clean-up
pbc.df<-pbc.df[pbc.df$Npoints<25000,]
pbch.df<-pbch.df[pbch.df$Npoints<25000,]
pbc.df<-pbc.df[pbc.df$Time<10,]
pbch.df<-pbch.df[pbch.df$Time<10,]
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
by(cbind(pbc.df$Time, pbc.df$Size, pbc.df$PointsPerSec), pbc.df$Protocol, summary)


t.test(pbc.df$Time[pbc.df$Compression=="true"] ,pbc.df$Time[pbc.df$Compression=="false"], conf.level=0.99)

#
# Functions to compute means of Time and Throughput nad returns a label for it
#
pbcLabel<-function (df, gen, comp, prec, prot) {
  paste(gen, ifelse(comp=="true", "T", "F"), prec,  ifelse(prot=="http", "H", "S"), sep="")
}

pbcSel<-function (df, gen, comp, prec, prot) {
  subset(df, Generalization==gen & Compression==comp & Precision==prec & Protocol==prot)
}

compMeanTime<-function(df, gen, comp, prec, prot) {
  list(pbcLabel(df, gen, comp, prec, prot),
      mean(pbcSel(df, gen, comp, prec, prot)$Time)
  )
}

compMeanPPS<-function(df, gen, comp, prec, prot) {
  list(pbcLabel(df, gen, comp, prec, prot),
      mean(pbcSel(df, gen, comp, prec, prot)$PointsPerSec)
  )
}

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
# Plot Time vs Throughput
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

# Error in if (stderr < 10 * .Machine$double.eps * max(abs(mx), abs(my))) stop("data are essentially constant") : 
#   missing value where TRUE/FALSE needed
# In addition: Warning messages:
# 1: In mean.default(x) : argument is not numeric or logical: returning NA
# 2: In var(x) : NAs introduced by coercion
# 3: In mean.default(y) : argument is not numeric or logical: returning NA
# 4: In var(y) : NAs introduced by coercion




#Plot mean time and throughput against: Precision, Generalization, Compression and Protocol


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


#------------------------------------------------------------------------------------------------------------

#Plot median time and throughput against: Precision, Generalization, Compression and Protocol


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


#------------------------------------------------------------------------------------------------------------

#T-tests
#Largest differences in mean Time
t.test(pbcSel(pbc.df, 0.01, "false", 15, "http")$Time, 
    pbcSel(pbc.df, 0.01, "false", 15, "https")$Time)

t.test(pbcSel(pbc.df, 0.01, "false", 4, "http")$Time, 
    pbcSel(pbc.df, 0.01, "false", 4, "https")$Time)


#Largest differences in mean Throughput
t.test(pbcSel(pbc.df, 0.05, "true", 15, "http")$PointsPerSec, 
    pbcSel(pbc.df, 0.05, "true", 15, "https")$PointsPerSec)


t.test(pbcSel(pbc.df, 0.05, "true", 4, "http")$PointsPerSec, 
    pbcSel(pbc.df, 0.05, "true", 4, "https")$PointsPerSec)


#T-test shows no significant difference between largest differences in time and largest difference in throughput, all results fall within the 95% confidence interval.



#T-test for largest difference between generalization
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



#Generate histograms of Throughput and Time for each configuration, limited to less than 2 seconds.

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

#
#Size vs Time and Size vs Throughput distributions
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


#Plots of Point vs Size in Http and Https

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



#Comparison between Size vs Time in Http and Https configurations
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