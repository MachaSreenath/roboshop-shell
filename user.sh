#!/bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
mongodb_host=mongodb.forpractice.uno

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"

echo "script stareted executing at $TIMESTAMP" &>> $LOGFILE

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2 ... $R FAILED $N"
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N"
    fi
}

if [ $ID -ne 0 ]
then
    echo -e "$R ERROR:: Please run this script with root access $N"
    exit 1 # you can give other than 0
else
    echo "You are root user"
fi # fi means reverse of if, indicating condition end

dnf module disable nodejs -y &>> $LOGFILE

VALIDATE $? "Disabling nodejs" 

dnf module enable nodejs:20 -y &>> $LOGFILE

VALIDATE $? "Enabling nodejs:20" 

dnf install nodejs -y &>> $LOGFILE

VALIDATE $? "Installing nodejs 20"

id roboshop

if [ $? -ne 0 ]
then
    useradd roboshop 
    VALIDATE $? "roboshop user"
else
    echo -e "roboshop user already exist $Y SKIPPING $N"
fi

mkdir -p /app 

VALIDATE $? "Creating app directory" 

curl -o /tmp/user.zip https://roboshop-builds.s3.amazonaws.com/user.zip &>> $LOGFILE

VALIDATE $? "Downloading user application" 
 
cd /app &>> $LOGFILE

unzip -o /tmp/user.zip &>> $LOGFILE

VALIDATE $? "Unzipping user application" 

npm install &>> $LOGFILE

VALIDATE $? "Installing dependencies" 

cp /home/centos/roboshop-shell/user.service /etc/systemd/system/user.service &>> $LOGFILE

VALIDATE $? "Copying user service file"

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "Reloading daemon" 

systemctl enable user &>> $LOGFILE

VALIDATE $? "Enabling user service" 

systemctl start user &>> $LOGFILE

VALIDATE $? "Starting user service"

cp /home/centos/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo

VALIDATE $? "Copying mongo repository file"

dnf install mongodb-org-shell -y &>> $LOGFILE

VALIDATE $? "Installing mongodb client"

mongo --host $mongodb_host </app/schema/user.js &>> $LOGFILE

VALIDATE $? "Loading user data into mongodb"
