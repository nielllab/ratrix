%listen to the parallel port address in a station
clear all

duration=15;  %number second to run sniffer

rootPath='C:\pmeier\Ratrix\'; pathSep='\';
warning('off','MATLAB:dispatcher:nameConflict')
addpath(genpath([rootPath 'Server' pathSep]));
warning('on','MATLAB:dispatcher:nameConflict')

r=ratrix([rootPath 'ServerData' pathSep],0);

%find a station
%subjectID='test';
%possibleIDs=getSubjectIDs(r)
%s=getSubjectFromID(r,subjectID);
%b=getBoxIDForSubjectID(r,getID(s));
b=1;
st=getStationsForBoxID(r,b);

start=getSecs;
timeElapsed=0; i=0; lastPlotTime=0;
while timeElapsed<duration
    i=i+1;
    timeElapsed=getSecs-start;
    %status=dec2bin(lptread(1+hex2dec(st.parallelPortAddress)))
    [ports status]=readPorts(st);
    recordPorts(i,1:size(ports,2))=ports;
    status
    recordStatus(i,1:size(status,2))=str2num(status(:))';
    pause(0.1)
    
    if timeElapsed-lastPlotTime>5
        lastPlotTime=getSecs;
        imagesc(recordStatus)
    end
end

[ports status portCodes]=readPorts(st)
sum(recordPorts)
sum(recordStatus)
imagesc(recordStatus)
'done'
beep