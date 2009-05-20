function updateCalibrationData(conn,mac,timestamp,newdata)
% this function updates the BLOB object associated with the given mac address and timestamp
% empties the existing BLOB and replaces it with newdata, a vector of uint8s
% the given mac/timestamp should ALWAYS exist, because we never call this directly
% this is a function that gets called by addCLUTToOracle, which does an INSERT first, then a select for update


% first remove the existing BLOB
str=sprintf('update MONITOR_CALIBRATION set data=empty_blob() where station_mac=''%s'' and timestamp=to_date(''%s'',''mm-dd-yyyy hh24:mi'')',mac,timestamp);
r=exec(conn,str);

% now select the BLOB for updating
str=sprintf('select data from MONITOR_CALIBRATION where station_mac=''%s'' and timestamp=to_date(''%s'',''mm-dd-yyyy hh24:mi'') FOR UPDATE',mac,timestamp);
% str=sprintf('select data from CLUTS where station_mac=''%s''',mac);
results=query(conn,str);
blob=results{1};
% blob.length


if strcmp(class(newdata),'uint8')
    blob.putBytes(length(blob)+1,newdata);
%     blob.length
else
    error('newdata must be uint8');
end

%5/12/09
% for some reason, the executeUpdate statement will hang if you have SQL developer open.
% i think this has to do with access issues to BLOB entries (when you close SQL developer, the statement finishes executing).
% happens if you've used the CLUTs table in oracle (for example, to delete an entry).
% i think for now it is okay to just assume that sql developer is not accessing CLUTS, but what about when calibrateMonitor 
% automaticallys calls updateCLUT?
str=sprintf('update MONITOR_CALIBRATION set data=? where station_mac=''%s'' and timestamp=to_date(''%s'',''mm-dd-yyyy hh24:mi'')',mac,timestamp);
ps = conn.conn.prepareStatement(str);
ps.setBlob(1,blob);
ps.executeUpdate();
ps.close();

end % end function