function c = rnetcommand(varargin)

switch nargin
    case 0
        % if no input arguments, create a default object
        error('Default command not supported');
    case 1
        % if single argument of this class type, return it
        if isa(varargin{1},'rnetcommand')
            c = varargin{1};
            return;
        elseif isa(varargin{1},'ratrix.net.RatrixNetworkCommand')
            c.javaCommand = varargin{1};
            tmp = c.javaCommand.client;
            id = tmp.id.toCharArray();
            uid = c.javaCommand.getUID();
        else
            fprintf('Unknown class of cmd\n');
            disp(class(varargin{1}));
            error('Input argument is not a rnetcommand object');
        end;
    case 4
        uid = varargin{1};
        id = varargin{2};
        priority = varargin{3};
        command = varargin{4};
        arguments = {};
    case 5
        uid = varargin{1};
        id = varargin{2};
        priority = varargin{3};
        command = varargin{4};
        arguments = varargin{5};
    otherwise
        error('Wrong number of input arguments');
end

if nargin >1
    client = RatrixNetworkClientIdent(id);
    c.javaCommand = RatrixNetworkCommand(client,priority,command,arguments);
end
jc = c.javaCommand;
c.uid = uid;
c.id = id;
c.priority = jc.priority;
c.command = jc.command;
c.arguments = jc.getArguments();
if nargin > 0
    c = class(c,'rnetcommand');
end