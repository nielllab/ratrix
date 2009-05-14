function datacon = connectToClient(datanet,hostname)
% this function tries to connect to the client's bootstrap loop
% INPUTS:
%	datanet - the server datanet object
%	hostname - hostname of the client
% OUTPUTS:
%	datacon - returns a valid pnet connection if ratrix exists;
%		 otherwise returns an empty that physiologyServer knows to interpret as doing standalone phys logging
MAX_SIZE=1024*1024;

if strmatch(datanet.type, 'stim')
    error('must be called on datanet of type ''data''');
end

% connect to client - this part needs to be allowed to fail, in case we want to run the phys logger in standAlone (w/o a ratrix)
% actually, this startClientTrials function gets called by physiologyServer, and should be allowed to return a 'fail' (ie empty datacon)
datacon=-1;
maxConnectAttempts=1;
tryNum=1;
while datacon==-1
    if tryNum>maxConnectAttempts
		% failed to find a ratrix client - assume we want to standalone phys log
		datacon=[];
		return;
    end
    fprintf('trying tcpconnect\n');
    datacon=pnet('tcpconnect',hostname,8888); % stim=client
    if datacon==-1
        fprintf('could not tcpconnect to client listener - perhaps you need to start the client bootstrap?\n');
    end
    tryNum=tryNum+1;  
end

end % end function