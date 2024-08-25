#!/bin/bash
# teams
#teams=("T1" "T2" "T3" "T4" "T5" "T6" "T7" "T8" "T9" "T10" "T11" "T12" "T13" "T14" "T15" "T16" "T17" "T18" "T19" "T20")
#namespaces=("default")
teams=("T1" "T2" "T3" "T4" "T5")
# Define the output CSV file
output_files=("t1.csv" "t2.csv" "t3.csv" "t4.csv" "t5.csv" "t6.csv" "t7.csv" "t8.csv" "t9.csv" "t10.csv" "t11.csv" "t12.csv" "t13.csv" "t14.csv" "t15.csv" "t16.csv" "t17.csv" "t18.csv" "t19.csv" "t20.csv")
output_files=("t1.csv" "t2.csv" "t3.csv" "t4.csv" "t5.csv")

# Variables
recipient="blradhakrishnan@gmail.com"
subject="K8 Challenge Scores"
body="Please find the attachement"
#path="/home/ubuntu"
path="/root/"
attachments=()

# Adding file names
for ((i=0; i<${#teams[@]}; i++)); do
    team=${teams[$i]}    
    output_file=${output_files[$i]}
    fname="$path"
    fname+="$output_file"
    attachments+=( "$fname" )
done

echo "set smtp=smtp://smtp.gmail.com:587" >> ~/.mailrc
echo "set smtp-auth-user=blradhakrishnan@gmail.com" >> ~/.mailrc
echo "enter your pass"
read -s pass
echo "set smtp-auth-password=$pass" >> ~/.mailrc
echo "set smtp-auth=login" >> ~/.mailrc
echo "set ssl-verify=ignore" >> ~/.mailrc

# Create the mail command
mail_command="echo \"$body\" | mailx -s \"$subject\""

# Add each attachment to the mail command
for attachment in "${attachments[@]}"; do
    mail_command+=" -a \"$attachment\""
done

# Add the recipient to the mail command
mail_command+=" \"$recipient\""

# Execute the mail command
eval $mail_command


