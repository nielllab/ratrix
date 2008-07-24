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
  catch ex
      quit=true;

      ple(ex)
      try
          f=fopen('SocketErrorLog.txt','a');
          fprintf(f,'%s: sendToServer from %s in client socket error\n',datestr(now),r.id);
          fprintf(f,['\t' ex.message '\n']);
          fprintf(f,['\t' ex.stack.file '\n']);
          fprintf(f,['\t' ex.stack.line '\n']);
          fclose(f);
      catch ex
          ple(ex)
      end
      com=[];
  end
  
