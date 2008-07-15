function conn=openDBConnection(driver,url,user,password)

cloader = java.lang.ClassLoader.getSystemClassLoader;
cloader.loadClass(driver);
java.lang.Class.forName(java.lang.String(driver),true,cloader);
%import oracle.jdbc.driver.OracleDriver

% This timeout must be set or the function will hang forever on a bad
% connection
java.sql.DriverManager.setLoginTimeout(10);

conn=java.sql.DriverManager.getConnection(url,user,password);