#CleaningData Assignment (run_analysis.R)

#1. Merges the training and the test sets to create one data set
#2. Extracts only the measurements on the mean and standard deviation for each measurement
#3. Uses descriptive activity names to name the activities in the data set
#4. Appropriately labels the data set with descriptive variable names
#5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject

# Load Packages and get the data
library(data.table)
library(reshape2)
path <- getwd()
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(url, file.path(path, "data.zip"))
unzip(zipfile = "data.zip")

#Load activity labels and features
activityLabels <- fread(file.path(path, "UCI HAR Dataset/activity_labels.txt"), col.names = c("classLabels", "activityName"))
features <- fread(file.path(path, "UCI HAR Dataset/features.txt"), col.names = c("index", "featureNames"))
featuresWanted <- grep("(mean|std)\\(\\)", features[, featureNames])
measurements <- features[featuresWanted, featureNames]
measurements <- gsub('[()]', '', measurements)

#Load train datasets
train <- fread(file.path(path, "UCI HAR Dataset/train/X_train.txt"))[, featuresWanted, with = FALSE]
data.table::setnames(train, colnames(train), measurements)
trainActivities <- fread(file.path(path, "UCI HAR Dataset/train/Y_train.txt"), col.names = c("Activity"))
trainSubjects <- fread(file.path(path, "UCI HAR Dataset/train/subject_train.txt"), col.names = c("SubjectNum"))
train <- cbind(trainSubjects, trainActivities, train)

#Load test datasets
test <- fread(file.path(path, "UCI HAR Dataset/test/X_test.txt"))[, featuresWanted, with = FALSE]
data.table::setnames(test, colnames(test), measurements)
testActivities <- fread(file.path(path, "UCI HAR Dataset/test/Y_test.txt"), col.names = c("Activity"))
testSubjects <- fread(file.path(path, "UCI HAR Dataset/test/subject_test.txt"), col.names = c("SubjectNum"))
test <- cbind(testSubjects, testActivities, test)

#Merge datasets
tidydata <- rbind(train, test)

#Convert Class Labels to Activity Names
tidydata[["Activity"]] <- factor(tidydata[, Activity], levels = activityLabels[["classLabels"]], labels = activityLabels[["activityName"]])
tidydata[["SubjectNum"]] <- as.factor(tidydata[, SubjectNum])
tidydata <- reshape2::dcast(data = tidydata, SubjectNum + Activity ~ variable, fun.aggregate = mean)

#Write tidydata to txt file
write.table(tidydata,file = "tidydata.txt",row.names = FALSE)
