function server
setupEnvironment;

servePump=false;

%standalone=false;
%rx=makeRatrix(fullfile(fileparts(fileparts(getRatrixPath)),'ratrixData',filesep),~servePump);

% if servePump
%     rewardMethod='serverPump'
% else
%     rewardMethod = 'localTimed'
% end

%rx=makeRatrix(fullfile(fileparts(fileparts(getRatrixPath)),'ratrixData',filesep),standalone,rewardMethod);
dataPath=fullfile(fileparts(fileparts(getRatrixPath)),'ratrixData',filesep);
rx=ratrix(fullfile(dataPath, 'ServerData'),0); %load from file

try
    if servePump
        sys=initPumpSystem(makePumpSystem());
    else
        sys=[];
    end

    addJavaComponents; %would like to have this in the rnet constructor, but doesn't work
    %     the caller has to call it before constructing an
    %     rnet for some reason.  can't figure out why, but if you don't do it, even
    %     though the dynamic path is updated correctly, the import appears to
    %     fail.
    r = rnet('server');
    clearTemporaryFiles(r);

    fprintf('server running - type q to quit\n')
    constants = getConstants(r);

    %     currentPrimeTarget={iterStationID(rx,0) 1};
    %     priming=false;

    quit=false;

    while ~quit
        while CharAvail() %note have to hit ctrl-c once for this to ever succeed!
            %this gives us ascii value 3, which is   ETX  ^C 		End of Text
            k=GetChar(0);

            switch k
                case 'q'
                    %                     if priming
                    %                         r=stopPrime(r);
                    %                         priming=false;
                    %                     end
                    quit=true;
                    fprintf('quitting\n')
                    break %gets us out of CharAvail() while loop
                    %                 case 'p'
                    %                     priming = ~priming;
                    %                     if priming
                    %                         [r priming]=startPrime(r,currentPrimeTarget{1},currentPrimeTarget{2});
                    %                     else
                    %                         r=stopPrime(r);
                    %                     end
                    %                 case {'<','>'}
                    %
                    %                     if priming
                    %                         r=stopPrime(r);
                    %                     end
                    %
                    %                     if k=='>'
                    %                         d=1;
                    %                     elseif k=='<'
                    %                         d=-1;
                    %                     end
                    %                     currentPrimeTarget{2}=currentPrimeTarget{2}+d;
                    %                     if currentPrimeTarget{2}>getNumPortsForStationID(rx,currentPrimeTarget{1})
                    %                         currentPrimeTarget{2}=1;
                    %                         currentPrimeTarget{1}=iterStationID(rx,currentPrimeTarget{1},'next');
                    %                     elseif currentPrimeTarget{2}<1
                    %                         currentPrimeTarget{1}=iterStationID(rx,currentPrimeTarget{1},'prev');
                    %                         currentPrimeTarget{2}=getNumPortsForStationID(rx,currentPrimeTarget{1});
                    %                     end
                    %                     fprintf('current prime target: station %d port %d\n',currentPrimeTarget{1},currentPrimeTarget{2})
                    %
                    %                     if priming
                    %                         [r priming]=startPrime(r,currentPrimeTarget{1},currentPrimeTarget{2});
                    %                     end
                    %                 case 'u'
                    %                     clients = listClients(r);
                    %                     fprintf('Attempting to update all connected clients\n');
                    %                     for i=1:length(clients);
                    %                         [quit com]=sendToClient(r,clients(i),constants.priorities.IMMEDIATE_PRIORITY,constants.serverToStationCommands.S_UPDATE_SOFTWARE_CMD,{});
                    %                         if ~quit
                    %                             fprintf('Updating software on %s\n',mac)
                    %                             timeout=5.0;
                    %                             quit=waitForAck(r,com,timeout,'Waiting for acknowledge of software update request');
                    %                         end
                    %                         com=[];
                    %                     end
                    %                     clients=[];
                otherwise
                    if double(k)==3
                        'trapped ctrl-c!'
                        ListenChar(2)
                    else
                        k
                        class(k)
                        double(k)
                        fprintf('unrecognized command - type q to quit\n')
                    end
            end
        end

        %note that a quit (say in the middle of a reward) should not be able to screw anything up, but it appeared to for me once so far...

        if ~quit

            if servePump
                %setOnlineRefill(sys); %need to rapidly call this over and over to avoid flooding!
                ensureAllRezFilled(sys); %less efficient, but more safe than setOnlineRefill()
            end

            %             if priming
            %                 primeTimeout = -5.0;
            %                 ulPrimeSize=100;
            %                 primeValveStates=false(1,getNumPortsForStationID(rx,currentPrimeTarget{1}));
            %                 primeValveStates(currentPrimeTarget{2})=true;
            %                 isPrime=true;
            %                 sys=rewardClient(r,getPrimeClient(r),ulPrimeSize,primeValveStates,primeTimeout,isPrime,sys);
            %             else

            % update client register
            clients = listClients(r);
            connectedClients={}; %note, switching to cell array from a java () array!
            for i=1:length(clients)
                if isConnected(r,clients(i))
                    connectedClients{end+1}=clients(i);
                else
                    r=unregisterClient(r,clients(i));
                    commandsWaitingFromClient=disconnectClient(r,clients(i));
                    commandsWaitingFromClient=[]; % i'll ignore leftover commands for now
                end
            end
            clients=[];
            for i=1:length(connectedClients) %this needs to happen after disconnections have been removed to prevent fast reconnects from confusing me!
                reregistered = clientReregistered(r,connectedClients{i});
                if reregistered
                    % If reregistered, unregister it first
                    if clientIsRegistered(r,connectedClients{i})
                        r=unregisterClient(r,connectedClients{i});
                    end
                end
                if ~clientIsRegistered(r,connectedClients{i}) || reregistered
                    [quit mac]=getClientMACaddress(r,connectedClients{i});

                    %ask client for its type -- if monitor vs if
                    %station

                    if quit
                        fprintf('Client is no longer connected\n');
                        commandsWaitingFromClient=disconnectClient(r,connectedClients{i}); %i'll ignore leftover commands for now
                        commandsWaitingFromClient=[];
                    else
                        [quit com]=sendToClient(r,connectedClients{i},constants.priorities.IMMEDIATE_PRIORITY,constants.serverToStationCommands.S_UPDATE_SOFTWARE_CMD,{});
                        if ~quit
                            timeout=10.0;
                            [quit updateConfirm updateConfirmCmd updateConfirmArgs]=waitForSpecificCommand(r,connectedClients{i},constants.stationToServerCommands.C_RECV_UPDATING_SOFTWARE_CMD,timeout,'waiting for client response to S_UPDATE_SOFTWARE_CMD',[]);
                            com=[];
                            updateConfirm=[];
                        end
                        if quit
                            fprintf('Client is no longer connected %s\n',mac);
                            commandsWaitingFromClient=disconnectClient(r,connectedClients{i});
                            commandsWaitingFromClient=[]; %i'll ignore leftover commands for now
                        elseif updateConfirmArgs{1}
                            fprintf('Updating software on %s\n',mac);
                            commandsWaitingFromClient=disconnectClient(r,connectedClients{i});
                            commandsWaitingFromClient=[]; %i'll ignore leftover commands for now
                        else
                            z=getZoneForStationMAC(rx,mac);
                            if ~isempty(z)
                                r=registerClient(r,connectedClients{i},mac,z);

                                [quit com]=sendToClient(r,connectedClients{i},constants.priorities.IMMEDIATE_PRIORITY,constants.serverToStationCommands.S_GET_RATRIX_CMD,{});

                                if ~quit
                                    timeout=10.0;
                                    [quit rxCmd rxCom rxArgs]=waitForSpecificCommand(r,connectedClients{i},constants.stationToServerCommands.C_RECV_RATRIX_CMD,timeout,'waiting for client response to S_GET_RATRIX_CMD',[]);
                                    com=[];
                                    rxCmd=[];
                                end
                                if quit
                                    fprintf('Client is no longer connected %s\n',mac);
                                    commandsWaitingFromClient=disconnectClient(r,connectedClients{i});
                                    commandsWaitingFromClient=[]; %i'll ignore leftover commands for now
                                elseif ~isempty(rxArgs{1})
                                    %merge backup to rx %may be for totally different subject!
                                end

                                nonPersistedRatrix=makeNonpersistedRatrixForStationMAC(rx,mac);
                                [quit com]=sendToClient(r,connectedClients{i},constants.priorities.IMMEDIATE_PRIORITY,constants.serverToStationCommands.S_START_TRIALS_CMD,{nonPersistedRatrix});
                                if ~quit
                                    nonPersistedRatrix=[];
                                    fprintf('\nsent ratrix to %s\n',mac)
                                    timeout=5.0;
                                    quit=waitForAck(r,com,timeout,'waiting for ack from sent ratrix');
                                end
                                if quit
                                    fprintf('Client is no longer connected %s\n',mac);
                                    r=unregisterClient(r,connectedClients{i});
                                    commandsWaitingFromClient=disconnectClient(r,connectedClients{i});
                                    commandsWaitingFromClient=[]; % i'll ignore leftover commands for now
                                end
                                com=[];
                            else
                                %disconnect that client, no record for that mac in ratrix

                                r=remoteClientShutdown(r,connectedClients{i});

                                commandsWaitingFromClient=disconnectClient(r,connectedClients{i});
                                commandsWaitingFromClient=[]; % i'll ignore leftover commands for now


                            end
                        end
                    end
                end
            end
            connectedClients={};


            if length(listClients(r)) < 1
                WaitSecs(0.1); %sleeps the thread
            else

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

                if commandsAvailable(r) %used to be while, but want to loop faster so online equalization tank refills happen more often
                    disp(sprintf('%s: handling command.  num commands in queue: %d\n',datestr(now),commandsAvailable(r)))
                    com = getNextCommand(r);
                    startTime=GetSecs();
                    [sys r]=serverHandleCommand(r,com,sys);
                    fprintf('\tcommand handling time was %g secs\n',GetSecs()-startTime);
                    com=[];
                else
                    if servePump
                        sys = considerOpportunisticRefill(sys);
                    end
                end
            end
            clients={};
        end
    end

    [sys,r,rx]=cleanup(servePump,sys,r,rx);
    clear all
    whos
    doClears();

catch
    fprintf('shutting down rnet and pump system due to error\n')
    lasterr
    x=lasterror
    x.stack.file
    x.stack.line

    %if call ListenChar(0) to undo the ListenChar(2) before this point, seems to replace useful errors with 'Undefined function or variable GetCharJava_1_4_2_09.'

    com=[];
    clients=[];
    [sys,r,rx]=cleanup(servePump,sys,r,rx);
    doClears();

    rethrow(lasterror)
end

function [sys,r,rx]=cleanup(servePump,sys,r,rx)
'turning off listenchar'
ListenChar(0) %'called listenchar(0) -- why doesn''t keyboard work?'
ShowCursor(0)
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
    r=shutdown(r);
catch
    fprintf('error shutting down rnet\n')
    lasterr
    x=lasterror
    x.stack.file
    x.stack.line
end

rx=[];

function doClears

clear classes
% java.lang.System.gc();
% clear java
% WaitSecs(.5)
% clear classes
% clear java
% java.lang.System.gc();
clearJavaComponents();