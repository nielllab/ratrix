function cmd=checkForSpecificCommand(varargin);
cmd=[];
if nargin>=1 && isa(varargin{1},'rnet')
  r = varargin{1};
else
  error('checkForSpecificCommand() must pass in rnet object as first parameter');
end
switch nargin
 case 3
  client = varargin{2};
  command = varargin{3};
  priority = [];
 case 4
  client = varargin{2};
  command = varargin{3};
  priority = varargin{4};
 otherwise
  error('bad number of arguments to check for specific command');
end

switch r.type
 case r.constants.nodeTypes.SERVER_TYPE
  if isempty(priority)
    cmd = r.server.checkForSpecificCommand(client,command);
  else
    cmd = r.server.checkForSpecificCommand(client,command,priority);
  end
 case r.constants.nodeTypes.CLIENT_TYPE
  if isempty(priority)
    cmd = r.client.checkForSpecificCommand(command);
  else
    cmd = r.client.checkForSpecificCommand(command,priority);
  end
 otherwise
  error('bad rnet node type')
end

if ~isempty(cmd)
    % Turn the command into a matlab object command
    'Got a valid command converting to rnetcommand()'
    cmd = rnetcommand(cmd);
end
