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
        %serverAddress='132.239.158.169'; %testing only
    else
        serverAddress=info.server;
    end
    
    tries=0;
    while true
        initRatrixPorts;
        try
            clearJavaComponents();
            checkForUpdate;
            addJavaComponents();  %        move to top of file. so that above dbConn
            % If r is already setup, just try and reconnect
            %             if exist('r','var') && ~isempty(r)
            %                 reconnect(r);
            %             else
            r = rnet('client',id,serverAddress);
            %             end
        catch ex
            errStrs={'Unable to establish socket in RlabNetworkClient constructor',...
                'Unable to open input streams',...
                'Unable to open I/O streams on server socket in client thread',...
                'While waiting for connect acknowledgment, client is no longer connected',...
                'Unable to send connection message in RlabNetworkClient constructor'...
                'Client timed out waiting to establish connection'};

            tmp={};
            for ind=1:length(errStrs)
                tmp{ind}=ex.message;
            end
            if  any(~cellfun(@isempty,cellfun(@findstr,errStrs,tmp,'UniformOutput',false)))
                r=[]; %release reference to java objects
                tries=tries+1;
                fprintf('%s: try %d: no server found at %s, trying again in a sec\n',datestr(now),tries, serverAddress)
                WaitSecs(1);
            else
                errStrs
                ex.message
                disp(['CAUGHT ERROR: ' getReport(ex,'extended')])
                error('bootstrap problem')
            end
        end
        if exist('r','var') && ~isempty(r)
            tries=0;

            fixSystemTime;
            clearTemporaryFiles(r);

            quit=false;
            constants=getConstants(r);
            while ~quit
                if ~isConnected(r)
                    quit=1;
                else
                    com=getNextCommand(r);
                    if ~isempty(com)
                        quit=clientHandleCommand(r,com,constants.statuses.NO_RATRIX);
                    else
                        WaitSecs(0.1);
                    end
                end
            end
            com=[]; %release reference to java objects
            r=cleanup(r);
        end
    end

catch ex
    disp(['CAUGHT ERROR: ' getReport(ex,'extended')])

    fprintf('shutting down client due to error\n')
    cleanup(r);

    rethrow(ex)
end


function r=cleanup(r)
FlushEvents('mouseUp','mouseDown','keyDown','autoKey','update');
ListenChar(0);
ShowCursor(0);
if exist('r','var') && isa(r,'rnet')
    r=shutdown(r);
end
clearJavaComponents();