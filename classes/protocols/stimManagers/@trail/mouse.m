function pos=mouse(s)

if IsLinux
    %dual mouse stuff not yet complete
    
    [pos(1),pos(2),buttons,focus,valuators,valinfo] = GetMouse([],s.mouseIndices(1));
    
    if false
        screenNum=0; %should use [], but Error in function SetMouseHelper: 	Missing argument
        SetMouse(s.initialPos(1),s.initialPos(2),screenNum,s.mouseIndices(1));
        
        % Error in function SetMouseHelper: 	Usage error
        % Invalid 'mouseIndex' provided. No such master cursor pointer.
        
        % WTF, must be master?
    else
        SetMouse(s.initialPos(1),s.initialPos(2)); %good enough, actually? :)
    end
    
else
    [pos(1),pos(2)] = GetMouse;
    if ~IsOSX %takes 1/4 second on OSX for GetMouse to see something new after a call to SetMouse!
        % if ~all(pos==s.initialPos') %don't know why this is necessary, but if we don't do it, we never see any mouse movement
            SetMouse(s.initialPos(1),s.initialPos(2));
        % end
    end
end