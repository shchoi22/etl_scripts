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
    start = datetime.now()
    f = open("/home/schoi/etl/queries/lease_signings_public.sql",'r')
    query = "".join(i for i in f.read() if ord(i)<128)

    con_pangea = psycopg2.connect("host={0} dbname={1} user={2} password={3}".format(cf.pangea_api_host,cf.pangea_api_db,cf.pangea_api_id,cf.pangea_api_pwd))
    con_chartio = psycopg2.connect("host={0} dbname={1} user={2} password={3} sslmode=allow".format(cf.chartio_host,cf.chartio_db,cf.chartio_id,cf.chartio_pwd))

    cur_pangea = con_pangea.cursor()
    cur_chartio = con_chartio.cursor()

    cur_pangea.execute(query)
    data = cur_pangea.fetchall()

    column = [desc[0] for desc in cur_pangea.description]

    data2 = pd.DataFrame(data,columns=column)
    data2 = data2.applymap(lambda x: x.replace('\n','').replace('\r','').replace(';','').replace("\\","") if isinstance(x,(str, unicode)) else x)
    
    #dc.writeFrame(con_chartio,'public.application_approvals',data2)
    data2.to_csv('lease_signings'+'output.csv', sep=';', na_rep='', cols=None, header=False, index=False)

    cur_chartio.execute("TRUNCATE TABLE " + 'public.lease_signings')
    #con_chartio.commit()
    cur_chartio.execute("DROP TABLE IF EXISTS " + 'public.lease_signings')
    #con_chartio.commit()
    cur_chartio.execute("CREATE TABLE " + 'public.lease_signings' +'()')
    con_chartio.commit()

    for column in data2.columns:
        cur_chartio.execute("ALTER TABLE public.lease_signings ADD COLUMN " + column.lower() + " text;")
        con_chartio.commit()

    columnString = ','.join(data2.columns)

    cur_chartio.copy_from(open('lease_signings'+'output.csv','r'), 'public.lease_signings', sep=';', null = 'NA', columns=None)
    con_chartio.commit()

    cur_chartio.execute("GRANT ALL ON TABLE public.lease_signings TO GROUP reporting_role;")
    con_chartio.commit()

    cur_pangea.close()
    cur_chartio.close()
    con_pangea.close()
    con_chartio.close()

    print datetime.now() - start
    print 'Done'
except:
    exc_type, exc_value, exc_traceback = sys.exc_info()
    lines = traceback.format_exception(exc_type, exc_value, exc_traceback)
    error_log = ''.join('!! ' + line for line in lines)

    #sending email of error log
    sender = cf.gmail_id
    receivers = [cf.recip]
    message = """From: Linux Box <{0}>\nTo:<{1}>\nSubject: ERROR LOG-FAIL TO WRITE {2}\n\nError message: {3}.""".format(cf.gmail_id,cf.recip,'lease_signings_public', error_log)
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
