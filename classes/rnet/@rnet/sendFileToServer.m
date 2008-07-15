function quit=sendFileToServer(r,clientId,priority,command,arguments,files)

error('sendFileToServer(): This should never be used')
% Go through the list of files and send them over the filesystem
  driveLetter = 'z';
  serverAddress = '132.239.158.169';
  % The share name used on the server
  serverShare = 'Ratrix';
  % The server share mapping to the server's local filesystem
  serverShareLocal = 'C:\Ratrix'; 
  commPath = 'Network\Incoming'; % Location on share to store .mat objects being sent to
  % another computer
  serverPath = sprintf('\\\\%s\\%s',serverAddress,serverShare);
  serverPassword = 'Pac3111';
  serverUsername = 'rlab';
  
  if ~ispc
      error('File transfer mechanism in rnet is windows specific!');
  end
  
  % Mount remote filesystem
  [status result]= dos(sprintf('net use %s: /delete',driveLetter));
  % Don't care if the removal didn't work
  [status result] = dos(sprintf('net use %s: %s %s /USER:%s',driveLetter,serverPath,serverPassword,serverUsername));
  if status ~= 0
      error('Unable to mount remote filesystem');
  end
  fileStr = '';
  for i=1:length(files)
      fileStr = strcat(fileStr,files{i},' ');
  end
  [status result] = dos(sprintf('copy /Y %s %s:\\%s',fileStr,driveLetter,commPath));
  if status ~= 0
      error('Unable to copy file to remote filesystem');
  end  
  dos(sprintf('net use %s: /delete',driveLetter));
  % Send the command to the server
  quit=sendToServer(r,clientId,priority,command,arguments)
