# Retrieve files from the internet
fileurl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileurl, destfile = "UCIdataset.zip", method = "curl")

# unzip the file and change working directory
unzip("UCIdataset.zip")
setwd('./UCI HAR Dataset')

# Load the data into R
trainingSet <- read.table("train/X_train.txt", sep = "", header = FALSE)
trainingLabels <- read.table("train/Y_train.txt", sep = "", header = FALSE)
trainingSubject <- read.table("train/subject_train.txt", sep = "", header = FALSE)
testSet <- read.table("test/X_test.txt", sep = "", header = FALSE)
testLabels <- read.table("test/Y_test.txt", sep = "", header = FALSE)
testSubject <- read.table("test/subject_test.txt", sep = "", header = FALSE)

# part 1 - merge the training and test data into one data frame
train <- cbind(trainingSubject, trainingLabels, trainingSet)
test <- cbind(testSubject, testLabels, testSet)
complete <- rbind(test, train)        #merges the test and training sets

# Name the columns of the data set, sourced from features.txt
features <- read.table("features.txt")
names(complete) <- c("subject", "label", as.vector(features$V2))

# part 2 - Extract only the measurements on the mean and standard deviation for each measurement
meanIndex <- grep("-mean\\(\\)", names(complete), ignore.case = TRUE)        #extracting only "mean()" measurements
stdIndex <- grep("-std\\(\\)", names(complete), ignore.case = TRUE)
index <- c(1,2,meanIndex, stdIndex)
index <- sort(index)
extracted <- complete[, index]        # this is the desired data frame, with only mean and sd observations


# part 3 - Uses descriptive activity names to name the activities in the data set
activityLabels <- read.table("activity_labels.txt")        # step 1 - source descriptive activity names from "activity labels.txt"
extracted$label <- activityLabels$V2[extracted$label]        # replace label numbers with descriptive activity names

# part 4 - Appropriately label the data set with descriptive variable names
names(extracted) <- gsub("-",".",names(extracted))
names(extracted) <- gsub("\\(\\)","",names(extracted))
names(extracted) <- gsub("^t", "time", names(extracted))
names(extracted) <- gsub("^f", "freq", names(extracted))


# part 5 - From the data set in step 4, create a second, independent tidy data set 
# with the average of each variable for each activity and each subject
library(dplyr)
tidyExtract <- extracted %>% group_by(subject, label) %>% summarize_all(funs(mean))

write.table(tidyExtract, file = "tidyExtract.txt", row.names = FALSE)
setwd("//Users/balajik/Documents/R/")
