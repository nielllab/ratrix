function miniServer
setupEnvironment;
addJavaComponents();

dataPath=pwd;

diary off
warning('off','MATLAB:MKDIR:DirectoryExists')
mkdir(fullfile(dataPath,'diaries'))
warning('on','MATLAB:MKDIR:DirectoryExists')
diary([fullfile(dataPath,'diaries') filesep datestr(now,30) '.txt'])

quit=false;

fixSystemTime;
r=startServer();
er=0;
autoUpdateInterval=.3;
FlushEvents('keyDown')
while ~quit
    [quit r er]=doAServerIteration(r);
    WaitSecs(autoUpdateInterval);
    if CharAvail
        quit=true;
    end
end
r=stopServer(r);

doClears();
if er
    rethrow(lasterror)
end
end

function r=startServer

%addJavaComponents; %would like to have this in the rnet constructor, but doesn't work
%     the caller has to call it before constructing an
%     rnet for some reason.  can't figure out why, but if you don't do it, even
%     though the dynamic path is updated correctly, the import appears to
%     fail.
r = rnet('server');
clearTemporaryFiles(r);
fprintf('server running')
end

function r=stopServer(r)
fprintf('quitting\n')

try
    r=shutdown(r,[],[]);
catch ex
    fprintf('error shutting down rnet\n')
    disp(['CAUGHT ERROR: ' getReport(ex,'extended')])
end

end

function [quit r er]=doAServerIteration(r)
try
    quit=false;
    er=false;
    constants = getConstants(r);

    % update client register
    clients = listClients(r);
    connectedClients={}; %note, switching to cell array from a java () array!
    for i=1:length(clients)
        if isConnected(r,clients(i))
            connectedClients{end+1}=clients(i);
        else
            tossClient(r,clients(i));
        end
    end
    clients=[];

    for i=1:length(connectedClients) %this needs to happen after disconnections have been removed to prevent fast reconnects from confusing me!
        if clientReregistered(r,connectedClients{i})
            connectedClients{i}
            'reregistered'
        end
        [quit mac]=getClientMACaddress(r,connectedClients{i});

        if quit
            fprintf('got quit from getClientMACaddress %s\n',mac);
            tossClient(r,connectedClients{i});
        else
            fprintf('shutting down client %s\n',mac);
            r=remoteClientShutdown(r,connectedClients{i},[],[]);
            tossClient(r,connectedClients{i});
        end
    end
    connectedClients={};
catch ex
    quit=true;
    er=true;

    fprintf('shutting down rnet due to error\n')
    disp(['CAUGHT ERROR: ' getReport(ex,'extended')])
    
    connectedClients={};
    clients=[];
end
end

function tossClient(r,c)
commandsWaitingFromClient=disconnectClient(r,c);
commandsWaitingFromClient
'commands waiting'
commandsWaitingFromClient=[]; % i'll ignore leftover commands for now
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
