%would like to compile to standalone with:
%mcc -m -I C:\psychtoolbox\Psychtoolbox -I \\Reinagel-lab.ad.ucsd.edu\rlab\Rodent-Data\ratrixAdmin\ -d standalone ratrixServer.m
%but this yields:
%
% ??? Undefined function or method 'FlushEventsNoJVM' for input arguments of type
% 'char'.
%
% Error in ==> FlushEvents at 89
%
% Error in ==> setupEnvironment at 19
%
% Error in ==> ratrixServer at 2
%
% can't see C:\psychtoolbox\Psychtoolbox\PsychBasic\MatlabWindowsFilesR11\FlushEventsNoJVM.dll
% this is removed from path for 2007a installs...
%
%
% i temporarily moved this, then got:
%
% This MATLAB file does not have proper version information and may be corrupt.
% The file
%    '\\Reinagel-lab.ad.ucsd.edu\rlab\Rodent-Data\ratrixAdmin\getRatrixHeatInfo.m'
%
%    is not in the application's expanded CTF archive at
%     'C:\Documents and Settings\rlab\Desktop\ratrix\bootstrap\standalone\ratrixSe
% rver_mcr'.
% This is typically caused by calls to ADDPATH in your startup.m or matlabrc.m fil
% es. Please see the compiler documentation and use the ISDEPLOYED function to ens
% ure ADDPATH commands are not executed by deployed applications.
% ??? The M-file
%    "\\Reinagel-lab.ad.ucsd.edu\rlab\Rodent-Data\ratrixAdmin\getRatrixHeatInfo.m"
%
% cannot be executed.
%
% Error in ==> ratrixServer at 48
%
% MATLAB:err_parse_cannot_run_m_file



function ratrixServer
setupEnvironment;
addJavaComponents();
dataPath=fullfile(fileparts(fileparts(getRatrixPath)),'ratrixData',filesep);

diary off
warning('off','MATLAB:MKDIR:DirectoryExists')
mkdir(fullfile(dataPath,'diaries'))
warning('on','MATLAB:MKDIR:DirectoryExists')
diary([fullfile(dataPath,'diaries') filesep datestr(now,30) '.txt'])

servePump=false;

quit=false;



margin=5;
oneRowHeight=23;
longTWidth=200;
ddWidth=150;
bWidth=75;
miniSz=400;


started=[];
heatUpSinceTStr='';
buttonT='start';


rackNum=1;
%[heats,garbage]=getRatrixHeatInfo(rackNum);

conn=dbConn('132.239.158.177','1521','dparks','pac3111');
hts=getHeats(conn);
for i=1:length(hts)
    heats{i,1}={hts{i}.name [hts{i}.red hts{i}.green hts{i}.blue]};
    assignments=getAssignments(conn,rackNum,hts{i}.name);
    for j=1:length(assignments)
        stn=getStation(conn,rackNum,assignments{j}.station_id);
        heats{i,2}{j}={assignments{j}.subject_id {[stn.row stn.col] stn.mac} assignments{j}.owner assignments{j}.experiment};
    end
end
closeConn(conn);   

subjects={};
heatStrs={};
for i=1:size(heats,1)
    heatStrs{end+1}=heats{i,1}{1};
end

doDelete=false;
running=false;

fWidth=margin+ddWidth+margin+longTWidth+margin+bWidth+margin;
fHeight=margin+oneRowHeight+margin+miniSz+margin;
f = figure('Visible','off','MenuBar','none','Name',sprintf('ratrix control: rack %d',rackNum),'NumberTitle','off','Resize','off','CloseRequestFcn',@cleanup,'Units','pixels','Position',[50 50 fWidth fHeight]);
    function cleanup(src,evt)
        doDelete=true;
        updateUI;
    end

    function updateUI()
        if doDelete
            if running
                errordlg('must stop running before closing','error','modal')
                doDelete=false;
            else
                'turning off listenchar'
                ListenChar(0) %'called listenchar(0) -- why doesn''t keyboard work?'
                ShowCursor(0)

                closereq;
                exit
                return
            end
        elseif running
            buttonT='stop';
            upSince=etime(clock,started);
            hrs=floor(upSince/60/60);
            mins=floor((upSince-hrs*60*60)/60);
            secs=floor(upSince-hrs*60*60-mins*60);
            heatUpSinceTStr=sprintf('up time %d:%02d:%02d',hrs,mins,secs);
            set(heatUpSinceT,'ForegroundColor',[0 0 0]);
            set(swapM,'Enable','off')
        else
            buttonT='start';
            heatUpSinceTStr='not running';
            set(heatUpSinceT,'ForegroundColor',[1 0 0]);
            set(swapM,'Enable','on')
        end
        set(heatUpSinceT,'String',heatUpSinceTStr);
        set(cycleB,'String',buttonT);
        drawnow;
    end




