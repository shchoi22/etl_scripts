import psycopg2
import ConfigInfo as cf

f = open("/home/schoi/etl/queries/lease_analytics.sql",'r')
query = "".join(i for i in f.read() if ord(i)<128)

con = psycopg2.connect("host={0} dbname={1} user={2} password={3}".format(cf.chartio_host,cf.chartio_db,cf.chartio_id,cf.chartio_pwd))
cur = con.cursor()
cur.execute("DROP TABLE IF EXISTS analytics.leases;")
cur.execute("CREATE TABLE analytics.leases AS " + query + ";")
cur.execute("GRANT ALL ON TABLE analytics.leases TO GROUP reporting_role;")
cur.execute("create index on analytics.leases ((leases.lease_name));")
con.commit()

cur.close()
con.close()
