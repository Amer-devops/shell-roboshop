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
MYSQL_HOST=mysql.daws86s.icu
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


dnf module disable nginx -y
VALIDATE $? "Disable nginx"

dnf module enable nginx:1.24 -y
VALIDATE $? "Enable nginx"

dnf install nginx -y
VALIDATE $? "Installing nginx"

systemctl enable nginx 
VALIDATE $? "Enable nginx"

systemctl start nginx 
VALIDATE $? "Start nginx"

rm -rf /usr/share/nginx/html/* 

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip
VALIDATE $? "Downloading nginx"

cd /usr/share/nginx/html 

unzip /tmp/frontend.zip
VALIDATE $? "Unzip nginx"

rm -rf /etc/nginx/nginx.conf

cp frontend.service /nginx.conf /etc/nginx/nginx.conf


systemctl restart nginx 
