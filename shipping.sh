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


dnf install maven -y
VALIDATE $? "Installing Maven"

useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
VALIDATE $? "Adding system user"

mkdir -p /app 
VALIDATE $? "Create app directory"

curl -L -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip 
VALIDATE $? "Downloading shiiping zip"

cd /app 
VALIDATE $? "Change to aap directory"

unzip /tmp/shipping.zip
VALIDATE $? "Unzipping to temp"


mvn clean package 
VALIDATE $? "Installing package"

mv target/shipping-1.0.jar shipping.jar 
VALIDATE $? "Installing dependencies"

systemctl daemon-reload

systemctl enable shipping 
VALIDATE $? "Enabling shipping "

systemctl start shipping
VALIDATE $? "Starting shipping"


dnf install mysql -y 
VALIDATE $? "Installing mysql client"


mysql -h <MYSQL-SERVER-IPADDRESS> -uroot -pRoboShop@1 < /app/db/schema.sql
VALIDATE $? "Loading schema"

mysql -h <MYSQL-SERVER-IPADDRESS> -uroot -pRoboShop@1 < /app/db/master-data.sql
VALIDATE $? "Creating app user"


mysql -h <MYSQL-SERVER-IPADDRESS> -uroot -pRoboShop@1 < /app/db/master-data.sql
VALIDATE $? "Loading master data"


systemctl restart shipping
VALIDATE $? "Restarting shipping services"