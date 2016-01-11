#inputs:
#	1 - directory containing csv file, and where the output will be
#	2 - csv file containing training data
#	3 - classification (nucleus or under or ...)
#	4 - output file name

args <- commandArgs(TRUE)
setwd(args[[1]])

library('ada')
d<-read.csv(args[[2]])
d$MeanIntensity <- d$Intensity / d$Area

n <- nrow(d)
set.seed(100)
ind <- sample(1:n)

trainval <- ceiling(n * .5)
testval <- ceiling(n * .3)
train <- d[ind[1:trainval],]
test <- d[ind[(trainval+1):(trainval+testval)],]
valid <- d[ind[(trainval+testval+1):n],]

f <- formula(paste(args[[3]], " ~ 	Area + MajorAxisLength + 
									MinorAxisLength + Eccentricity + 
									ConvexArea + FilledArea + 
						 		  	EulerNumber + EquivDiameter + 
									Solidity + Perimeter + 
									Intensity + MeanIntensity"))

model <- ada(	f,
				data=d,
				test.x=test[,-17],
				test.y=test[,17],
				iter=1000,
				type="discrete",
				control=rpart.control(maxdepth=8))

model <- addtest(model, valid[,-17], valid[,17])

save(model, file=args[[4]])