swapM = uicontrol(f,'Style','popupmenu',...
    'String',heatStrs,...
    'Value',1,'Units','pixels','Position',[margin 2*margin+miniSz ddWidth oneRowHeight],'Callback',@swapC);
    function swapC(source,eventdata)


        setHeat;

    end

    function setHeat
        try
        heat=heatStrs{get(swapM,'Value')};
        for i=1:size(heats,1)
            if strcmp(heats{i,1}{1},heat)
                subjects=heats{i,2};
                heatCol=heats{i,1}{2};
            end
        end
        makeMini(subjects,rackNum,miniSz,ha,heatCol);
        %         for i=1:length(subjects)
        %             subjects{i}{2}{1}
        %         end
        catch
            x=lasterror
            x.stack.file
            x.stack.line
            y=errordlg(['call dan erik or philip before closing this box.  quitting due to error: ' x.message],'ratrix error','modal')
            uiwait(y)
            cleanup
        end
    end

heatUpSinceT=uicontrol(f,'Style','text','HorizontalAlignment','Left','String',heatUpSinceTStr,'Units','pixels','Position',[2*margin+ddWidth 2*margin+miniSz longTWidth oneRowHeight/2]);

cycleB=uicontrol(f,'Style','togglebutton','String',buttonT,'Units','pixels','Position',[3*margin+ddWidth+longTWidth 2*margin+miniSz bWidth oneRowHeight],'Callback',@buttonC);
    function buttonC(source,eventdata)
        if get(cycleB,'Value')
            started=datevec(now);
            running=true;

            run();
        else
            running=false;

        end
        updateUI;
    end

    function run

        [r sys rx]=startServer(servePump,dataPath);
        % Dan is initializing er to 0 032908
        er=0;
        autoUpdateInterval=.3;
        while ~doDelete && running && ~quit %get(cycleB,'Value')
            updateUI();
            [quit r rx sys er]=doAServerIteration(r,rx,servePump,sys,subjects);
            WaitSecs(autoUpdateInterval);
        end
        updateUI();
        [r rx sys]=stopServer(r,rx,servePump,sys,er,subjects);
        rp=getRatrixPath;
        rp=fullfile(rp,'analysis','eflister');
        cmdStr=sprintf('matlab -automation -r "cd(''%s'');compileTrialRecords(%d);quit" &',rp,rackNum);
        system(cmdStr);
        
        %whos
        doClears();
        if er
            rethrow(lasterror)
        end
        system('matlab -automation -r "cd(''C:\Documents and Settings\rlab\Desktop\ratrix\analysis\eflister'');compileTrialRecords;quit" &');
    end


align([swapM heatUpSinceT cycleB],'Fixed',margin,'Middle');


ha = axes('Parent',f,'Visible','off','Units','pixels','Position',[round((fWidth-miniSz)/2),margin,miniSz,miniSz]);
axis(ha,'ij');
axis(ha,'equal')


setHeat;
set(f,'Visible','on')
updateUI;
end




function makeMini(subjects,rackNum,miniSz,ha,heatCol)

% stationInfo=getRatrixStationInfo(rackNum);
% theseStations=[];
% stationNames={};
% for i=1:length(stationInfo)
%     theseStations(end+1,:)=stationInfo{i}{2}{1};
%     stationNames{end+1}=stationInfo{i}{1};
% end



conn=dbConn('132.239.158.177','1521','dparks','pac3111');
stationInfo=getStationsOnRack(conn,rackNum);
closeConn(conn);

theseStations=[];
stationNames={};
for i=1:length(stationInfo)
    theseStations(end+1,:)=[stationInfo{i}.row stationInfo{i}.col];
    %theseStations(end+1,:)=[stationInfo.row stationInfo.col];
    stationNames{end+1}=[num2str(stationInfo{i}.rack_id) stationInfo{i}.station_id];
end



% stationLocs=[];
% for i=1:r(1)
%     for j=1:r(2)
%         stationLocs(end+1,:)=[rackNum i j];
%     end
% end

%theseStations=stationLocs(stationLocs(:,1)==rackNum,2:3);

numRows=max(theseStations(:,1));
numCols=max(theseStations(:,2));

rackPix=zeros(miniSz,miniSz,3);
columnBoundaries=floor(linspace(1,miniSz,numCols+1));
rowBoundaries=floor(linspace(1,miniSz,numRows+1));

borderColor=1;
col=.5*ones(1,3);

rackPix(:,columnBoundaries,:)=borderColor;
rackPix(rowBoundaries,:,:)=borderColor;

for j=1:size(theseStations,1)

    row=theseStations(j,1);
    column=theseStations(j,2);

    rows=(rowBoundaries(row)+1):(rowBoundaries(row+1)-1);
    columns=(columnBoundaries(column)+1):(columnBoundaries(column+1)-1);

    rackPix(rows,columns,:)=repmat(reshape(col,[1 1 3]),[length(rows) length(columns) 1]);

