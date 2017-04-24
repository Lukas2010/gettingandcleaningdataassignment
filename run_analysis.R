# scriptname: run_analysis
## 2 testsets für jeweils 70% training und 30% test
## mergen und asuwerten
### subject_train enthält identifikationsnummer für testobjekte, x_train und y_ train enth
### 561 variablen, aufgeschrieben in X_test ! Für jedes object, beschrieben in subject_test ?
### length für subject_test und blockanzahl x_test müsste dann matchen
#### was is

## some basic start up stuff
library(dplyr)
rm(list=ls())
setwd("~/Documents/DataScience/Gettingandcleaningdata/Week4/Assignment")

#### STEP 1: acquiring data and adding variable and subjectidentifications

## read in the testfile with the subjectnumbers
subjectnumberstest <- read.table("UCIHARDataset/test/subject_test.txt")

## read in the variable names
variables <- read.table("UCIHARDataset/features.txt", stringsAsFactors=F)
changedvariables <- gsub("-","",tolower(variables$V2))

## read in the testfile with the data
testdata <- read.table("UCIHARDataset/test/X_test.txt")
## nimmt automatisch richtig auf, erstmal personen und daten matchen

## change variable names in the testfile
colnames(testdata) <- changedvariables

## add row with subjectidentification numbers
testdata$IDs <- subjectnumberstest$V1

## add row with the descriptive activity names
#testdata$activities <- read.table("UCIHARDataset/test/y_test.txt")

#### IMPORTANT: connect the subjects before merging the data !!!

## read in the trainingfile
trainingdata <- read.table("UCIHARDataset/train/X_train.txt")

## change the variablenames in the trainingfile
colnames(trainingdata) <- changedvariables

## retrieve subjectnumbers for trainingdataset
subjectnumberstrain <- read.table("UCIHARDataset/train/subject_train.txt", stringsAsFactors = F)

## add row with subject identification numbers
trainingdata$IDs <- subjectnumberstrain$V1

## add row with descriptive activity names
#activities2 <- read.table("UCIHARDataset/train/y_train.txt")
#trainingdata$activities <- activities2

#### STEP 2: Merging the Datasets

alldata <- rbind(testdata, trainingdata)

#### STEP 3: 

## Extracting the right measurements
#### !!! REGULAR EXPRESSION suchen um zu vereinfachen !
meanplace <- grep(("mean"), changedvariables)
stdplace <- grep(("std"), changedvariables)
meanstd <- c(meanplace, stdplace)
finaldata <- alldata[,c(meanstd,562)]


#### STEP 4: label with the right descripitve activity --> tomorrow

## createector with activitynumbers
testactivities <- read.table("UCIHARDataset/test/y_test.txt")
trainactivities <- read.table("UCIHARDataset/train/y_train.txt")
finaldata$activities <- c(testactivities$V1, trainactivities$V1)

## read in the activities labels
activitylabels <- read.table("UCIHARDataset/activity_labels.txt", stringsAsFactors = F)

## factorize the labels connected to the databases
finaldata$activities <- factor(finaldata$activities, labels = activitylabels$V2)
View(finaldata)

#### STEP 5: create appropriate descriptive variablenames
colNames = colnames(finaldata) 
colNames1 <- gsub("\\()", "", colNames)
colNames2 <- gsub("^(t)", "Time", colNames1)
colNames3 <- gsub("1(f)", "Frequency", colNames2)
colNames4 <- gsub("acc", "Acceleration", colNames3)
colNames5 <- gsub("[Gg]yro", "Gyro", colNames4)
colNames6 <- gsub("[Mm]ean", "Mean", colNames5)
colNames7 <- gsub("[Ss]td", "Standarddeviation", colNames6)
colNames8 <- gsub("x$", "x-axis", colNames7)
colNames9 <- gsub("y$", "y-axis", colNames8)
colNamesfinal <- gsub("z$", "z-axis", colNames9)

colnames(finaldata) <- colNamesfinal

#### STEP 6: creating a 2nd tidy dataset
finaldata2 <- finaldata %>% group_by(IDs, activities) %>% summarise_each(funs(mean), 1:87)
View(finaldata2)
write.table(finaldata2, file="datafile_gettingandcleaningdata.txt", row.names = FALSE)


