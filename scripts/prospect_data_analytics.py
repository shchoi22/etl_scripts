import psycopg2
import ConfigInfo as cf

f = open("/home/schoi/etl/queries/prospect_data_dump_second_V0.4_2.4.14_sc.sql",'r')
query = "".join(i for i in f.read() if ord(i)<128)

con = psycopg2.connect("host={0} dbname={1} user={2} password={3}".format(cf.chartio_host,cf.chartio_db,cf.chartio_id,cf.chartio_pwd))
cur = con.cursor()
cur.execute("DROP TABLE IF EXISTS analytics.prospects;")
cur.execute("CREATE TABLE analytics.prospects AS " + query + ";")
cur.execute("GRANT ALL ON TABLE analytics.prospects TO GROUP reporting_role;")
con.commit()

cur.close()
con.close()
