#http://www.stat.lsa.umich.edu/~gmichail/ada_final.pdf
#http://cran.r-project.org/web/packages/ada/index.html

setwd('~/CellAnimation/segmentation/segment')

d <- read.csv('kernel01.csv')

library('ada')

d$MeanIntensity <- d$Intensity/d$Area

model.nuclei <- ada(nucleus ~ 	Area + MajorAxisLength + 
								MinorAxisLength + Eccentricity + 
								ConvexArea + FilledArea + 
								EulerNumber + EquivDiameter + 
								Solidity + Perimeter + 
								Intensity + MeanIntensity,
                    data=d,
                    iter=1000,
                    type="discrete",
                    control=rpart.control(maxdepth=8))
                    
varplot(model.nuclei)
text(0.003, 10.5, "Nuclei Prediction")

pairs(model.nuclei,d, maxvar=3)

t1 <- model.nuclei$model$trees[[1000]]
names(t1)
t1
t1$frame
t1$cptable

model.predivision <- ada(predivision ~ 	
							Area + 				MajorAxisLength + 
							MinorAxisLength + 	Eccentricity + 
							ConvexArea + 		FilledArea + 
							EulerNumber + 		EquivDiameter + 
							Solidity + 			Perimeter + 
							Intensity + 		MeanIntensity,
                         data=d,
                         iter=1000,
                         type="discrete",
                         control=rpart.control(maxdepth=8))
