#!/usr/bin/python
# coding=utf-8
__author__ = 'steve'

import smtplib

# Import the email modules we'll need
from email.mime.text import MIMEText

print("Hello World!")
sender ='523216892@163.com'
receiver = '523216892@qq.com'
subject = 'PythonMail Test'

smtp_host = 'smtp.163.com'
smtp_port = 25
password = '*'


msg = MIMEText('hello, Python!')
msg['Subject'] = subject
msg['from'] = sender
msg['to'] = receiver
#msg['From'] = '<' + sender + '>'
#msg['To'] = '<' + receiver +'>'


smtp = smtplib.SMTP(smtp_host,timeout=30)
#smtp.connect(smtp_host,smtp_port)
smtp.login(sender,password)
smtp.sendmail(sender,receiver,msg.as_string())
smtp.close()
print("Successful")
