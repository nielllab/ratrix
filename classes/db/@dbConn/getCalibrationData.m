function out=getCalibrationData(conn,mac)
% this function retrieves an existing BLOB based on mac, reads it as a binary .mat file, and loads this temp file.
out={};
str=sprintf('select data from MONITOR_CALIBRATION where station_mac=''%s''',mac);
results=query(conn,str);
if length(results)>1
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