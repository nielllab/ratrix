function [quit com] = sendToServer(r,clientId,priority,command,arguments)
  import rlab.net.*;  
  quit=false;
  if ~isa(clientId,'RlabNetworkNodeIdent')
    error('<clientId> argument must be a RlabNetworkNodeIdent object');
  end
  if ~exist('arguments','var')
      arguments = {};
  end
  if ~iscell(arguments)
    error('<arguments> argument must be a cell array');
  end
  jCom = RlabNetworkCommand(r.client.getNextCommandUID(),clientId,r.client.getRemoteNodeId(),priority,command);
  % Convert the matlab arguments into something java can understand
  jCom = packageArguments(r,jCom,arguments);
  try
      r.client.sendImmediately(jCom);
      com = rnetcommand(jCom);
  catch
      quit=true;
      lasterr
      x=lasterror;
      x.stack.file
      x.stack.line
      try
          f=fopen('SocketErrorLog.txt','a');
          fprintf(f,'%s: sendToServer from %s in client socket error\n',datestr(now),r.id);
          fprintf(f,['\t' lasterr '\n']);
          fprintf(f,['\t' x.stack.file '\n']);
          fprintf(f,['\t' x.stack.line '\n']);
          fclose(f);
      catch
      end
      com=[];
  end
  
