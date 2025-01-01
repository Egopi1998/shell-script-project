USERID=$(id -u)  #when we run id -u we get user id and store it to USERID
TIMESTAMP=$(date +%F-%H-%M)
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOGFILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
echo " please enter your db password"
read -s db_root_password
VALIDATE(){
    if [ $1 -eq 0 ]
    then
        echo -e "$2..$G SUCCESS $N "
    else
        echo -e "$2 ...$R FAILED $N "
        exit 1
    fi
}

if [ $USERID -ne 0 ] # 0 is for root, if it is not value will be 1001, 1002 etc..
then
    echo "you are not a super user please ensure you are using sudo for your commands"
    exit 1  #exiting manually 
else
    echo "you are super user, please wait i am processing your request"
fi             # fi means exiting from if loop

dnf module disable nodejs -y &>>$LOGFILE
VALIDATE $? "Disabling the nodejs is ..." #it will disable the default nodejs version

dnf module enable nodejs:20 -y &>>$LOGFILE
VALIDATE $? "enabling nodejs:20 is ..."

dnf install nodejs -y &>>$LOGFILE
VALIDATE $? "nodejs installation is..."

id -u expense
if[ $? -eq 0 ]
then
    echo -e "user Expense is already Exist .. $Y SKIPPING $N"
else 
    useradd expense
    VALIDATE $? "user expense creation.."
fi

rm -rf /app &>>$LOGFILE
VALIDATE $? "removing old /app directory.."

mkdir /app &>>$LOGFILE
VALIDATE $? "creating new /app directory.."

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$LOGFILE
VALIDATE $? "downloading backend.zip.."

cd /app &>>$LOGFILE
VALIDATE $? "changing directory to /app .."

unzip /tmp/backend.zip &>>$LOGFILE
VALIDATE $? "unzip to /app .."

npm install &>>$LOGFILE
VALIDATE $? "npm install .."

cp /home/ec2-user/shell-script-project/backend.service /etc/sustemd/system/default.d/backend.service &>>$LOGFILE
VALIDATE $? "copying backend.service .."

systemctl daemon-reload &>>$LOGFILE
VALIDATE $? "daemon-reload .."

systemctl start backend &>>$LOGFILE
VALIDATE $? "starting the backend .."

systemctl enable backend &>>$LOGFILE
VALIDATE $? "backend service enable .."

dnf install mysql -y &>>$LOGFILE
VALIDATE $? "installing mysql .."

mysql -h db.hellandhaven.xyz -uroot -p${db_root_passowrd} < /app/schema/backend.sql &>>$LOGFILE
VALIDATE $? "schema loading ..."

systemctl restart backend &>>$LOGFILE
VALIDATE $? "backend service restart .."


