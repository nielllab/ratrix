function updateBLOB(conn,mac,newdata)
% this function updates the BLOB object associated with the given mac address
% empties the existing BLOB and sets it to newdata, where newdata is a matlab double array

% first remove the existing BLOB
str=sprintf('update CLUTS set data=empty_blob() where station_mac=''%s''',mac);
exec(conn,str);

% now select the BLOB for updating
str=sprintf('select data from CLUTS where station_mac=''%s''FOR UPDATE',mac);
% str=sprintf('select data from CLUTS where station_mac=''%s''',mac);
results=query(conn,str);
blob=results{1};
blob.length

w=typecast(newdata,'uint8'); % an array of 8 bytes, each an uint8
blob.putBytes(length(blob)+1,w); % puts the 8 bytes in w at the end of the BLOB a
blob.length

str=sprintf('update CLUTS set data=? where station_mac=''%s''',mac);
ps = conn.conn.prepareStatement(str);
ps.setBlob(1,blob);
ps.executeUpdate();
ps.close();

end % end function