function out=getCalibrationData(conn,mac)
% this function retrieves an existing BLOB based on mac, reads it as a binary .mat file, and loads this temp file.
out={};
str=sprintf('select data, to_char(timestamp,''mm-dd-yyyy hh24:mi'') from MONITOR_CALIBRATION where station_mac=''%s''',mac);
results=query(conn,str);
if size(results,1)>1
    warning('found multiple entries for the given mac address - using first entry!');
end
c=results{1};
stream=c.getBinaryStream;
nextbyte=stream.read();
while nextbyte~=-1
    out=[out nextbyte];
    nextbyte=stream.read();
end
out=cell2mat(out);
out=uint8(out);

fid=fopen('tempdata.mat','w');
fwrite(fid,out);
fclose(fid);

out=load('tempdata.mat');
end % end function