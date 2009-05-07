function out=getBLOB(conn,mac)
% this function retrieves an existing BLOB based on mac
% and reads it into a double-precision matrix
% (converts from BLOB bytes)

str=sprintf('select data from CLUTS where station_mac=''%s''',mac);
results=query(conn,str);
bytes=cell2mat(results{1});
bytes=uint8(bytes);

if mod(length(bytes),8)~=0
    error('got a BLOB with a number of bytes that doesnt divide by 8 - 8 bytes is one double');
    out=[];
else
    out=typecast(bytes,'double');
end
end % end function