import psycopg2
import ConfigInfo as cf

f = open("/home/schoi/etl/queries/lease_signings_analytics.sql",'r')
query = "".join(i for i in f.read() if ord(i)<128)

con = psycopg2.connect("host={0} dbname={1} user={2} password={3}".format(cf.chartio_host,cf.chartio_db,cf.chartio_id,cf.chartio_pwd))
cur = con.cursor()
cur.execute("DROP TABLE IF EXISTS analytics.lease_signings;")
cur.execute("CREATE TABLE analytics.lease_signings AS " + query + ";")
cur.execute("GRANT ALL ON TABLE analytics.lease_signings TO GROUP reporting_role;")
cur.execute("create index on analytics.lease_signings ((lease_signings.prospect_id));")
con.commit()

cur.close()
con.close()
