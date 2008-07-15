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
        elseif isa(varargin{1},'rlab.net.RlabNetworkCommand')
            c.javaCommand = varargin{1};
            tmp = c.javaCommand.sendingNode.toString();
            sendingNodeId = tmp.toCharArray();
            tmp = c.javaCommand.receivingNode.toString();
            receivingNodeId = tmp.toCharArray();
            uid = c.javaCommand.getUID();
        else
            fprintf('Unknown class of cmd\n');
            disp(class(varargin{1}));
            error('Input argument is not a rnetcommand object');
        end;
    case 5
        uid = varargin{1};
        sendingNodeId = varargin{2};
        receivingNodeId = varargin{3};
        priority = varargin{4};
        command = varargin{5};
        arguments = {};
    case 6
        uid = varargin{1};
        sendingNodeId = varargin{2};
        receivingNodeId = varargin{3};
        priority = varargin{4};
        command = varargin{5};
        arguments = varargin{6};
    otherwise
        error('Wrong number of input arguments');
end


if nargin >1
    sNode = RlabNetworkNodeIdent(sendingNodeId);
    rNode = RlabNetworkNodeIdent(receivingNodeId);
    c.javaCommand = RlabNetworkCommand(uid,sNode,rNode,priority,command,arguments);
end
jc = c.javaCommand;
c.uid = uid;
c.sendingNodeId = sendingNodeId;
c.receivingNodeId = receivingNodeId;
c.priority = jc.priority;
c.command = jc.command;
c.arguments = jc.getArguments();
if nargin > 0
    c = class(c,'rnetcommand');
end