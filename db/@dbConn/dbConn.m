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

odbcFile = 'classes12_g.jar';
[pathstr, name, ext, versn] = fileparts(mfilename('fullpath'));
dbPath = fileparts(pathstr);
odbcPath = fullfile(dbPath,odbcFile);
if ~any(strcmp(javaclasspath('-all'),odbcPath))
    javaaddpath(odbcPath);
else
    'Oracle JDBC classes12_g.jar file already present'
end


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

% This timeout must be set or the function will hang forever on a bad
% connection
logintimeout('oracle.jdbc.driver.OracleDriver',10);
conn.conn=database(conn.name,conn.user,conn.password,conn.driver,conn.url);
setdbprefs('DataReturnFormat','cellarray');

conn = class(conn,'dbConn');