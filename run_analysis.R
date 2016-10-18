#Assingment Week 4 Module 3 Getting and Cleaning Data

#download dataset
url<-"https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(url,"./Data/dataset.zip")

#unzipping the dataset
?unzip
unzip("./Data/dataset.zip")

#checking list of files
list.dirs()
list.files("./UCI HAR Dataset/test")
list.files("./UCI HAR Dataset/train")

library(dplyr)

?read.table

#load data using read.table

Xtrain <- read.table("./Videos and Notes from Coursera/03_Getting Cleaning Data/UCI HAR Dataset/train/X_train.txt")
Ytrain <- read.table("./Videos and Notes from Coursera/03_Getting Cleaning Data/UCI HAR Dataset/train/y_train.txt")
subject_train <- read.table("./Videos and Notes from Coursera/03_Getting Cleaning Data/UCI HAR Dataset/train/subject_train.txt")

Xtest <- read.table("./Videos and Notes from Coursera/03_Getting Cleaning Data/UCI HAR Dataset/test/X_test.txt")
Ytest <- read.table("./Videos and Notes from Coursera/03_Getting Cleaning Data/UCI HAR Dataset/test/y_test.txt")
subject_test <- read.table("./Videos and Notes from Coursera/03_Getting Cleaning Data/UCI HAR Dataset/test/subject_test.txt")

#checking variable name for each X,Y and subject
names(Xtrain)   #561 variable start with V1-V561
names(Ytrain)   #1 variable, V1
names(subject_train)  #1 variable, V1

#since all variable have V1, rename variable for Y and subject for both train dan test dataset
colnames(subject_train)<-"Subject"
colnames(subject_test)<-"Subject"
colnames(Ytrain)<-"Activity"
colnames(Ytest)<-"Activity"

#rename X dataset for both train and test using features

features <- read.table("./Videos and Notes from Coursera/03_Getting Cleaning Data/UCI HAR Dataset/features.txt")
colnames(Xtrain)<-t(features[2])
colnames(Xtest)<-t(features[2])


#STEP 1
#merge each train data and test data using cbind

Train<-cbind(subject_train,Ytrain,Xtrain)
Test<-cbind(subject_test,Ytest,Xtest)

#before merging train data (70%) and test data(30%), i would like to add new variable
# named "mode" to mark wether the observation is training or test

Train$Mode<-"training"
Test$Mode<-"test"


#merge all using rbind

All_data<-rbind(Train,Test)


#STEP 2 

#remove duplicate
duplicated(colnames(All_data))
All_data<-All_data[,!duplicated(colnames(All_data))]

#extracting measurement on the mean and stdev using select
#maintain act_code and subject as main variable
?select

mean_std_data<-select(All_data,contains("Subject"),contains("Activity"),contains("mean()"),contains("std()"))


#STEP 3
#Using descriptive activity names

#load activity labels
activity_labels <- read.table("./Videos and Notes from Coursera/03_Getting Cleaning Data/UCI HAR Dataset/activity_labels.txt")

#rename descriptive activity names
names(mean_std_data)
mean_std_data[, 2] <- activity_labels[mean_std_data[, 2], 2]
View(mean_std_data)
names(mean_std_data)

#STEP 4
#labels data set with descriptive variable names

#Already labelled in STEP 2 using features

names(mean_std_data)<-gsub("std()", "SD", names(mean_std_data))
names(mean_std_data)<-gsub("mean()", "MEAN", names(mean_std_data))
names(mean_std_data)<-gsub("^t", "time", names(mean_std_data))
names(mean_std_data)<-gsub("^f", "frequency", names(mean_std_data))
names(mean_std_data)<-gsub("Acc", "Accelerometer", names(mean_std_data))
names(mean_std_data)<-gsub("Gyro", "Gyroscope", names(mean_std_data))
names(mean_std_data)<-gsub("Mag", "Magnitude", names(mean_std_data))
names(mean_std_data)<-gsub("BodyBody", "Body", names(mean_std_data))

names(mean_std_data)


#STEP 5
#Create create data set with average of each variable for each activity and subject

library(plyr)

tidydata_avg <- ddply(mean_std_data, .(Subject, Activity), function(x) colMeans(x[, 3:68]))

getwd()
?write.table
write.table(tidydata_avg,file = "./Videos and Notes from Coursera/03_Getting Cleaning Data/Quiz and Assignments/Assignment Week 4/tidydata.txt", row.names = FALSE)


