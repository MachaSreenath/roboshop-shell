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

dnf module disable mysql -y

VALIDATE $? "Disable mysql module"

cp mysql.repo /etc/yum.repos.d/mysql.repo

VALIDATE $? "Copy mysql repo"

dnf install mysql-community-server -y

VALIDATE $? "Install mysql"

systemctl enable mysqld

VALIDATE $? "Enable mysql service"

systemctl start mysqld

VALIDATE $? "Start mysql service"

mysql_secure_installation --set-root-pass RoboShop@1

VALIDATE $? "Setting mysql root password"