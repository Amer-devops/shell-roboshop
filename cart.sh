#!/bin/bash

cartID=$(id -u)
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



mkdir -p /app
VALIDATE $? "Creating app directory"



curl -o /tmp/cart.zip https://roboshop-artifacts.s3.amazonaws.com/cart-v3.zip &>>$LOG_FILE
VALIDATE $? "Downloading cart"

cd /app 
VALIDATE $? "change app directory"

rm -rf /app/*
VALIDATE "Removing existing code"

unzip /tmp/cart.zip &>>$LOG_FILE
VALIDATE $? "Unzip cart"


npm install &>>$LOG_FILE
VALIDATE $? "Installing dependencies"

cp $SCRIPT_DIR/cart.service /etc/systemd/system/cart.service
VALIDATE $? "Copy cart.services"

systemctl daemon-reload

systemctl enable cart &>>$LOG_FILE
VALIDATE $? "Enable cart"

systemctl start cart
VALIDATE $? "start cart"

systemctl restart cart
VALIDATE $? "Restarting cart"