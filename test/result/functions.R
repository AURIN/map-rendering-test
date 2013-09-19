#
# General functions
#

#
# Loads PBC data from directory dir and returns a data frame
#
pbc.load<-function() {
  
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
  
  pbc.df<-rbind(pbc14.df, pbc15.df, pbc16.df, pbc17.df, pbc18.df, pbc19.df, pbc20.df, pbc21.df)
  pbch.df<-rbind(pbc22.df, pbc23.df, pbc24.df, pbc25.df, pbc26.df, pbc27.df, pbc28.df, pbc29.df)

  # Data clean-up
  print(sum(xtabs(~Compression+Precision, rbind(pbc.df, pbch.df))))
  pbc.df<-subset(pbc.df, Npoints < 25000 & Ngeoms < 400 & Time < 4)
  pbch.df<-subset(pbch.df, Npoints < 25000 & Ngeoms < 400 & Time < 4)
  pbch.df$Protocol<-"http"
  pbc.df$Protocol<-"https"
  pbc.df<-rbind(pbc.df, pbch.df)
  print(sum(xtabs(~Compression+Precision, pbc.df)))
  
  # Recodification of variables as factors
  pbc.df$Precision<-as.factor(pbc.df$Precision) 
  pbc.df$Generalization<-as.factor(pbc.df$Generalization)
  pbc.df$Compression<-as.factor(pbc.df$Compression)
  pbc.df$Protocol<-as.factor(pbc.df$Protocol)
  
  # Defines new variables
  pbc.df$SizePerGeom<-(pbc.df$Size / pbc.df$Ngeoms)
  pbc.df$GeomsPerSec<-(pbc.df$Ngeoms / pbc.df$Time) 
  pbc.df$SizePerPoint<-(pbc.df$Size / pbc.df$Npoints)

  pbc.df
}

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
# Definition of analytical functions
#
pbcLm<-function (df, models) {
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
