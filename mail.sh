#!/bin/bash
# teams
teams=("t1" "t2")
# Define the output CSV file
output_files=("t1.csv" "t2.csv")

# Variables
recipient="blradhakrishnan@gmail.com"
subject="K8 Challenge Scores"
body="Please find the attachement"
#path="~/"
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


