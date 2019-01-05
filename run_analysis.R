#Download and unzip the zip file
fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip "
download.file(fileURL, destfile = 'dataset.zip',method='curl')

unzip('dataset.zip')

#load the activity and feature information
activities <- read.table("UCI HAR Dataset/activity_labels.txt")
features <- read.table("UCI HAR Dataset/features.txt")


activities[,2] <- as.characther(activities[,2])
features[,2] <- as.character(features[,2])

#extract mean and std column
meanstdfeatures <- grep('.*mean.*|.*std.*',features[,2])
meanstdfeatures.name <-features[meanstdfeatures,2]
meanstdfeatures.name <- gsub('-mean','Mean', meanstdfeatures.name)
meanstdfeatures.name <- gsub('-std', 'Std', meanstdfeatures.name)
meanstdfeatures.name <- gsub('[-()]','', meanstdfeatures.name)

#load trian dataset with only mean and std column
train <- read.table("UCI HAR Dataset/train/X_train.txt")[meanstdfeatures]
trainactivities <- read.table("UCI HAR Dataset/train/y_train.txt")
trainsubject<- read.table("UCI HAR Dataset/train/subject_train.txt")

train <- cbind(trainsubject,trainactivities,train)

#load test dataset with only mean and std column
test <- read.table("UCI HAR Dataset/test/X_test.txt")[meanstdfeatures]
testactivities <- read.table("UCI HAR Dataset/test/y_test.txt")
testsubject<- read.table("UCI HAR Dataset/test/subject_test.txt")

test <- cbind(testsubject, testactivities, test)

#merge train and test
data <- rbind(train,test)

#change column names to readable names
colnames(data) <- c('subject','activity', meanstdfeatures.name)

#change activity and subject column into factors
data$activity <- factor(data$activity, levels = activities[,1], labels = activities[,2])
data$subject <- as.factor(data$subject)

#get mean for each variable for each subject and activity
data.melt <- melt(data,id = c('subject','activity'))
data.mean <- dcast(data.melt, subject + activity ~ variable, mean)

#create a data table with means for each subject + activity

write.table(data.mean, "tidy.txt", row.names = FALSE, quote = FALSE)