#!usr/bin/env bash

#To run bash script using git bash in cmd prompt run below command
#cmd /c ""C:\Program Files\Git\bin\bash.exe" --login -i -- C:\Users\ththc\Desktop\sideproject\sendEmail.sh"
#To run using task scheduler every week
#create Task/Basic Task n task scheduler
#check Run only when user is logged in security options accordingly
#check Run with highest previleges in security options to avois permission related issues
#Actions will be start a program
#program/script value will be: "C:\Program Files\Git\bin\bash.exe" (path of gitbash.exe )
#Add arguments will be: --login -i -- C:\Users\ththc\Desktop\sideproject\sendEmail.sh

#region to get email ids of tickets in respective condition
# Set the API endpoint and request headers
url="https://dev.azure.com/gokuladitya/Test%20Email%20Notification/_apis/wit/wiql?api-version=7.0"; 
preurl="https://dev.azure.com/gokuladitya/Test%20Email%20Notification/_apis/wit/workitems/";
posturl="?api-version=7.0";
headers="Content-Type: application/json";
token="poj3by6ch6kewgclokb5nonh6gnzcpds7azd3gavb2r3q6h3gwka";
# WIQL query to retrieve work item IDs in the Active state
#Today - 14 should be changed accrodingly on how many days should have passed being in that state i.e. in that state for more than 14 days
query='{"query": "SELECT [System.Id], [System.Title], [System.State] FROM WorkItems WHERE [System.State] = '\''Active'\'' AND [System.ChangedDate] <= @Today - 14"}'
# Make the API request
response=$(curl -u ":$token" -s -H "$headers" -X POST --data "$query" "$url")
# Extract the work item IDs from the response using pattern matching
ids="";
emailIds="";
ids+=$(echo $response | grep -oP '(?<=id":)[0-9]+' | tr '\n' ' ');
# Print the IDs
for id in $ids; do
	url2=$preurl$id$posturl;
	response=$(curl -u ":$token" -s -H "$headers" -X GET "$url2");
	emailIds+=$(echo "$response" | sed -n 's/.*"uniqueName":"\([^"]*\).*/\1/p')";";
done
echo $emailIds;

#region to send email to emailids in gmail 
gapp="gokuladitya13@gmail.com:ubxdpxsvssgspupm";
sender="gokuladitya13@gmail.com";
#recipients="gokuladitya2@gmail.com,suksesh164@gmail.com";
#split comma sepearated emailid in array
IFS='; ' read -r -a array <<< "$emailIds";
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


<<comm
# Set the API endpoint and request headers
endpoint="https://gokuladitya.visualstudio.com/Test%20Email%20Notification/_queries/query/?tempQueryId=8da4cd07-6ad1-4fe9-b648-f3f859c7a365"
headers="Content-Type: application/json"
token="Bearer l66hk3amfr6o2bsimfaykngi4aahgisxmb6q5dk2qfqnajdpstwa"

# Make the API call and get the response
response=$(curl -s -H "$headers" -H "Authorization: $token" -X GET "$endpoint")

# Extract the uniqueName field using grep and awk
email_addresses=($(echo "$response" | grep -oP '(?<="uniqueName": ")[^"]+' | awk -F "@" '{print $1 "@" $2}' | awk '{print tolower($0)}'))
echo $email_addresses
echo $response


# Extract the email addresses of the assignees from the response
for email_address in "${email_addresses[@]}"; do
    email_address=$(echo "$email_address" | awk -F "@" '{print $1 "@" $2}' | sed 's/.*/\L&/')
	cmd+=" --mail-rcpt \"${email_address}\""
    echo "$email_address"
done

echo $cmd
#execute curl cmd
$cmd
comm

