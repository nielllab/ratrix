function pos=mouse(s)

if IsLinux
    %dual mouse stuff
    error('not yet written')
    
    [x,y,buttons,focus,valuators,valinfo] = GetMouse(windowPtrOrScreenNumber, mouseDev);
    SetMouse(x,y,windowPtrOrScreenNumber, mouseid);
else
    [pos(1),pos(2)] = GetMouse;
    if ~IsOSX %takes 1/4 second on OSX for GetMouse to see something new after a call to SetMouse!
        if ~all(pos==s.initialPos') %don't know why this is necessary, but if we don't do it, we never see any mouse movement
            SetMouse(s.initialPos(1),s.initialPos(2));
        end
    end
end