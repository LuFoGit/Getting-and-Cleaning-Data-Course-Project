# Getting-and-Cleaning-Data-Course-Project
The purpose of this project is to demonstrate the ability to collect, work with, and clean a data set. The goal is to prepare tidy data that can be used for later analysis. It is to submit: 

1. Link to individual Github repository with all files and descriptions
2. R script for performing the analysis 
3. Tidy data set as described below
4. Code book that describes the variables, the data, and any transformations or work that you performed to clean up the data called CodeBook.md 
5. (This) README.md to explain how all of the scripts work and how they are connected

# Data considerations

With analysis of origin data (see also FolderStructureAndFiles.txt) some files seemed to fit together like a puzzle with some files als columns and some as observation addition to main data files.

filename | dimensions | (expected) content
---------|------------|-------------------
features.txt | 561 x 1 | fitting as column names to n x 561 tables
activity_labels.txt | 6 x 1 | strings fitting to y_test and y_train data with range 1:6
X_test.txt|2947 x 561 | test data
y_test.txt|2947 x 1 | integers 1:6, number code for observation activities
subjects_test.txt|2947 x 1 | integers 1:30, number code for subjects performing the exercise
X_train.txt|7352 x 561 | train data
y_train.txt|7352 x 1 | integers 1:6, number code for observation activities
subjects_train.txt|7352 x 1 | integers 1:30, number code for subjects performing the exercise

It was decided to handle features.txt and activity_lables.txt as helper tables that add value to core data.
Then there are two bundles of test and train data with three files each. Largest X data are the observations while y and subjects data offer additional columns to main observation data.
So the structure for merging all these files together was planned:

1. Add y and subject columns to X test data
2. Add y and subject columns to X train data
3. rbind test and train data to a 10200x561 table (called tnt for "Test and Train" ;-) )
4. Rename 561 column headers by features list
5. Replace numeric activity column by activity labels

This defined program sequence for file and data handling.

# R Programming
As the assignment has requested the solution has been realised in R programming.

## Requirements
Assignment requested to create one R script called run_analysis.R that does the following. 

1. Merges the training and the test sets to create one data set.
2. Extracts only the measurements on the mean and standard deviation for each measurement. 
3. Uses descriptive activity names to name the activities in the data set
4. Appropriately labels the data set with descriptive variable names. 
5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

## Structure of function
Functions is a linear process chain fulfilling requested actions without any loops or preconditions. Execution can be repeated and results are reproducable. Straight forward function processes these actions:

- Download and unzip source data files
- Read files and process to combined data frame as described in "Data considerations" above (requirement 1)
- Extraction (requirement 2)
- Activity number to name translation (requirement 3)
- Column renaming (requirement 4)
- Tidy and averaging data export (requirement 5)
- Codebook generation and export
- Memory clean up
- Data frame return to console for optional further analysis

## Description of function
Major codeblocks and most functions are commented in function code. Here are just some remarks to highlight basic conceptional ideas and to follow the raw process chain.


As some activities like downloading and reading larg data frames take some while progress indications are written to consule. These code lines are not needed for the functionality, but helped during development and while waiting for execution, e.g.:
```
  print("## 1.1 Download and unzip")
```


Combined data frames have been numbered by requirments to allow step wise development and to indicate code chain. See example of step 2 following *2. Extracts only the measurements on the mean and standard deviation for each measurement*.
```
  tnt2<-tnt1[, !(names(tnt1) %in% features_not_to_keep[,2])]
```


Tables are read with option *as.is=TRUE* to avoid factoring of columns.
```
  features<-read.table("UCI HAR Dataset/features.txt", as.is=TRUE )
  #                                                    ^^^^^^^^^^ to avoid factor
```


During development several data analysis has taken part. Most dimensions are commented in code to keep overview on column and observation handling.
```
  testx<-read.table("UCI HAR Dataset/test/X_test.txt")
  dim(testx)
  #[1] 2947  561
```


While developing rbind of test and train data it turned out that there are errors and issues caused by renamed columns. So finally the first data set handling has been done with column numbering and renaming took place after rbind.
```
  # add columns to table x
  # attention, use column numbering, do not give column names as this spoils rbind later on (?)
  testx[,562] <- "test"
  testx[,563] <- tests[,1]
  testx[,564] <- testy[,1]
  dim(testx)
  #[1] 2947  564
```


Column renaming took place after rbind of both data frames.
```
  ## 1.4 rename colum names in x table
  # these are not final names, but to keep track of columns during development...
  names(tnt1) <- features[,2]
  names(tnt1)[562] <- "Source"
  names(tnt1)[563] <- "Subject"
  names(tnt1)[564] <- "Activity"
```


Decision to select mean and standard deviation columns has been take by observation, that some column names in features.txt end like *mean()* or *std()* indicating already processed functionality. A list of column names NOT to keep has been grep'ed. Due to this list of 495 columns to exclude, further processing has been done with 66 columns. [Usually it is prefered to think in a positive way, e.g. features_to_keep, but in this case already added columns (source, subject and activity) blocked this approach. Code goes for a Boolean expression *not features_not_to_keep* :]
```
  features_not_to_keep<-features[!(grepl("([mM]ean|[sS]td)\\(", features[,2])),]
  #str(features_not_to_keep)
  #'data.frame':	495 obs. of  2 variables:
  #...

  tnt2<-tnt1[, !(names(tnt1) %in% features_not_to_keep[,2])]
```


Activity names have been included by list of six activity names, assuming numerical values 1:6 are bound to activity list order.
```
  # add new column ActivityName to tnt, depending on Activity number already in data frame
  tnt3$ActivityName <- activity[,2][tnt3$Activity]
```


Column renaming has been decided on this observations and translations.

  - resolve abbreviations to long names
    - "Acc" to "Accelerometer"
    - "Gyro" to "Gyroscope"
    - "Mag" to "Magnitude"
    - "BodyBody" to "Body"
  - function names toUpper
    - "mean()" to "Mean"
    - "std()" to "Std"
  - delete extra bracket and comma characters (, ), -
  

Requirement 5, tidying data, was solved by dplyr aggregation to 180 rows (30 subjects with 6 activities each).
```
  print("## 5 tidy up with average")
  ##
  ## 5 From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject
  ##
  library(dplyr)
  tnt5<-aggregate(tnt4[1:66], tnt4[,68:70], FUN=mean)
  tnt5$Activity<-NULL
  # dim(tnt5)
  #[1] 180    70
```


## Resulting data

### Tidy Data
Tidy data set is written to file system

```
write.table(tnt5, "TidyData.txt", row.names = FALSE)
```

### Codebook
This might be the most weak part of the assignment results. It has been created with *codebook {memisc}* and written to file system as text. As there is no clear definition of a code book this area of data science offers room for personal skill improvement.
```
library(memisc)
...
Write(codebook(tntds), file="TidyData-codebook.txt")
```

# Submitted files
In this GitHub repo following files represent assignment submission.

Filename | Content
---------| -------
README.md | This summary
FolderStructureAndFiles.txt | Listing on source data files and folder structure
run_analysis.R | Function performing the analysis, written in R
TidyData.txt | Resulting data table with "average of each variable for each activity and each subject"
TidyData-codebook.txt | *codebook {memisc}* generated data frame documentation

# Personal remark
This assignment offers room for individual analysis and decisions how to solve certain requirements. In some cases, e.g. rbind problems of renamed data frames, discussion forum helped to proceed.
The sub task of googleing for code books without being informed during the lessons, was disappointing.
Finally the time effort for this assignment was much more than expected.

All in all this was a appreciated experience in R programming and data science documentation.