end

image('Parent',ha,'CData',rackPix);

rowCenters=rowBoundaries(1:end-1)+diff(rowBoundaries)/2;
colCenters=columnBoundaries(1:end-1)+diff(columnBoundaries)/2;
margin=5;

for i=1:length(subjects)
    loc=subjects{i}{2}{1};
    name=subjects{i}{1};
    name(name=='_')=' ';
    owner=subjects{i}{3};
    exp=subjects{i}{4};
    %note axis ij, so row/col flipped!
    text('Parent',ha,'Position',[colCenters(loc(2)) rowCenters(loc(1)) ],'String',name,'Color',heatCol,'FontSize',30,'FontWeight','bold','VerticalAlignment','middle','HorizontalAlignment','center');
    text('Parent',ha,'Position',[columnBoundaries(loc(2))+margin rowBoundaries(loc(1)+1) ],'String',sprintf('owner: %s\nexp: %s',owner,exp),'Color',[0 0 0],'FontSize',10,'FontWeight','normal','VerticalAlignment','bottom','HorizontalAlignment','left');
end


for i=1:length(stationNames)
    text('Parent',ha,'Position',[columnBoundaries(theseStations(i,2))+margin rowBoundaries(theseStations(i,1)) ],'String',[stationNames{i}],'Color',[0 0 0],'FontSize',30,'FontWeight','bold','VerticalAlignment','top','HorizontalAlignment','left');
end

end






function [r sys rx]=startServer(servePump,dataPath)
if servePump
    sys=initPumpSystem(makePumpSystem());
else
    sys=[];
end



%addJavaComponents; %would like to have this in the rnet constructor, but doesn't work
%     the caller has to call it before constructing an
%     rnet for some reason.  can't figure out why, but if you don't do it, even
%     though the dynamic path is updated correctly, the import appears to
%     fail.
r = rnet('server');
clearTemporaryFiles(r);

fprintf('server running')


rx=ratrix(fullfile(dataPath, 'ServerData'),0); %load from file

[rx ids]=emptyAllBoxes(rx,'ratrixServer starting','ratrix');
if length(ids)>0
    ids
    warning('found subjects in boxes at ratrixServer startup')
end


end









function [r rx sys]=stopServer(r,rx,servePump,sys,er,subjects)
fprintf('quitting\n')

[sys,r,rx]=cleanup(servePump,sys,r,rx,subjects);
end









