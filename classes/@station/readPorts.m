function [ports status portCodes] =readPorts(s)
if strcmp(s.responseMethod,'parallelPort')
    status=dec2bin(lptread(1+hex2dec(s.parallelPortAddress)),8); %didn't i fix this 8 thing?
    %status
    ports=status(s.portCodes)=='0'; %used to be 1 -- need to set parity in station 
    portCodes=s.portCodes;
else
    s.responseMethod
    warning('can''t read ports without parallel port')
    ports=zeros(1,s.numPorts);
end