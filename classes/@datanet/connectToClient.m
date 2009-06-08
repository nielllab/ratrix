function [dataCmdCon dataAckCon] = connectToClient(datanet,hostname)
% this function tries to connect to the client's bootstrap loop
% INPUTS:
%	datanet - the server datanet object
%	hostname - hostname of the client
% OUTPUTS:
%	dataCmdCon - returns a valid pnet connection if ratrix exists;
%		 otherwise returns an empty that physiologyServer knows to interpret as doing standalone phys logging
%   dataAckCon - the ack channel connection
MAX_SIZE=1024*1024;

if strmatch(datanet.type, 'stim')
    error('must be called on datanet of type ''data''');
end

% connect to client - this part needs to be allowed to fail, in case we want to run the phys logger in standAlone (w/o a ratrix)
% actually, this startClientTrials function gets called by physiologyServer, and should be allowed to return a 'fail' (ie empty datacon)
doCmd=true;
doAck=true;

maxConnectAttempts=1;
tryNum=1;
while doCmd && doAck
    if tryNum>maxConnectAttempts
		% failed to find a ratrix client - assume we want to standalone phys log
		dataCmdCon=[];
        dataAckCon=[];
		return;
    end
    if doCmd
        fprintf('trying tcpconnect to 8888 (cmd channel)\n');
        dataCmdCon=pnet('tcpconnect',hostname,8888); % stim=client
    end
    if doAck
        fprintf('trying tcpconnect to 8889 (ack channel)\n');
        dataAckCon=pnet('tcpconnect',hostname,8889); % stim=client
    end
    if dataCmdCon==-1
        fprintf('could not tcpconnect to client listener on cmd channel - perhaps you need to start the client bootstrap?\n');
    else
        doCmd=false;
    end
    if dataAckCon==-1
        fprintf('could not tcpconnect to client listener on ack channel - perhaps you need to start the client bootstrap?\n');
    else
        doAck=false;
    end
    tryNum=tryNum+1;  
end

end % end function