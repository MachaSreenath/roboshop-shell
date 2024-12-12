#!/bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

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
fi

dnf install python3.11 gcc python3-devel -y &>> $LOGFILE

VALIDATE $? "Installing python"

id roboshop

if [ $? -ne 0 ]
then
    useradd roboshop 
    VALIDATE $? "roboshop user"
else
    echo -e "roboshop user already exist $Y SKIPPING $N"
fi

mkdir /app &>> $LOGFILE

VALIDATE $? "Creating app directory"

curl -L -o /tmp/payment.zip https://roboshop-builds.s3.amazonaws.com/payment.zip &>> $LOGFILE

VALIDATE $? "Downloading payment zip"

cd /app 

VALIDATE $? "Moving to app directory"

unzip /tmp/payment.zip &>> $LOGFILE

VALIDATE $? "Unzipping payment zip"

pip3.11 install -r requirements.txt &>> $LOGFILE

VALIDATE $? "Installing python dependencies"

cp /home/centos/roboshop-shell/payment.service /etc/systemd/system/payment.service &>> $LOGFILE

VALIDATE $? "Copying payment service"

systemctl daemon-reload

VALIDATE $? "Reloading systemd daemon"

systemctl enable payment 

VALIDATE $? "Enabling payment service"

systemctl start payment

VALIDATE $? "Starting payment service"

