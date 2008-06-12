function cmd=checkForSpecificCommands(varargin)

cmd=[];

if nargin>=1 && isa(varargin{1},'rnet')
  r = varargin{1};
else
  error('checkForSpecificCommands() must pass in rnet object as first parameter');
end
allPrio = getSortedPrioritiesHighestFirst(r);

switch nargin
 case 3
  client = varargin{2};
  commands = varargin{3};
  priorities = allPrio; % Get all the priorities
 case 4
  client = varargin{2};
  commands = varargin{3};
  lowestPriority = varargin{4};
  if ~isValidPriority(r,lowestPriority)
    error('checkForSpecificCommands() priority is not valid');
  end
  % Get the subset of priorities that are equal or higher than lowestPriority
  priorities=allPrio(1:find(allPrio==lowestPriority));
 otherwise
  error('bad number of arguments to checkForSpecificCommands()');
end

% Look at the highest priorities first
for p=1:length(priorities)
  % Within the same priority, look at each command in the order given
  for c=1:length(commands)
    cmd=checkForSpecificCommand(r,client,commands(c),priorities(p));
    if ~isempty(cmd)
      % Found the corresponding command at an acceptable priority
      return;
    end
  end
end