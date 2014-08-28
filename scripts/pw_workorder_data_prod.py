import pandas as pd
import numpy as np
import psycopg2
from pandas import DataFrame
from datetime import datetime, date
import collections
import re
import dataclean as dc
import sys
import traceback
import smtplib
import ConfigInfo as cf

try:
    #buildings Data
    url = cf.wo_url

    start = datetime.now()
    data = dc.jsonToFrame(url)

    #Cleaning Data
    data = dc.cleanData(data)
    data = data.applymap(lambda x: x.replace('\n','').replace('\r','').replace(';','').replace("\\","") if isinstance(x,(str, unicode)) else x)
    conn = psycopg2.connect("host={0} dbname={1} user={2} password ={3} sslmode=allow".format(cf.chartio_host,cf.chartio_db,cf.chartio_id,cf.chartio_pwd))

    dc.writeFrame(conn,'pw_workorder',data)

    conn.close()
    end = datetime.now()

    print end - start
    print 'Done'

except:
    exc_type, exc_value, exc_traceback = sys.exc_info()
    lines = traceback.format_exception(exc_type, exc_value, exc_traceback)
    error_log = ''.join('!! ' + line for line in lines)

    #sending email of error log
    sender = cf.gmail_id
    receivers = [cf.recip]
    message = """From: Linux Box <{0}>\nTo:<{1}>\nSubject: ERROR LOG-FAIL TO WRITE {2}\n\nError message: {3}.""".format(cf.gmail_id,cf.recip,'pw_workorder', error_log)
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
