#!/bin/bash

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOGS_FOLDER="/var/log/shell-script"
SCRIPT_NAME=$( echo $0 | cut -d "." -f1 )
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log" # /var/log/shell-script/16-logs.log
MONGO_HOST=mongodb.daws86s.icu
SCRIPT_DIR=$PWD
mkdir -p $LOGS_FOLDER
echo "Script started executed at: $(date)" | tee -a $LOG_FILE

if [ $USERID -ne 0 ]; then
    echo "ERROR:: Please run this script with root privelege"
    exit 1 # failure is other than 0
fi

VALIDATE(){ # functions receive inputs through args just like shell script args
    if [ $1 -ne 0 ]; then
        echo -e "Installing $2 ... $R FAILURE $N" | tee -a $LOG_FILE
        exit 1
    else
        echo -e "Installing $2 ... $G SUCCESS $N" | tee -a $LOG_FILE
    fi
}


dnf module disable nodejs -y &>>$LOG_FILE
VALIDATE $? "Disable nodejs"

dnf module enable nodejs:20 -y &>>$LOG_FILE
VALIDATE $? "Enable nodejs 20"

dnf install nodejs -y
VALIDATE $? "Install nodejs 20"

id=roboshop
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
    VALIDATE $? "Adding system user"
else
    echo -e "User alredy exist...$Y SKIPPING $N"
fi

rm -rf /app
VALIDATE "Removing existing directory"

mkdir /app 
VALIDATE $? "Creating app directory"



curl -o /tmp/user.zip https://roboshop-artifacts.s3.amazonaws.com/user-v3.zip &>>$LOG_FILE
VALIDATE $? "Downloading user"

cd /app 
VALIDATE $? "change app directory"

rm -rf /app/*
VALIDATE "Removing existing code"

unzip /tmp/user.zip &>>$LOG_FILE
VALIDATE $? "Unzip user"

cd /app 
VALIDATE $? "change app directory"

npm install &>>$LOG_FILE
VALIDATE $? "Installing dependencies"

cp $SCRIPT_DIR/user.service /etc/systemd/system/user.service
VALIDATE $? "Copy user.services"

systemctl daemon-reload

systemctl enable user &>>$LOG_FILE
VALIDATE $? "Enable user"

systemctl start user
VALIDATE $? "start user"

systemctl restart user
VALIDATE $? "Restarting user"