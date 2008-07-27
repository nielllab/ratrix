function [r rx]=unregisterClient(r,c,rx,subjects)
% IMPORTANT! Here is the higher level program acknowledging a disconnection
[tf loc]=clientIsRegistered(r,c);
if ~tf
    c
    
    warning('that client doesn''t exist in the register')
else
    [quit mac]=getClientMACaddress(r,c);
    if quit
        error('got a quit from getClientMACaddress for a registered client!')
    end
    
    fprintf('disconnecting %s\n',r.serverRegister{loc,2});
    inds = 1:size(r.serverRegister,1);
    r.serverRegister=r.serverRegister(inds(inds~=loc),:); %WOW.  those should be curlies!  how is that consistent syntax, mathworks?

        for i=1:length(subjects)
        %subjects{i}{2}{2}
        if strcmp(subjects{i}{2}{2},mac)
            rx=removeSubjectFromBox(rx,subjects{i}{1},getBoxIDForSubjectID(rx,subjects{i}{1}),'unregistering client','ratrix');
        end
    end


end