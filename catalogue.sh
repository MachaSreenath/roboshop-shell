#!/bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
mongodb_host=mongodb.forpractice.online

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

dnf module disable nodejs -y

VALIDATE $? "Disabling nodejs" &>> $LOGFILE

dnf module enable nodejs:18 -y

VALIDATE $? "Enabling nodejs:18" &>> $LOGFILE

dnf install nodejs -y

VALIDATE $? "Installing nodejs 18" &>> $LOGFILE

useradd roboshop

VALIDATE $? "Adding user roboshop" &>> $LOGFILE

mkdir /app

VALIDATE $? "Creating /app directory" &>> $LOGFILE

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip

VALIDATE $? "Downloading catalogue application" &>> $LOGFILE

cd /app 

unzip /tmp/catalogue.zip &>> $LOGFILE

VALIDATE $? "Unzipping catalogue application" &>> $LOGFILE

npm install 

VALIDATE $? "Installing catalogue application dependencies" &>> $LOGFILE

cp /home/centos/roboshop-shell/catalogue.service /etc/systemd/system/catalogue.service

VALIDATE $? "Copying catalogue service file" &>> $LOGFILE

systemctl daemon-reload

VALIDATE $? "Reloading daemon" &>> $LOGFILE

systemctl enable catalogue

VALIDATE $? "Enabling catalogue service" &>> $LOGFILE

systemctl start catalogue

VALIDATE $? "Starting catalogue service" &>> $LOGFILE

cp /home/centos/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo

VALIDATE $? "Copying mongo repository file" &>> $LOGFILE

dnf install mongodb-org-shell -y

VALIDATE $? "Installing mongodb client" &>> $LOGFILE

mongo --host $mongodb_host </app/schema/catalogue.js

VALIDATE $? "Loading catalogue data into mongodb" &>> $LOGFILE