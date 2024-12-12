#!/bin/bash

# Color codes for output
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

# Variables
TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$(basename $0)-$TIMESTAMP.log"

# Start logging
echo "Script started executing at $TIMESTAMP" &>> $LOGFILE

# Function to validate commands
VALIDATE() {
    if [ $1 -ne 0 ]; then
        echo -e "$2 ... $R FAILED $N"
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N"
    fi
}

# Ensure the script is run as root
if [ $(id -u) -ne 0 ]; then
    echo -e "$R ERROR: Please run this script as root $N"
    exit 1
fi

# Check and add the roboshop user
if ! id roboshop &>> $LOGFILE; then
    useradd roboshop
    VALIDATE $? "Roboshop user creation"
else
    echo -e "Roboshop user already exists ... $Y SKIPPING $N"
fi

# Install Maven
dnf install maven -y &>> $LOGFILE
VALIDATE $? "Maven installation"

# Create app directory
mkdir -p /app &>> $LOGFILE
VALIDATE $? "Creating app directory"

# Download and extract shipping package
curl -L -o /tmp/shipping.zip https://roboshop-builds.s3.amazonaws.com/shipping.zip &>> $LOGFILE
VALIDATE $? "Downloading shipping package"

cd /app &>> $LOGFILE
VALIDATE $? "Navigating to app directory"

unzip -o /tmp/shipping.zip &>> $LOGFILE
VALIDATE $? "Unzipping shipping package"

# Build the application
mvn clean package &>> $LOGFILE
VALIDATE $? "Building the application"

mv target/shipping-1.0.jar shipping.jar &>> $LOGFILE
VALIDATE $? "Renaming jar file"

# Set up systemd service
cp /home/centos/roboshop-shell/shipping.service /etc/systemd/system/shipping.service &>> $LOGFILE
VALIDATE $? "Copying shipping service file"

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "Reloading systemd daemon"

systemctl enable shipping &>> $LOGFILE
VALIDATE $? "Enabling shipping service"

systemctl start shipping &>> $LOGFILE
VALIDATE $? "Starting shipping service"

# Install MySQL client
dnf install mysql -y &>> $LOGFILE
VALIDATE $? "Installing MySQL client"

# Load the database
MYSQL_SERVER="<MYSQL-SERVER-IPADDRESS>"
mysql -h $MYSQL_SERVER -uroot -pRoboShop@1 < /app/db/schema.sql &>> $LOGFILE
VALIDATE $? "Loading schema.sql"

mysql -h $MYSQL_SERVER -uroot -pRoboShop@1 < /app/db/app-user.sql &>> $LOGFILE
VALIDATE $? "Loading app-user.sql"

mysql -h $MYSQL_SERVER -uroot -pRoboShop@1 < /app/db/master-data.sql &>> $LOGFILE
VALIDATE $? "Loading master-data.sql"

# Restart shipping service
systemctl restart shipping &>> $LOGFILE
VALIDATE $? "Restarting shipping service"
