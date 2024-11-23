#!/bin/bash

ID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
R="\e[31m"
G="\e[32m"
N="\e[0m"

LOGFILE="/tmp/$0-$TIMESTAMP.log"

echo "Script started executing at $TIMESTAMP" &>> $LOGFILE

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "ERROR:: $2 ... $R FAILED $N"
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N"
    fi
}

if [ $ID -ne 0 ]
then
    echo -e "\e[31m ERROR:: Please run this script with root access \e[0m"
    exit 1 #you can give other than 0
else
    echo -e "\e[33m You are root user \e[0m"
fi #fi means reverse of if, indicating condition end

cp mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE

VALIDATE $? "Copied mongo.repo"

dnf install mongodb-org -y 

VALIDATE $? "Installed MongoDB" &>> $LOGFILE

systemctl enable mongod &>> $LOGFILE

VALIDATE $? "Enabled MongoDB service"

systemctl start mongod &>> $LOGFILE

VALIDATE $? "started MongoDB service"

sed -i 's/127.0.0.0/0.0.0.0/g' /etc/mongod.conf &>> $LOGFILE

VALIDATE $? "Remote access to mongodb"

systemctl restart mongod &>> $LOGFILE

VALIDATE $? "Restarted MongoDB service"
