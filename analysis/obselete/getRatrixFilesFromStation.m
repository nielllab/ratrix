%getRatrix 'Server' folder for source control

%for multiple stations
    stationIP{1}='192.168.0.101';
    stationIP{2}='192.168.0.102';
    stationIP{3}='192.168.0.103';
    stationIP{4}='192.168.0.104';
    stationIP{9}='192.168.0.109';
    stationIP{11}='192.168.0.111'
    
%stationIP{1}='192.168.0.101'
numStations=size(stationIP,2);
selectedStations=[1:numStations];  %(does all but could be just 1 or some)
selectedStations=[1 2 3 4 9 11];
%selectedStations=[9]; 

%map network drive for storage server
%sourceIP='132.239.158.177';  %OLD!  same as sourceIP='Reinagellab';  
sourceIP='132.239.158.181';  %same as sourceIP='Reinagel-lab.ad.ucsd.edu'; 
sourcePath='\rlab';
password='1Mouse';
command=sprintf('!net use z: \\\\%s%s %s /user:RODENT',sourceIP,sourcePath,password)
eval(command);


for stationNum=selectedStations;
    %map network drive for ratrix station
    sourceIP=stationIP{stationNum}; 
    sourcePath='\c'
    password='Pac3111';
    command=sprintf('!net use y: \\\\%s%s %s /user:rlab',sourceIP,sourcePath,password)
    eval(command);

    %do MAIN COPY

     
    destinationRoot=fullfile('z:','Rodent-Data','pmeier','RatricesStored');
    timeStamp=datestr(clock,30);
    saveToFolder=sprintf('Ratrix_Station%d-%s',stationNum,timeStamp);
    
    %make the main dir, so folder can be copied into it
    [status,message,messageid] = mkdir(destinationRoot,saveToFolder);
    if ~status==1
            error(sprintf('%s -- %s problem with making dir %s in %s',message,messageid,saveToFolder,destinationRoot))
    end
    
    %copy each folder
    folders={'example','classes','analysis'};
    numFolders=size(folders,2);
    for fldr=1:numFolders
        sourcePath=fullfile('y:\pmeier\Ratrix',folders{fldr});
        destinationPath=fullfile(destinationRoot,saveToFolder,folders{fldr});
        [status,message,messageid] = copyfile(sourcePath,destinationPath,'f');
        if ~status==1
            error(sprintf('%s -- %s problem with copying files from %s to %s',message,messageid,sourcePath,destinationPath))
        end
    end

    command=sprintf('!net use y: /delete'); eval(command);
end

%unmap drive for storage server
command=sprintf('!net use z: /delete'); eval(command);




