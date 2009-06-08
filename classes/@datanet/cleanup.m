function dn = cleanup(dn)
% cleans up the socket and connection for a datanet object
% we will do this under normal shutdown circumstances (after stopping NIDAQ
% and sending a shutdown cmd to data machine)
% but also when ratrix side throws an error, we can't send a normal
% shutdown cmd, so we just cleanup instead, and know that the data side
% will catch the pnet('close') using 'status'

dn.cmdSockcon=[];
dn.ackSockcon=[];
dn.cmdCon=[];
dn.ackCon=[];
end