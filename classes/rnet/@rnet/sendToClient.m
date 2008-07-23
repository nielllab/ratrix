function [quit com] = sendToClient(r,clientId,priority,command,arguments)
  import rlab.net.*;
  quit=false;
  if ~isa(clientId,'RlabNetworkNodeIdent')
      clientId
      class(clientId)
      javaclasspath
    error('<clientId> argument must be a RlabNetworkNoteIdent object');
  end
  if ~exist('arguments','var')
      arguments = {};
  end
  if ~iscell(arguments)
    error('<arguments> argument must be a cell array');
  end
  jCom = RlabNetworkCommand(r.server.getNextCommandUID(),r.server.getLocalNodeId(),clientId,priority,command);
  % Convert the matlab arguments into something java can understand
  jCom = packageArguments(r,jCom,arguments);
  try
      r.server.sendImmediately(jCom);
      com = rnetcommand(jCom);
  catch ex
      quit=true;
      
      'got a quit in sendToClient on command'
      command
      'to client'
      clientId
      
        ple
      
      try
          f=fopen('SocketErrorLog.txt','a');
          fprintf(f,'%s: sendToClient in server socket error\n',datestr(now));
          fprintf(f,['\t' ex.message '\n']);
          fprintf(f,['\t' ex.stack.file '\n']);
          fprintf(f,['\t' ex.stack.line '\n']);
          fclose(f);
      catch
      end
      com=[];
  end
