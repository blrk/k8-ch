import smtplib
from email.message import EmailMessage
import os
import getpass

# Initial list of file names
output_files = ["t1.csv", "t2.csv"]

# Directory path to be added
directory_path = "~/"

# Iterate through the list and modify each item
for i in range(len(output_files)):
    output_files[i] = directory_path + output_files[i]



def send_email(subject, body, to, files=[]):
    # Email details
    sender_email = 'blrk.research@gmail.com'
    # Prompt the user to enter their password
    sender_password = getpass.getpass(prompt='Enter your password: ')

    # Create the email message
    msg = EmailMessage()
    msg['Subject'] = subject
    msg['From'] = sender_email
    msg['To'] = to
    msg.set_content(body)

    # Attach multiple files
    for file in files:
        with open(file, 'rb') as f:
            file_data = f.read()
            file_name = os.path.basename(file)
            msg.add_attachment(file_data, maintype='application', subtype='octet-stream', filename=file_name)

    # Send the email
    try:
        with smtplib.SMTP_SSL('smtp.gmail.com', 465) as smtp:
            smtp.login(sender_email, sender_password)
            smtp.send_message(msg)
        print("Email sent successfully")
    except Exception as e:
        print(f"Failed to send email: {e}")

# Example usage
send_email(
    subject='DevOps DOJO Score',
    body='This mail includes multiple file attachments. Each teams score is attached as csv with the correspoding team"s name ',
    to='blradhakrishnan@gmail.com',
    files=output_files
)
