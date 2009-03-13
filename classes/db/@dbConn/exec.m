function rowCount = exec(conn,execString)

stmt = conn.conn.createStatement();

try
    rowCount = stmt.executeUpdate(execString);
    stmt.close();
catch ex
    stmt.close();
    rethrow(ex)
end