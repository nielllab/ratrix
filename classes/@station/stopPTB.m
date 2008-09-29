function s=stopPTB(s)

    s.ifi=[];
    s.window=[];
Screen('CloseAll');
Priority(0);
ShowCursor;


Screen('Resolution',0,1920,1200,0,32)
% following not true on osx:
% Psychtoolbox will automatically restore the systems display resolution to the
% system settings made via the display control panel as soon as either your script
% finishes by closing all its windows or by some error. Terminating Matlab due to
% quit command or due to crash will also restore the system preference settings.
% If you call this command without ever opening onscreen windows and closing them
% at some point, Psychtoolbox will not restore display settings automatically.