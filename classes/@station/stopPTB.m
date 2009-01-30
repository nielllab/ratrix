function s=stopPTB(s)

s.ifi=[];
s.window=[];
Screen('CloseAll');
Priority(0);
ShowCursor;

if ismac
    x=Screen('Resolutions',s.screenNum);
    x=x([x.pixelSize]==max([x.pixelSize]) & [x.hz]==max([x.hz]) & [x.width].*[x.height]==max([x.height].*[x.width]));
    if length(x)>1
        x=x(1);
    elseif length(x)<1
        error('can''t maximize depth, hz, and width x height simultaneously')
    end
    Screen('Resolution',s.screenNum,x.width,x.height,x.hz,x.pixelSize);
    %Screen('Resolution',0,1920,1200,0,32) %- 9/29/08 - THIS CRASHES WINDOWS-BASED MACHINES? - discuss
    
    % following not true on osx:
    % Psychtoolbox will automatically restore the systems display resolution to the
    % system settings made via the display control panel as soon as either your script
    % finishes by closing all its windows or by some error. Terminating Matlab due to
    % quit command or due to crash will also restore the system preference settings.
    % If you call this command without ever opening onscreen windows and closing them
    % at some point, Psychtoolbox will not restore display settings automatically.
    
    for i=1:20
        ShowCursor %seems to get stuck in multiple layers of hidecursor
    end
end