function out=getCalibrationData(conn,mac,timeRange)
% this function retrieves an existing BLOB based on mac, reads it as a binary .mat file, and loads this temp file.
% timeRange is specified as a a 2x1 vector of datenums

out={};
str=sprintf('select data, to_char(timestamp,''mm-dd-yyyy hh24:mi''),comment,calibrationString from MONITOR_CALIBRATION where station_mac=''%s''',mac);
results=query(conn,str);
list=results(:,[2 3 4]);

for i=1:size(results,1)
    results{i,2}=datenum(results{i,2},'mm-dd-yyyy HH:MM');
end
which=find(cell2mat(results(:,2))>=timeRange(1)&cell2mat(results(:,2))<=timeRange(2));
ind=1;
if length(which)>1
    for i=1:length(which)
        dispStr=sprintf('%d\t%s\t%s',which(i),list{which(i),1},list{which(i),2});
        disp(dispStr);
    end
    validInput=false;
    while ~validInput
        dispStr=sprintf('select an entry (%d-%d):',which(1),which(end));
        ind=input(dispStr);
        if isnumeric(ind) && isscalar(ind) && length(find(which==ind))==1
            % pass
            validInput=true;
            ind=find(which==ind);
        end
    end
elseif isempty(which)
    error('failed to find any entries for the given mac address and timeRange');
end
c=results{which(ind),1};
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