function [quit r rx sys er]=doAServerIteration(r,rx,servePump,sys,subjects)
try
%     while CharAvail() %note have to hit ctrl-c once for this to ever succeed!
%         %this gives us ascii value 3, which is   ETX  ^C 		End of Text
%         k=GetChar(0);
% 
%         if double(k)==3
%             'trapped ctrl-c!'
%             ListenChar(2)
%         end
%     end

    quit=false;
    er=false;
    constants = getConstants(r);

    if servePump
        %setOnlineRefill(sys); %need to rapidly call this over and over to avoid flooding!
        ensureAllRezFilled(sys); %less efficient, but more safe than setOnlineRefill()
    end

    % update client register
    clients = listClients(r);
    connectedClients={}; %note, switching to cell array from a java () array!
    for i=1:length(clients)
        if isConnected(r,clients(i))
            connectedClients{end+1}=clients(i);
        else
            [r rx]=unregisterClient(r,clients(i),rx,subjects);
            tossClient(r,clients(i));
        end
    end

    clients=[];
    for i=1:length(connectedClients) %this needs to happen after disconnections have been removed to prevent fast reconnects from confusing me!
        reregistered = clientReregistered(r,connectedClients{i});
        if reregistered
            % If reregistered, unregister it first
            if clientIsRegistered(r,connectedClients{i})
                [r rx]=unregisterClient(r,connectedClients{i},rx,subjects);
            end
        end
        if ~clientIsRegistered(r,connectedClients{i}) || reregistered
            [quit mac]=getClientMACaddress(r,connectedClients{i});

            %ask client for its type -- if monitor vs if
            %station

            if quit
                fprintf('Client is no longer connected\n');
                tossClient(r,connectedClients{i});

            else

                [quit com]=sendToClient(r,connectedClients{i},constants.priorities.IMMEDIATE_PRIORITY,constants.serverToStationCommands.S_UPDATE_SOFTWARE_CMD,{'svn://132.239.158.177/projects/eflister/Ratrix/branches/merge20080324'});
                if ~quit
                    timeout=10.0;
                    [quit updateConfirm updateConfirmCmd updateConfirmArgs]=waitForSpecificCommand(r,connectedClients{i},constants.stationToServerCommands.C_RECV_UPDATING_SOFTWARE_CMD,timeout,'waiting for client response to S_UPDATE_SOFTWARE_CMD',[]);
                    if isempty(updateConfirm) || isempty(updateConfirmCmd)
                        error('appeared to get error from client -- waitForSpecificCommand should know to also check for sendErrors() that have to do with that specific command (it''s objectID, not just its type)')
                    end
                    com=[]; %should this be something else?
                    updateConfirm=[];
                end
                if quit
                    fprintf('Client is no longer connected %s\n',mac);
                    tossClient(r,connectedClients{i});
                elseif updateConfirmArgs{1}
                    fprintf('Updating software on %s\n',mac);
                    tossClient(r,connectedClients{i});
                else
                    
                    quit=replicateClientTrialRecords(r,connectedClients{i},{getPermanentStorePath(rx)});

                    z=[];
                    if ~quit                    
                        z=getZoneForStationMAC(rx,mac);
                    end
                    
                    gotGoodRatrix=false;
                    if ~isempty(z)
                        [r rx tf]=registerClient(r,connectedClients{i},mac,z,rx,subjects);

                        [rx quit]=updateRatrixFromClientRatrix(r,rx,connectedClients{i});
                        
                        if ~quit && tf

                            nonPersistedRatrix=makeNonpersistedRatrixForStationMAC(rx,mac);
                            if ~isempty(nonPersistedRatrix)
                                gotGoodRatrix=true;
                                [quit com]=sendToClient(r,connectedClients{i},constants.priorities.IMMEDIATE_PRIORITY,constants.serverToStationCommands.S_START_TRIALS_CMD,{nonPersistedRatrix});
                                if ~quit
                                    nonPersistedRatrix=[];
                                    fprintf('\nsent ratrix to %s\n',mac)
                                    timeout=5.0;
                                    quit=waitForAck(r,com,timeout,'waiting for ack from sent ratrix');
                                end

                                com=[];
                            end
                        end
                    end
                    if isempty(z) || ~tf || quit || ~gotGoodRatrix


                        fprintf('shutting down client -- no entry for that mac or lost connection %s\n',mac);                        

                        [r rx]=remoteClientShutdown(r,connectedClients{i},rx,subjects); %will handle unregistering

                        tossClient(r,connectedClients{i});

                    end
                end
            end
        end
    end
    connectedClients={};

    if length(listClients(r)) >= 1

        % Handle a SERVER RESET
        if resetRequested(r)
            fprintf('Responding to Server Reset Request\n');
            % Attempt to disconnect all clients
            clients = listClients(r);
            for i=1:length(clients)
                % disconnectClient(r,clients(i));
            end
            clients=[];
            %do we need to restart the server here or something?
        end

        com = getNextCommand(r);
        if ~isempty(com) %commandsAvailable(r) %used to be while, but want to loop faster so online equalization tank refills happen more often
            disp(sprintf('%s: handling command.  num other commands in queue: %d\n',datestr(now),commandsAvailable(r)))
            %com = getNextCommand(r);
            startTime=GetSecs();
            [sys r rx]=serverHandleCommand(r,com,sys,rx,subjects);
            fprintf('\tcommand handling time was %g secs\n',GetSecs()-startTime);
            com=[];
        else
            if servePump
                sys = considerOpportunisticRefill(sys);
            end
        end
    end
    clients={};
catch
    quit=true;
    er=true;



    fprintf('shutting down rnet and pump system due to error\n')
    lasterr
    x=lasterror
    x.stack.file
    x.stack.line

    %if call ListenChar(0) to undo the ListenChar(2) before this point, seems to replace useful errors with 'Undefined function or variable GetCharJava_1_4_2_09.'

    com=[];
    clients=[];


end
end







function tossClient(r,c)
commandsWaitingFromClient=disconnectClient(r,c);
commandsWaitingFromClient=[]; % i'll ignore leftover commands for now
end







function [sys,r,rx]=cleanup(servePump,sys,r,rx,subjects)


if servePump
    try
        sys=closePumpSystem(sys);
    catch
        fprintf('error shutting down pump\n')
        lasterr
        x=lasterror
        x.stack.file
        x.stack.line
    end
end

try
    [r rx]=shutdown(r,rx,subjects);
catch
    fprintf('error shutting down rnet\n')
    lasterr
    x=lasterror
    x.stack.file
    x.stack.line
end

[rx ids]=emptyAllBoxes(rx,'ratrixServer cleanup','ratrix');
if length(ids)>0
    ids
    warning('subjects were left in boxes at ratrixServer cleanup')
end

rx=[];
end





function doClears

debug=1;
if ~debug
    clear classes
    clearJavaComponents();
end

% java.lang.System.gc();
% clear java
% WaitSecs(.5)
% clear classes
% clear java
% java.lang.System.gc();

end
