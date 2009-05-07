function clearBLOB(conn,mac)
% this function clears an existing BLOB by mac address

% first remove the existing BLOB
str=sprintf('update CLUTS set data=empty_blob() where station_mac=''%s''',mac);
exec(conn,str);


end % end function