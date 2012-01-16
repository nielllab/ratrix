function pos=mouse(s)

if IsLinux
    %dual mouse stuff
    error('not yet written')

    [x,y,buttons,focus,valuators,valinfo] = GetMouse(windowPtrOrScreenNumber, mouseDev);
    SetMouse(x,y,windowPtrOrScreenNumber, mouseid);    
else
    [pos(1),pos(2)] = GetMouse;
    SetMouse(s.initialPos(1),s.initialPos(2));
end