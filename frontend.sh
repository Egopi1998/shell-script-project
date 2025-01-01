USERID=$(id -u)  #when we run id -u we get user id and store it to USERID
TIMESTAMP=$(date +%F-%H-%M)
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOGFILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
VALIDATE(){
    if [ $1 -eq 0 ]
    then
        echo -e " $2..$G SUCCESS $N"
    else
        echo -e " $2 ..$R FAILED $N"
        exit 1
    fi
}

if [ $USERID -ne 0 ] # 0 is for root, if it is not value will be 1001, 1002 etc..
then
    echo "you are not a super user please ensure you are using sudo for your commands"
    exit 1  #exiting manually 
else
    echo "you are super user, please wait i am processing your request"
fi 
dnf install nginx -y &>>$LOGFILE
VALIDATE $? "installation of nginx.."

systemctl enable nginx 
VALIDATE $? "enable of nginx.."

systemctl start nginx
VALIDATE $? "starting of nginx.."

rm -rf /usr/share/nginx/html/*
VALIDATE $? "removing of olg html file.."

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip
VALIDATE $? "downloading of frontend code.."

cd /usr/share/nginx/html
VALIDATE $? "changing to directory /usr/share/nginx/html.."

unzip /tmp/frontend.zip
VALIDATE $? "frontend code extracting to the /usr/share/nginx/html.."

cp /home/ec2-user/shell-script-project/expense.conf /etc/nginx/default.d/expense.conf &>>$LOGFILE
VALIDATE $? "Copied expense conf"

systemctl restart nginx
VALIDATE $? "restarting of nginx.."