library(reshape2)

file <- "getdata_dataset.zip"

## Downloading the data:
if (!file.exists(file)){
  fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
  download.file(fileURL, file, method="curl")
}
## Unzipping:
if (!file.exists("UCI HAR Dataset")) { 
  unzip(file) 
}

## Preparing activity labels + features
labels <- read.table("UCI HAR Dataset/activity_labels.txt")
labels[,2] <- as.character(labels[,2])
features <- read.table("UCI HAR Dataset/features.txt")
features[,2] <- as.character(features[,2])

## Extracting the data on mean and standard deviation
wanted <- grep(".*mean.*|.*std.*", features[,2])
names.wanted <- features[wanted,2]
  ## Cleaning names
    names.wanted <- gsub('-mean', 'Mean', names.wanted)
    names.wanted <- gsub('-std', 'Std', names.wanted)
    names.wanted <- gsub('[-()]', '', names.wanted)


## Loading datasets
    ## Training data
      train <- read.table("UCI HAR Dataset/train/X_train.txt")[wanted]
      trainactivities <- read.table("UCI HAR Dataset/train/y_train.txt")
      trainsubjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
      ## Binding tables
        train <- cbind(trainsubjects, trainactivities, train)

    ## Test Data
      test <- read.table("UCI HAR Dataset/test/X_test.txt")[wanted]
      testactivities <- read.table("UCI HAR Dataset/test/y_test.txt")
      testsubjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
      ## Binding tables
        test <- cbind(testsubjects, testactivities, test)

## Merging datasets and names
  full.data <- rbind(train, test)
  colnames(full.data) <- c("subject", "activity", names.wanted)

## Creating Factors
  full.data$activity <- factor(full.data$activity, levels = labels[,1], labels = labels[,2])
  full.data$subject <- as.factor(full.data$subject)

## Melting and preparing final output
melt.data <- melt(full.data, id = c("subject", "activity"))
output <- dcast(melt.data, subject + activity ~ variable, mean)

write.table(output, "tidy.txt", row.names = FALSE, quote = FALSE)
