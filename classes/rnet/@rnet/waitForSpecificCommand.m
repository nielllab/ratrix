function [quit cmd com args]=waitForSpecificCommand(r,client,command,timeout,errStr,stat)

quit=false;
cmd=[];
com=[];
args=[];
startTime=GetSecs();

switch r.type
    case r.constants.nodeTypes.SERVER_TYPE
        emergencyCommands=[r.constants.stationToServerCommands.C_CMD_ERR];
        lightweightCommands=[];

        [tf loc]=clientIsRegistered(r,client);
        if tf
            mac=r.serverRegister{loc,2};
        else
            mac='unregistered client';
        end

    case r.constants.nodeTypes.CLIENT_TYPE
        mac='server';
        lightweightCommands=[r.constants.serverToStationCommands.S_GET_MAC_CMD,r.constants.serverToStationCommands.S_GET_STATUS_CMD];
        emergencyCommands=[r.constants.serverToStationCommands.S_STOP_TRIALS_CMD,r.constants.serverToStationCommands.S_SHUTDOWN_STATION_CMD];
    otherwise
        error('bad rnet.type')
end

if timeout<=0
    f=fopen('cmdLog.txt','a');
    fprintf(f,'%s: waitForSpecificCommand from %s (willing to wait forever): %s\n',datestr(now), mac, errStr);
    fclose(f);

end

highPriorityCommands=[emergencyCommands(:)',lightweightCommands(:)'];
commandsToWaitFor = [highPriorityCommands,command];
ps=getSortedPrioritiesHighestFirst(r);
lowestPriority = ps(end);
priorities = [repmat(r.constants.priorities.IMMEDIATE_PRIORITY,1,length(highPriorityCommands)),lowestPriority];

% Wait for commands to appear
cmd=waitForCommands(r,client,commandsToWaitFor,priorities,timeout);

switch r.type
 case r.constants.nodeTypes.SERVER_TYPE
  if ~isConnected(r,client) || isClientReregistered(r,client)
    try
      f=fopen('SocketErrorLog.txt','a');
      fprintf(f,'%s: waitForSpecificCommand from %s server unexpectedly no longer connected to this client\n',datestr(now),mac);
      fclose(f);
    catch ex
        ple(ex)
    end
    'waitForSpecificCommand: Client no longer connected'
    client.id
    isConnected(r,client)
    isClientReregistered(r,client)
    quit=true;
  end
 case r.constants.nodeTypes.CLIENT_TYPE
  if ~isConnected(r)
    quit=true;
  end
end
if ~isempty(cmd)

  f=fopen('cmdLog.txt','a');
  fprintf(f,'%s: waitForSpecificCommand from %s: %s, got match or lightweight/emergency after %g\n',datestr(now), mac, errStr, GetSecs()-startTime);
  fclose(f);
  
  
  [good com args]=validateCommand(r,cmd);
  if ~good
    cmd=[];
  end
  
  if command~=com
    'handling unexpected command!'
    
    switch r.type
     case r.constants.nodeTypes.SERVER_TYPE
      serverHandleCommand(r,cmd,[],[],[]);
      quit=true; %hack for now, cuz only emergency commands are errors
     case r.constants.nodeTypes.CLIENT_TYPE
      quit=clientHandleVerifiedCommand(r,cmd,com,args,stat);
    end
    
    
    
    if quit
      'got an unexpected quit!'
    elseif ismember(com,lightweightCommands)
      cmd=[];
    end
  end
end

if ~isempty(cmd)
  fprintf('Received command %d\n',getCommand(cmd));
end
fprintf('Number of commands available %d\n',commandsAvailable(r));
if isempty(cmd)
    client
  warning(['timed out: ' errStr])
  
  
  f=fopen('cmdLog.txt','a');
  fprintf(f,'%s: timed out of: %s, ignored %d commands in queue\n',datestr(now), errStr, commandsAvailable(r));
  fclose(f);
  

end