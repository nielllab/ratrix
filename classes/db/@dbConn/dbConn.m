function conn=dbConn
conn.host = 'reichardt.uoregon.edu'; %'184.171.84.11';
conn.port = '5433';
conn.user = 'postgres';
conn.password = 'password';
conn.driver='org.postgresql.Driver';
conn.database = 'subjectAdmin';
conn.name=''; % This must be left blank!

conn.url=['jdbc:postgresql://' conn.host ':' conn.port '/' conn.database];
conn.conn = openDBConnection(conn.driver,conn.url,conn.user,conn.password);

conn = class(conn,'dbConn');