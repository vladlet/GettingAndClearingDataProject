
## 1. Merges the training and the test sets to create one data set
##==============================================================================

## Download data 
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
fileArch <- "./data/data.zip"

dir.create("./data")
if (!file.exists("./data/data.zip")) {
  download.file(fileUrl, destfile=fileArch, method="curl")
  ## Extract files from the zip archive.
  unzip(fileArch, exdir="./data")
}

## Init a directory of input data
pathData <- file.path("./data/UCI HAR Dataset/")

## Read the activity files
inActivity <- list()
inActivity$train <- read.table(file.path(pathData, "train", "Y_train.txt"), header = FALSE)
inActivity$test  <- read.table(file.path(pathData, "test" , "Y_test.txt" ), header = FALSE)

## Read the subject files
inSubject <- list()
inSubject$train <- read.table(file.path(pathData, "train", "subject_train.txt"), header = FALSE)
inSubject$test  <- read.table(file.path(pathData, "test" , "subject_test.txt"), header = FALSE)

## Read fearures files
inFeatures <- list()
inFeatures$test  <- read.table(file.path(pathData, "test" , "X_test.txt" ), header = FALSE)
inFeatures$train <- read.table(file.path(pathData, "train", "X_train.txt"), header = FALSE)
inFeatures$names <- read.table(file.path(pathData, "features.txt"), header=FALSE)

## Concatenate all data 
inActivity$all <- rbind(inActivity$train, inActivity$test)
inSubject$all <- rbind(inSubject$train, inSubject$test)
inFeatures$all <- rbind(inFeatures$train, inFeatures$test)

## Set names to the columns
names(inActivity$all) <- "activity"
names(inSubject$all) <- "subject"
names(inFeatures$all) <- inFeatures$names$V2

## Merge all data to variable "data"
data <- cbind(inActivity$all, inSubject$all, inFeatures$all)

## Free some memory
rm(list=c("fileArch", "fileUrl", "inActivity", "inFeatures", "inSubject"))

## 2. Extracts only the measurements on the mean and standard deviation for each measurement. 
##==============================================================================

allNames <- names(data)
needNames <- allNames[grepl("mean\\(\\)|std\\(\\)", allNames)]
data <- subset(data, select = c("activity", "subject", needNames))

rm(list=c("allNames", "needNames"))

## 3. Uses descriptive activity names to name the activities in the data set
##==============================================================================
actLabels <- read.table(file.path(pathData, "activity_labels.txt"), header = FALSE)
data$activity <- factor(data$activity, levels = actLabels$V1, labels = actLabels$V2)

## Free some memory
rm(list=c("actLabels"))

## 4. Appropriately labels the data set with descriptive variable names. 
##==============================================================================

## Use information from feature_info.txt 
## prefix 't' to denote time
## prefix 'f' to indicate frequency domain signals 
## the 'Acc' means accelerometer 
## the 'Gyro' means gyroscope
## the 'Mag' means magnitude of these three-dimensional signals
## the 'BodyBody' is needed to reduce to 'Body'

names(data) <- gsub("^t", "Time", names(data))
names(data) <- gsub("^f", "Frequency", names(data))
names(data) <- gsub("Acc", "Accelerometer", names(data))
names(data) <- gsub("Gyro", "Gyroscope", names(data))
names(data) <- gsub("Mag", "Magnitude", names(data))
names(data) <- gsub("BodyBody", "Body", names(data))

## 5. From the data set in step 4, creates a second, independent tidy data set with
## the average of each variable for each activity and each subject.
##==============================================================================

tidyData <- aggregate(. ~ activity + subject, data, FUN=mean)
write.table(tidyData, file = "tidydata.txt", row.name = FALSE)


