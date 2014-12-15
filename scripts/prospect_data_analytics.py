import psycopg2
import ConfigInfo as cf

try:
	f = open("/home/schoi/etl/queries/prospect_data_dump_second_V0.4_2.4.14_sc.sql",'r')
	query = "".join(i for i in f.read() if ord(i)<128)

	con = psycopg2.connect("host={0} dbname={1} user={2} password={3}".format(cf.chartio_host,cf.chartio_db,cf.chartio_id,cf.chartio_pwd))
	cur = con.cursor()
	cur.execute("DROP TABLE IF EXISTS analytics.prospects;")
	cur.execute("CREATE TABLE analytics.prospects AS " + query + ";")
	cur.execute("GRANT ALL ON TABLE analytics.prospects TO GROUP reporting_role;")
	cur.execute("create index on analytics.prospects ((prospects.prospect_id));")
	con.commit()
	cur.execute("create index on analytics.prospects ((prospects.applicant_id));")
	con.commit()
	cur.execute("create index on analytics.prospects ((prospects.application_id));")
	con.commit()
	cur.execute("create index on analytics.prospects ((prospects.lease_name));")
	con.commit()

	cur.close()
	con.close()
except:
	exc_type, exc_value, exc_traceback = sys.exc_info()
	lines = traceback.format_exception(exc_type, exc_value, exc_traceback)
	error_log = ''.join('!! ' + line for line in lines)
	
	#sending email of error log
	sender = cf.gmail_id
	receivers = [cf.recip]
	message = """From: Linux Box <{0}>\nTo:<{1}>\nSubject: ERROR LOG-FAIL TO WRITE {2}\n\nError message: {3}.""".format(cf.gmail_id,cf.recip,'pcore_prospect_analytics', error_log)
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