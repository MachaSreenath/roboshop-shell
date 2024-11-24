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

dnf install maven -y

VALIDATE $? "Maven installation"

id roboshop

if [ $? -ne 0 ]
then
    useradd roboshop 
    VALIDATE $? "roboshop user"
else
    echo -e "roboshop user already exist $Y SKIPPING $N"
fi

mkdir /app

VALIDATE $? "Creating app directory"

curl -L -o /tmp/shipping.zip https://roboshop-builds.s3.amazonaws.com/shipping.zip &>> $LOGFILE

VALIDATE $? "Downloading shipping"

cd /app

VALIDATE $? "Moving to app directory"

unzip -o /tmp/shipping.zip &>> $LOGFILE

VALIDATE $? "Unzipping shipping"

mvn clean package &>> $LOGFILE

VALIDATE $? "Installing dependencies"

mv target/shipping-1.0.jar shipping.jar &>> $LOGFILE

VALIDATE $? "Renaming jar file"

cp /home/centos/roboshop-shell/shipping.service /etc/systemd/system/shipping.service &>> $LOGFILE

VALIDATE $? "Copying shipping service"

systemctl daemon-reload

VALIDATE $? "Reloading daemon"

systemctl enable shipping 

VALIDATE $? "Enabling shipping service"

systemctl start shipping

VALIDATE $? "Starting shipping service"

dnf install mysql -y &>> $LOGFILE

VALIDATE $? "Installing mysql client"

mysql -h mysql.forpractice.uno -uroot -pRoboShop@1 < /app/schema/shipping.sql &>> $LOGFILE

VALIDATE $? "Loading shipping database"

systemctl restart shipping 

VALIDATE $? "Restarting shipping service"