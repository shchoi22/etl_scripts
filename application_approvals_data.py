import os
import sys
import traceback
import smtplib
import MailingInfo as mf

try:
   #Data pull, clean, and write to public as raw data
   os.system("python /home/schoi/etl/scripts/application_approvals_public.py")

   #Data write to analytics as processed data
   os.system("python /home/schoi/etl/scripts/application_approvals_analytics.py")
except:
   exc_type, exc_value, exc_traceback = sys.exc_info()
   lines = traceback.format_exception(exc_type, exc_value, exc_traceback)
   error_log = ''.join('!! ' + line for line in lines)

   #sending email of error log
   sender = mf.gmail_id
   receivers = [mf.recip_error]
   message = """From: Linux Box <{0}>\nTo:<{1}>\nSubject: ERROR LOG-FAIL TO WRITE {2}\n\nError Message: {3}.""".format(mf.gmail_id,mf.recip,'application_approvals_data',error_log)
   try:
       session = smtplib.SMTP('smtp.gmail.com',587)
       session.ehlo()
       session.starttls()
       session.ehlo()
       session.login(sender,mf.gmail_pwd)
       session.sendmail(sender, receivers, message)
       print "Successfully sent email"
   except smtplib.SMTPException:
       print "Error: unable to send email"


