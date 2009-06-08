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
    datanet.cmdSockcon = pnet('tcpsocket', datanet.ports(1));
    datanet.ackSockcon = pnet('tcpsocket', datanet.ports(2));
    % first connection - keep trying to get a connection using tcplisten
    doCmd=true;
    doAck=true;
    while doCmd && doAck
        if doCmd
            cmd_stimcon=pnet(datanet.cmdSockcon,'tcplisten','noblock');
        end
        if doAck
            ack_stimcon=pnet(datanet.ackSockcon,'tcplisten','noblock');
        end
        if cmd_stimcon==-1
            fprintf('tried tcplisten on cmd port - no connection received\n')
        else
            fprintf('got connection on cmd port!\n')
            doCmd=false;
        end
        if ack_stimcon==-1
            fprintf('tried tcplisten on ack port - no connection received\n')
        else
            fprintf('got connection on ack port!\n')
            doAck=false;
        end
        if doCmd || doAck
            WaitSecs(3);
        end
    end
    pnet(cmd_stimcon,'setwritetimeout',5);
    pnet(cmd_stimcon,'setreadtimeout',5);
    pnet(ack_stimcon,'setwritetimeout',5);
    pnet(ack_stimcon,'setreadtimeout',5);
    datanet=setCmdCon(datanet,cmd_stimcon);
    datanet=setAckCon(datanet,ack_stimcon);

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
                    pnet(datanet.cmdCon,'close');
                    pnet(datanet.ackCon,'close');
                    datanet.cmdCon=[];
                    datanet.ackCon=[];
                    % reconnect!
                    doCmd=true;
                    doAck=true;
                    while doCmd && doAck
                        if doCmd
                            cmd_stimcon=pnet(datanet.cmdSockcon,'tcplisten','noblock');
                        end
                        if doAck
                            ack_stimcon=pnet(datanet.ackSockcon,'tcplisten','noblock');
                        end
                        if cmd_stimcon==-1
                            fprintf('tried tcplisten on cmd port - no connection received\n')
                        else
                            fprintf('got connection on cmd port!\n')
                            doCmd=false;
                        end
                        if ack_stimcon==-1
                            fprintf('tried tcplisten on ack port - no connection received\n')
                        else
                            fprintf('got connection on ack port!\n')
                            doAck=false;
                        end
                    end
                    pnet(cmd_stimcon,'setwritetimeout',5);
                    pnet(cmd_stimcon,'setreadtimeout',5);
                    pnet(ack_stimcon,'setwritetimeout',5);
                    pnet(ack_stimcon,'setreadtimeout',5);
                    datanet=setCmdCon(datanet,cmd_stimcon);
                    datanet=setAckCon(datanet,ack_stimcon);

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
                    pnet(datanet.cmdCon,'close');
                    pnet(datanet.ackCon,'close');
                    pnet('closeall')
                    datanet.cmdCon=[];
                    datanet.ackCon=[];
                end
            end        
        end
    end
    
    pnet('closeall');
    disp('finished handling commands for this datanet, going back to bootstrap');
    
end

end % end function
