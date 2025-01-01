USERID=$(id -u)  #when we run id -u we get user id and store it to USERID
TIMESTAMP=$(date +%F-%H-%M)
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOGFILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log
R=”\e[31m”
G=”\e[32m”
Y=”\e[33m”
N=”\E[0m”
echo " please enter your db password"
read -s db_root_password
VALIDATE(){
    if [ $1 -el 0 ]
    then
        echo " $2..$G SUCCESS $N "
    else
        echo " $2 ...$R FAILED $N"
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

dnf module disable nodejs -y
VALIDATE $? "Disabling the nodejs is ..." #it will disable the default nodejs version

dnf module enable nodejs:20 -y
VALIDATE $? "enabling nodejs:20 is ..."

dnf install nodejs -y
VALIDATE $? "nodejs installation is..."

id -u expense
if[ $? -el 0 ]
then
    echo "user Expense is already Exist .. $Y SKIPPING $N"
else 
    useradd expense
    VALIDATE $? "user expense creation.."
fi

rm -rf /app
VALIDATE $? "removing old /app directory.."

mkdir /app
VALIDATE $? "creating new /app directory.."

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip
VALIDATE $? "downloading backend.zip.."

cd /app
VALIDATE $? "changing directory to /app .."

unzip /tmp/backend.zip
VALIDATE $? "unzip to /app .."

npm install
VALIDATE $? "npm install .."

cp ./shell-script-project/backend.service /etc/sustemd/system/default.d/backend.service
VALIDATE $? "copying backend.service .."

systemctl daemon-reload
VALIDATE $? "daemon-reload .."

systemctl start backend
VALIDATE $? "starting the backend .."

systemctl enable backend
VALIDATE $? "backend service enable .."

dnf install mysql -y
VALIDATE $? "installing mysql .."

mysql -h db.hellandhaven.xyz -uroot -p${db_root_passowrd} < /app/schema/backend.sql
VALIDATE $? "schema loading ..."

systemctl restart backend
VALIDATE $? "backend service restart .."


