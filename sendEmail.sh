#!usr/bin/env bash

# User input
#read -p "Enter your email : " sender
#>cmd /c ""C:\Program Files\Git\bin\bash.exe" --login -i -- C:\Users\ththc\Desktop\sideproject\sendEmail.sh"
#to run in task scheduler
#program/script
#"C:\Program Files\Git\bin\bash.exe"
#Add arguments
#--login -i -- C:\Users\ththc\Desktop\sideproject\sendEmail.sh
#max admin previlege

gapp="gokuladitya13@gmail.com:ubxdpxsvssgspupm";
sender="gokuladitya13@gmail.com";
recipients="gokuladitya2@gmail.com,suksesh164@gmail.com";
#split comma sepearated emailid in array
IFS=', ' read -r -a array <<< "$recipients";
sub="test sub";
body="this is a test messsage";

(echo -e "From: ${sender} \nTo: ${recipients} \nSubject:${sub} \n\n${body}")>emailTemplate.txt




#store curl cmd for multiple address
cmd="curl --ssl-reqd --url "smtps://smtp.gmail.com:465" --user "${gapp}" --mail-from \"${sender}\" --upload-file emailTemplate.txt"

for element in "${array[@]}"
do
    cmd+=" --mail-rcpt \"${element}\""
done

echo $cmd
#execute curl cmd
$cmd