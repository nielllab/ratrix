function r=svnUpdate(r,targetRevision)
% Shutdown server/client, and remove the java server/client object

info.type = r.type;
info.serverType = r.constants.nodeTypes.SERVER_TYPE;
info.clientType = r.constants.nodeTypes.CLIENT_TYPE;
info.id = r.id;
info.host = r.host;
info.port = r.port;

r=shutdown(r);

% Update the Ratrix codebase using SVN
% Determine the root directory for the ratrix code
% If no revision is specified, supply the empty string
if nargin <= 1
    targetRevision = '';
end
svnPath = GetSubversionPath;

% Construct svn update command
info.updateCommand=[svnPath 'svn update '  targetRevision getRatrixPath ];
save('info.mat','info');

% Clear java classes
clearJavaComponents();
clearJavaComponents();

whos
clear all
java.lang.System.gc();
WaitSecs(5)
clear all
java.lang.System.gc();
x=whos
clear java
clearJavaComponents();
import ratrix.net.*;  

load('info.mat','info');
% Run svn update command
% if IsWin
%     s = dos(info.updateCommand);
% else
    [s result] = system(info.updateCommand);
% end

%Check return arguments to verify success
if s~=0
  warning('SVN update not successful!');
  result
end
  
% Update psychtoolbox
updatePsychtoolboxIfNecessary

% Reload java classes
addJavaComponents();
import ratrix.net.*;



% Once the command is completed, then start up the client/server again
successful=false;
while ~successful
  try
    switch info.type
     case info.serverType
      r = rnet('server',info.port);
     case info.clientType
      r = rnet('client',info.id,info.host,info.port);
     otherwise
      error('In svnUpdate(): Unknown node type');
    end
    successful = true;
  catch ex
    successful = false;
    ple(ex)
    pause(1.0);
    fprintf('Attempting to reconnect in svnUpdate()\n');
  end
end
