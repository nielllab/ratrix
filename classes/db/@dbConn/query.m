function records = query(conn,queryString)

stmt = conn.conn.createStatement();
records = {};
curRow = 0;
failed = false;
try
    rs=stmt.executeQuery(queryString);
    try
        while rs.next()
            curRow = curRow + 1;
            metaData = rs.getMetaData();
            numColumns = metaData.getColumnCount();
            for i=1:numColumns
                c = rs.getObject(i);
                switch(class(c))
                    case 'java.math.BigDecimal'
                        convC = c.doubleValue();
                    case 'java.sql.Date'
                        % java.sql.Date is defined as 
                        % year - CalendarYear - 1900
                        % month - (0 to 11)
                        % day - (1 to 31)
                        convC = datenum(c.getYear()+1900,c.getMonth()+1,c.getDay());%,c.getHours(),c.getMinutes(),c.getSeconds());
                    case 'double'
                        convC = c;
                    case 'char'
                        convC = c;
                    case 'oracle.sql.BLOB'
%                         convC=c;
                        convC={};
                        stream=c.getBinaryStream;
                        nextbyte=stream.read();
                        while nextbyte~=-1
                            convC=[convC nextbyte];
                            nextbyte=stream.read();
                        end
                    otherwise
                        'Cannot handle'
                        class(c)
                        error('Cannot handle object type')
                end
                records{curRow,i}=convC;
            end
        end
        rs.close();
    catch ex
        rs.close();
        disp(['CAUGHT ERROR: ' getReport(ex,'extended')])
        failed = true;
    end
    stmt.close();
catch ex
    stmt.close();
    disp(['CAUGHT ERROR: ' getReport(ex,'extended')])
    failed = true;
end
% Make sure the statement and recordset are closed, now we can error if needed
if failed
    rethrow(ex)
end