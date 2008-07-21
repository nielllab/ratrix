function kbTest
ListenChar(2);

openwindow=false; %if true, keys are typed through

if openwindow
    w =Screen('OpenWindow',max(Screen('Screens')));
end

quit=false;
while ~quit
    [keyIsDown,secs,keyCode]=KbCheck;
    if keyIsDown
        keys=find(keyCode);
        for keyNum=1:length(keys)
            if strcmp(KbName(keys(keyNum)),'q');
                quit=true;
            end
        end
    end
end
if openwindow
    Screen('CloseAll');
end

ListenChar(0)