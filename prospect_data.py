import os
import sys
import traceback
import smtplib

try:
   #Data pull, clean, and write to public as raw data
   os.system("python ./scripts/prospect_data_public.py")

   #Data write to analytics as processed data
   os.system("python ./scripts/prospect_data_analytics.py")
except:
   exc_type, exc_value, exc_traceback = sys.exc_info()
   lines = traceback.format_exception(exc_type, exc_value, exc_traceback)
   error_log = ''.join('!! ' + line for line in lines)

   #sending email of error log
   sender = cf.gmail_id
   receivers = [cf.recip]
   message = """From: Linux Box <{0}>\nTo:<{1}>\nSubject: ERROR LOG-FAIL TO WRITE {2}\n\nError Message: {3}.""".format(cf.gmail_id,cf.recip,'prospect_data',error_log)
   try:
       session = smtplib.SMTP('smtp.gmail.com',587)
       session.ehlo()
       session.starttls()
       session.ehlo()
       session.login(sender,cf.gmail_pwd)
       session.sendmail(sender, receivers, message)
       print "Successfully sent email"
   except smtplib.SMTPException:
       print "Error: unable to send email"


