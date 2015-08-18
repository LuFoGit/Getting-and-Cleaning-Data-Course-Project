# getwd()
#[1] "/home/lufolg"
#> source("workspace/03P01/run_analysis.R")
# run_analysis.R()

####################################################################
## Getting and Cleaning Data Course Project
## "Human+Activity+Recognition+Using+Smartphones" 
## Function: run_analysis.R
## LuFoLG 2015-08-18
##

run_analysis.R <- function() {
  ##
  ##  You should create one R script called run_analysis.R that does the following. 
  ##
  ## 1 Merge the training and the test sets to create one data set.
  ##
  
  ## 1.1 download and unzip data file, prepare local working directory
  
  print("## 1.1 Download and unzip")
  setwd("~/workspace/03P01")
  
  download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip", 
                "./Dataset.zip", 
                "wget", 
                quiet = TRUE, 
                mode = "w",
                cacheOK = TRUE,
                extra = getOption("download.file.extra"))
  
  unzip("./Dataset.zip")
  
  ## 1.2 read data files
  #  1.2.1 read helper files
  #  1.2.1.1 given column names
  print("## 1.2 read helper files")
  features<-read.table("UCI HAR Dataset/features.txt", as.is=TRUE )
  #                                                    ^^^^^^^^^^ to avoid factor
  dim(features)
  #[1] 561   2
  
  #  1.2.1.2 given activity names
  activity<-read.table("UCI HAR Dataset/activity_labels.txt", as.is=TRUE )
  #                                                           ^^^^^^^^^^ to avoid factor
  
  ## TEST DATA ##
  ## 1.2.2 read test data
  print("## 1.2 read test data")
  testx<-read.table("UCI HAR Dataset/test/X_test.txt")
  dim(testx)
  #[1] 2947  561
  ## read testers
  testy<-read.table("UCI HAR Dataset/test/y_test.txt")
  dim(testy)
  #[1] 2947  1
  ## read subjects
  tests<-read.table("UCI HAR Dataset/test/subject_test.txt")
  dim(tests)
  #[1] 2947  1
  
  # add y to table x
  # attention, use column numbering, do not give column names as this spoils rbind later on (?)
  testx[,562] <- "test"
  testx[,563] <- tests[,1]
  testx[,564] <- testy[,1]
  dim(testx)
  #[1] 2947  564
  
  
  
  ## TRAIN DATA ##
  ## 1.2.4 read train data
  print("## 1.2 read train data")
  trainx<-read.table("UCI HAR Dataset/train/X_train.txt")
  dim(trainx)
  #[1] 7352  561
  ## read trainers
  trainy<-read.table("UCI HAR Dataset/train/y_train.txt")
  dim(trainy)
  #[1] 7352    1
  ## read subjects
  trains<-read.table("UCI HAR Dataset/train/subject_train.txt")
  dim(trains)
  #[1] 7352    1
  
  # add y to table x 
  # attention, same numbers as in test data for that rbind will succeed
  trainx[,562] <- "train"
  trainx[,563] <- trains[,1]
  trainx[,564] <- trainy[,1]
  dim(trainx)
  #[1] 7352  564
  
  ## 1.3 Create one daza set, here add both dataframes vertically (UNION ALL)
  ## by now the marriage, test and train = tnt1 of 1st action
  print("## 1.3 rbind and rename")
  tnt1 <- rbind(trainx[], testx[])
  
  ## 1.4 rename colum names in x table
  # these are not final names, but to keep track of columns during development...
  names(tnt1) <- features[,2]
  names(tnt1)[562] <- "Source"
  names(tnt1)[563] <- "Subject"
  names(tnt1)[564] <- "Activity"
  
  ## 1.5 clean up memory
  rm(testx)
  rm(testy)
  rm(tests)
  rm(trainx)
  rm(trainy)
  rm(trains)
  gc()
  
  print("## 2 extract measures")
  ##
  ## 2 Extract only the measurements on the mean and standard deviation for each measurement. 
  ##
  # first find column names [Mm]ean or [Ss]td
  #str(features)
  #'data.frame':	561 obs. of  2 variables:
  # $ V1: int  1 2 3 4 5 6 7 8 9 10 ...
  # $ V2: chr  "tBodyAcc-mean()-X" "tBodyAcc-mean()-Y" "tBodyAcc-mean()-Z" "tBodyAcc-std()-X" ...
  features_to_keep<-features[(grepl("([mM]ean|[sS]td)\\(", features[,2])),]
  #str(features_to_keep)
  #'data.frame':	66 obs. of  2 variables:
  # $ V1: int  1 2 3 4 5 6 41 42 43 44 ...
  # $ V2: chr  "tBodyAcc-mean()-X" "tBodyAcc-mean()-Y" "tBodyAcc-mean()-Z" "tBodyAcc-std()-X" ...
  features_not_to_keep<-features[!(grepl("([mM]ean|[sS]td)\\(", features[,2])),]
  #str(features_not_to_keep)
  #'data.frame':	495 obs. of  2 variables:
  # $ V1: int  7 8 9 10 11 12 13 14 15 16 ...
  # $ V2: chr  "tBodyAcc-mad()-X" "tBodyAcc-mad()-Y" "tBodyAcc-mad()-Z" "tBodyAcc-max()-X" ...
  
  
  tnt2<-tnt1[, !(names(tnt1) %in% features_not_to_keep[,2])]
  dim(tnt2)
  #'data.frame':	10299 obs. of  69 variables:
  # $ tBodyAcc-mean()-X          : num  0.289 0.278 0.28 0.279 0.277
  
  
  print("## 3 add activity names")
  ##
  ## 3 Use descriptive activity names to name the activities in the data set
  ##
  tnt3<-tnt2
  # remember already read activity file:
  #str(activity)
  #'data.frame':	6 obs. of  2 variables:
  # $ V1: int  1 2 3 4 5 6
  # $ V2: chr  "WALKING" "WALKING_UPSTAIRS" "WALKING_DOWNSTAIRS" "SITTING" ...
  
  # add new column ActivityName to tnt, depending on Activity number already in data frame
  tnt3$ActivityName <- activity[,2][tnt3$Activity]
  
  dim(tnt3)
  #str(tnt3)
  #'data.frame':	10299 obs. of  70 variables:
  # $ tBodyAccelerometerMeanX            : num  0.289 0.278 0.28 0.279 0.277 ...
  # ...
  # $ fBodyGyroscopeJerkMagnitudeStd     : num  -0.991 -0.996 -0.995 -0.995 -0.995 ...
  # $ Source                             : chr  "train" "train" "train" "train" ...
  # $ Subject                            : int  1 1 1 1 1 1 1 1 1 1 ...
  # $ Activity                           : int  5 5 5 5 5 5 5 5 5 5 ...
  # $ ActivityName                       : chr  "STANDING" "STANDING" "STANDING" "STANDING" ...
  
  
  print("## 4 descriptive variable names")
  ##
  ## 4 Appropriately labels the data set with descriptive variable names
  ##
  # resolve abbreviations to long names
  #  "Acc" to "Accelerometer"
  #  "Gyro" to "Gyroscope"
  #  "Mag" to "Magnitude"
  #  "BodyBody" to "Body"
  # function names toUpper
  #  "mean()" to "Mean"
  #  "std()" to "Std"
  # delete extra characters (, ), -
  tnt4<-tnt3
  names(tnt4)<-sub("Acc", "Accelerometer", names(tnt4))
  names(tnt4)<-sub("Gyro", "Gyroscope", names(tnt4))
  names(tnt4)<-sub("Mag", "Magnitude", names(tnt4))
  names(tnt4)<-sub("BodyBody", "Body", names(tnt4))
  names(tnt4)<-sub("mean", "Mean", names(tnt4))
  names(tnt4)<-sub("std", "Std", names(tnt4))
  names(tnt4)<-sub("\\(\\)", "", names(tnt4))
  names(tnt4)<-sub("-", "", names(tnt4))
  dim(tnt4)
  
  
  print("## 5 tidy up with average")
  ##
  ## 5 From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject
  ##
  library(dplyr)
  tnt5<-arrange(tnt4, Subject, Activity)
  tnt5<-aggregate(tnt4[1:66], tnt4[,68:70], FUN=mean)
  tnt5$Activity<-NULL
  # dim(tnt5)
  #[1] 10299    70
  
  write.table(tnt5, "TidyData.txt", row.names = FALSE)
  
  print("## 5 write codebook")
  library(memisc)
  
  tntds<-data.set(tnt5)
  tntds <- within(tntds,{
    description(tnt5.Subject)	<- "Individuum performing the (train or test) exercise"
    wording(tnt5.Subject)		<- "Numeric code for individual person, 1-30"
    measurement(tnt5.Subject)	<- "ordinal"
    
    description(tnt5.ActivityName) <- "one of six registered movements"
    wording(tnt5.ActivityName)		<- "translated form numeric code"
    labels(tnt5.ActivityName)	<- c(
      "WALKING"			= 1,
      "WALKING_UPSTAIRS"	= 2,
      "WALKING_DOWNSTAIRS"= 3,
      "SITTING"			= 4,
      "STANDING"			= 5,
      "LAYING"			= 6	)
  })
  
  ##description(tntds)
  ##codebook(tntds)
  
  ##Write(description(tntds), file="TidyData-description.txt")
  Write(codebook(tntds), file="TidyData-codebook.txt")
  
  print("## Done.")
  print("## See resulting tidy data files in working directory")
  
  ## also return data frame to calling environment
  invisible(tnt5)
  
}