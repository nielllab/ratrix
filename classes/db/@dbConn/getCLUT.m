function out=getCLUT(conn,mac)
% this function retrieves an existing BLOB based on mac, reads it as a binary .mat file, and loads this temp file.
out={};
str=sprintf('select data from CLUTS where station_mac=''%s''',mac);
results=query(conn,str);
if length(results)>1
    warning('found multiple CLUTs for the given mac address - using first entry!');
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

fid=fopen('tempCLUT.mat','w');
fwrite(fid,out);
fclose(fid);

out=load('tempCLUT.mat');

% if mod(length(bytes),8)~=0
%     error('got a BLOB with a number of bytes that doesnt divide by 8 - 8 bytes is one double');
%     out=[];
% else
%     out=typecast(bytes,'double');
% end
end % end function