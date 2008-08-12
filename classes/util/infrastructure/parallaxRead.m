

port='COM1';
config='BaudRate=2400 DataBits=8 Parity=None StopBits=1 DTR=1';
handle = IOPort('OpenSerialPort',port,config);
block=false;
if handle>=0
    while ~kbcheck
        x=GetSecs;
        [data, when, errmsg] = IOPort('Read', handle, double(~block));
        y=GetSecs-x;
        if ~isempty(data)
            if data(1)==hex2dec('0A') && data(end)==hex2dec('0D')
                fprintf('got %s at %g, %g elapsed\n',char(data(2:end-1)),when,y);
            else
                data
                warning('unexpected message format')
            end
        end
        if ~isempty(errmsg)
            errmsg
            warning('ioport error')
        end
    end
    IOPort('Close', handle);
else
    handle
    error('couldn''t open serial port')
end









alreadies=instrfind;
if ~isempty(alreadies)
    fclose(alreadies)
    delete(alreadies)
end

s = serial('COM1','BaudRate',2400,'Timeout',.0001);
fopen(s);
while ~kbcheck
    warning('off','MATLAB:serial:fscanf:unsuccessfulRead');
    x=GetSecs;
    t=fscanf(s);
    y=GetSecs-x;
    warning('on','MATLAB:serial:fscanf:unsuccessfulRead');
    if ~isempty(strtrim(t))
        fprintf('got %s, %g elapsed\n',strtrim(t),y);
    end
end
fclose(s)