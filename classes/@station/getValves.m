function [valves status valveCodes] =getValves(s)
if strcmp(s.responseMethod,'parallelPort')

    status=dec2bin(lptread(hex2dec(s.parallelPortAddress)),8); 

    valves=status(s.valveOpenCodes)=='1'; %need to set parity in station, assumes NC valves
    valveCodes=s.valveOpenCodes;
else
    warning('can''t read ports without parallel port')
    valves=zeros*s.valveOpenCodes;
end