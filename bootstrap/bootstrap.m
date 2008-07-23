function bootstrap

setupEnvironment;
addJavaComponents();  %might conflict with dbconn        
            
dataPath=fullfile(fileparts(fileparts(getRatrixPath)),'ratrixData',filesep);

diary off
warning('off','MATLAB:MKDIR:DirectoryExists')
mkdir(fullfile(dataPath,'diaries'))
warning('on','MATLAB:MKDIR:DirectoryExists')
diary([fullfile(dataPath,'diaries') filesep datestr(now,30) '.txt'])

try

    [success id]=getMACaddress();

    if ~success
        error('couldn''t get mac address')
    end

    conn=dbConn;
    info=getStationFromMac(conn,id);
    closeConn(conn);
    if isempty(info)
        error('No station is defined for this MAC, is this a known station?')
    end
    serverAddress=info.server;
    
    tries=0;
    while true
        'looping over svn code update, then rnet creation, then commands'
        'erik was here 4'
        initRatrixPorts;
        try
            clearJavaComponents();
            checkForUpdate;
            addJavaComponents();  %        move to top of file. so that above dbConn
            % If r is already setup, just try and reconnect
%             if exist('r') && ~isempty(r)
%                 reconnect(r);
%             else
                r = rnet('client',id,serverAddress);
                'yo3'
%             end
        catch ex
            if any(strfind(ex.message,'Unable to open I/O streams on server socket in client thread'))% says can't find server
                r=[];
                tries=tries+1;
                fprintf('try %d: no server found at %s, trying again in a sec\n',tries, serverAddress)
                WaitSecs(1);
            else
                ex
                ple
                error('bootstrap problem')
            end
        end
        if exist('r') && ~isempty(r)
            tries=0;
            % Update system time upon reconnect
            fixSystemTime;
            clearTemporaryFiles(r);
            
            quit=false;
            timing.temp = '';
            constants=getConstants(r);
            while ~quit
                if ~isConnected(r)
                    quit=1;
                else %if commandsAvailable(r)
                    com=getNextCommand(r);
                    if ~isempty(com)
                        quit=clientHandleCommand(r,com,constants.statuses.NO_RATRIX);
                    else
                        WaitSecs(0.1);
                    end
                end
            end
            com=[];
            r=cleanup(r);
        end
    end

catch ex
    ple

    fprintf('shutting down client due to error\n')
    cleanup(r);

    rethrow(ex)
end


function r=cleanup(r)
ListenChar(0);
ShowCursor(0);
if exist('r') && isa(r,'rnet')
    r=shutdown(r);
end
clearJavaComponents();