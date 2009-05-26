function quit = bootstrap(datanet)
% bootstrap on a 'stim' datanet

quit = false;
constants = getConstants(datanet);
message = [];
MAXSIZE=1024*1024;
CMDSIZE=1;

if strmatch(datanet.type, 'data')
    error('must be called on datanet of type ''stim''');
end

while 1
    quit=false;
    % listen for a tcpconnect
    % ========================================================================================
    % DATANET STUFF
    % open a socket connection
    datanet.sockcon = pnet('tcpsocket', datanet.port);
    % first connection - keep trying to get a connection using tcplisten
    stimcon = -1;
    while stimcon == -1
        stimcon=pnet(datanet.sockcon,'tcplisten','noblock');
        if stimcon==-1
            fprintf('tried tcplisten - no connection received\n')
            WaitSecs(3);
        end
    end
    pnet(stimcon,'setwritetimeout',5);
    pnet(stimcon,'setreadtimeout',5);
    datanet=setCon(datanet,stimcon);
    [ip port]=pnet(stimcon,'gethost')
    % now that stimcon is not -1, that means a data-side tcpconnect was issued
    % check for commands (ie start_trials_cmd)
    disp('received connection from server')
    % basically just loop clientHandleCommands
    while ~quit
        try
        [datanet quit]=handleCommands(datanet,[]);
        catch ex
            disp(['CAUGHT ER (at bootstrap): ' getReport(ex)]);
            validStr=false;
            while ~validStr
                str=input('(R)estart trials OR (q)uit trials?','s');
                if strcmpi(str,'r')
                    % need to send a message to the server to NOT reset
                    % running/recording!
                    validStr=true;
                    quit=false;
                    commands=[];
                    commands.cmd = constants.stimToDataCommands.S_ERROR_RECOVERY_METHOD;
                    cparams=[];
                    cparams.method = 'Restart';
                    commands.arg=cparams;
                    [gotAck] = sendCommandAndWaitForAck(datanet, commands);
                    pnet(datanet.con,'close');
                    datanet.con=[];
                    % reconnect!
                    stimcon = -1;
                    while stimcon == -1
                        stimcon=pnet(datanet.sockcon,'tcplisten','noblock');
                        if stimcon==-1
                            fprintf('tried tcplisten - no connection received\n')
                            WaitSecs(3);
                        end
                    end
                    pnet(stimcon,'setwritetimeout',5);
                    pnet(stimcon,'setreadtimeout',5);
                    datanet=setCon(datanet,stimcon);
                    [ip port]=pnet(stimcon,'gethost')
                    % now that stimcon is not -1, that means a data-side tcpconnect was issued
                    % check for commands (ie start_trials_cmd)
                    disp('received connection from server')
                elseif strcmpi(str,'q')
                    validStr=true;
                    quit=true;
                    commands=[];
                    commands.cmd = constants.stimToDataCommands.S_ERROR_RECOVERY_METHOD;
                    cparams=[];
                    cparams.method = 'Quit';
                    commands.arg=cparams;
                    [gotAck] = sendCommandAndWaitForAck(datanet, commands);
                    pnet(datanet.con,'close')
                    pnet('closeall')
                    datanet.con=[];
                end
            end        
        end
    end
    
    pnet('closeall');
    disp('finished handling commands for this datanet, going back to bootstrap');
    
end

end % end function
