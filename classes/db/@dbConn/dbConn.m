function conn=dbConn(host,port,user,password)
% dbConn  class constructor.
% 
% Create a persistent connection to Oracle database
%
% conn = dbConn(id, path)
conn.host = '132.239.158.177'; % Default Oracle DB Server address
conn.port = '1521' % Default Oracle DB Port
conn.user = 'dparks';
conn.password = 'pac3111';
conn.driver='oracle.jdbc.driver.OracleDriver';
conn.service = 'XE';
conn.name=''; % This must be left blank!

if exist('host')
    conn.host = host;
end
if exist('port')
    if ~ischar(port)
        conn.port = sprintf('%d',port) % Turn port into a string
    else
        conn.port = port;
    end
end
if exist('user','var') % IMPORTANT 'user' is a type in exist
    conn.user = user;
end
if exist('password')
    conn.password = password;
end

conn.url=['jdbc:oracle:thin:/' conn.user '/' conn.password '@//' conn.host ':' conn.port '/' conn.service];

% Load driver and then create db connection
conn.conn = openDBConnection(conn.driver,conn.url,conn.user,conn.password);

conn = class(conn,'dbConn');