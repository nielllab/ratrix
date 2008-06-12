function [quit com] = sendToClient(r,clientIdent,priority,command,arguments)
  import ratrix.net.*;
  quit=false;
  if ~isa(clientIdent,'RatrixNetworkClientIdent')
      clientIdent
      class(clientIdent)
      javaclasspath
    error('<clientIdent> argument must be a RatrixNetworkClientIdent object');
  end
  if ~exist('arguments','var')
      arguments = {};
  end
  if ~iscell(arguments)
    error('<arguments> argument must be a cell array');
  end
  jCom = RatrixNetworkCommand(r.server.getNextCommandUID(),clientIdent,priority,command);
  % Convert the matlab arguments into something java can understand
  jCom = packageArguments(r,jCom,arguments);
  try
      r.server.sendCommandToClient(jCom);
      com = rnetcommand(jCom);
  catch
      quit=true;
      lasterr
      x=lasterror;
      x.stack.file
      x.stack.line
      try
          f=fopen('SocketErrorLog.txt','a');
          fprintf(f,'%s: sendToClient in server socket error\n',datestr(now));
          fprintf(f,['\t' lasterr '\n']);
          fprintf(f,['\t' x.stack.file '\n']);
          fprintf(f,['\t' x.stack.line '\n']);
          fclose(f);
      catch
      end
      com=[];
  end
