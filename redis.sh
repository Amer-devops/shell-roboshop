dnf module disable redis -y
VALIDATE $? "Disable redis"

dnf module enable redis:7 -y
VALIDATE $? "Enable redis 7"

dnf install redis -y 
VALIDATE $? "Install redis"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis/redis.conf
VALIDATE $? "Allowing remote connections to redis"

systemctl enable redis
VALIDATE $? "Enable redis"

systemctl start redis 
VALIDATE $? "start redis"