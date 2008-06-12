function quit=clientHandleCommand(r,com,status)

if ~isValidStatus(r,status)
    error('status must be a status constant as defined in rnet.m')
end

quit=false;
[good cmd args] = validateCommand(r,com);

if good
    quit=clientHandleVerifiedCommand(r,com,cmd,args,status);
end