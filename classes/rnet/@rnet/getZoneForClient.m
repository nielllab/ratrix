function out=getZoneForClient(r,c)
[tf loc]=clientIsRegistered(r,c);
if tf
    out=r.serverRegister{loc,3};
else
    error('that client is not registered')
end