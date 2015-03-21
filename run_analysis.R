#run_analysis.R
library("dplyr")
library("tidyr")
library("data.table")

#read in headers
headers<-read.table("~/Coursera/R Folder/UCI HAR Dataset/features.txt")
headers<-as.character(headers$V2)
headers<-make.names(headers,unique=TRUE)

#read in data sets, create key and assign headers
trainingset<-read.table("~/Coursera/R Folder/UCI HAR Dataset/train/X_train.txt",header=FALSE,sep="",dec=".",colClasses="character",row.names=NULL)
colnames(trainingset)<-headers #add headers
trainingset$key<-1:nrow(trainingset) #add key

testset<-read.table("~/Coursera/R Folder/UCI HAR Dataset/test/X_test.txt",header=FALSE,sep="",dec=".",colClasses="character",row.names=NULL)
colnames(testset)<-headers #add headers
testset$key<-1:nrow(testset)

#read in subject and activity files, create key
subjtest<-read.table("~/Coursera/R Folder/UCI HAR Dataset/test/subject_test.txt",col.names="subject")
subjtest$key<-1:nrow(subjtest)
subjtrain<-read.table("~/Coursera/R Folder/UCI HAR Dataset/train/subject_train.txt",col.names="subject")
subjtrain$key<-1:nrow(subjtrain)
acttest<-read.table("~/Coursera/R Folder/UCI HAR Dataset/test/y_test.txt",col.names="activity")
acttest$key<-1:nrow(acttest)
acttrain<-read.table("~/Coursera/R Folder/UCI HAR Dataset/train/y_train.txt",col.names="activity")
acttrain$key<-1:nrow(acttrain)

#merge files by key
trainingset<-trainingset%>%merge(subjtrain,by="key")%>%merge(acttrain,by="key")
testset<-testset%>%merge(subjtest,by="key")%>%merge(acttest,by="key")

#combine data set
df<-rbind(trainingset,testset)

#Extract mean and standard deviation measures using dplyr
df_meansd<-select(df,contains("mean"),contains("std"),matches("key"),matches("subject"),matches("activity"))

#Read in activity labels and add labels to dataset
activitynames<-read.table("~/Coursera/R Folder/UCI HAR Dataset/activity_labels.txt",col.names=c("activity","activityname"))
df_meansd<-merge(df_meansd,activitynames,by="activity")
df_meansd<-select(df_meansd,-key)
df_meansd<-as.data.table(df_meansd)

#tidy data set (need to remove NAs)
df_tidy<-df_meansd%>%group_by(subject,activity,activityname)%>%summarise_each(funs(mean(na.omit(.))))
