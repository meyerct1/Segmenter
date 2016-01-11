#inputs:
#	1 - directory with csv file for image
#	2 - directory with classifier
#	3 - name of image
#	4 - classification

args <- commandArgs(TRUE)

setwd(args[[1]])
library('ada')
d <- read.csv(paste(args[[3]], ".csv", sep=""))
d$MeanIntensity <- d$Intensity / d$Area
load(paste(args[[2]], "/", "model", args[[4]], ".Rdata", sep=""));

output <- predict(model, newdata=d)

write.csv(output, file=paste(args[[3]] ,args[[4]], ".csv", sep=""))
