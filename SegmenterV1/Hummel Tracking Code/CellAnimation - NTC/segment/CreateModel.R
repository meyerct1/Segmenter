#inputs:
#	1 - working directory
#	2 - csv file containing training data
#	3 - classification
#	4 - output file name

args <- commandArgs(TRUE)
setwd(args[[1]])
library('ada')
d<-read.csv(args[[2]])
d$MeanIntensity <- d$Intensity / d$Area

f <- formula(paste(args[[3]], " ~ 	Area + MajorAxisLength + 
									MinorAxisLength + Eccentricity + 
									ConvexArea + FilledArea + 
						 		  	EulerNumber + EquivDiameter + 
									Solidity + Perimeter + 
									Intensity + MeanIntensity"))

model <- ada(f,
			 data=d,
			 iter=1000,
			 type="discrete",
			 control=rpart.control(maxdepth=8))

save(model, file=args[[4]])
