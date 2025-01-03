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
#installing/configuring db
echo "please wait installing mysql-server"

dnf install mysql-server -y &>>$LOGFILE
VALIDATE $? "installing mysql.."

systemctl enable mysqld &>>$LOGFILE
VALIDATE $? "enabling mysql.."

systemctl start mysqld &>>$LOGFILE
VALIDATE $? "starting mysql.."

mysql -h db.hellandhaven.xyz -uroot -p${db_root_password} -e 'show databases;' &>>LOGFILE

if [ $? -ne 0 ]
then
    mysql_secure_installation --set-root-pass ${db_root_password} &>>LOGFILE
    VALIDATE $? "Db_root_password is creation.."
else
    echo -e "db password is already exist....$Y SKIPPING $N"
fi


