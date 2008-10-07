function [didAPause paused done response doValves ports didValves didHumanResponse manual doPuff pressingM pressingP] = ...
  handleKeyboard(tm, keyCode, didAPause, paused, done, response, doValves, ports, didValves, ...
  didHumanResponse, manual, doPuff, pressingM, pressingP, allowQPM, originalPriority, priorityLevel)

% This function handles the keyboard input part of stimOGL.
% Part of stimOGL rewrite.
% INPUT: keyCode, didAPause, paused, done, response, doValves, ports, didValves, didHumanResponse, manual, doPuff, pressingM, pressingP, allowQPM,
%            originalPriority, priorityLevel
% OUTPUT: didAPause, paused, done, response, doValves, ports, didValves, didHumanResponse, manual, doPuff, pressingM, pressingP

% note: this function pretty much updates a bunch of flags....

%logwrite(sprintf('keys are down:',num2str(find(keyCode))));

mThisLoop = 0;
pThisLoop = 0;
asciiOne=49;

keys=find(keyCode);
ctrlDown=0; %these don't get reset if keyIsDown fails!
shiftDown=0;
kDown=0;
for keyNum=1:length(keys)
    shiftDown = shiftDown || strcmp(KbName(keys(keyNum)),'shift');
    ctrlDown = ctrlDown || strcmp(KbName(keys(keyNum)),'control');
    kDown= kDown || strcmp(KbName(keys(keyNum)),'k');
end

if kDown
    for keyNum=1:length(keys)
        keyName=KbName(keys(keyNum));

        if strcmp(keyName,'p')
            pThisLoop=1;

            if ~pressingP && allowQPM

                didAPause=1;
                paused=~paused;

                if paused
                    Priority(originalPriority);
                else
                    Priority(priorityLevel);
                end

                pressingP=1;
            end
        elseif strcmp(keyName,'q') && ~paused && allowQPM
            done=1;
            response='manual kill';

        elseif ~isempty(keyName) && ismember(keyName(1),char(asciiOne:asciiOne+length(ports)-1))
            if shiftDown
                if keyName(1)-asciiOne+1 == 2
                    'WARNING!!!  you just hit shift-2 ("@"), which mario declared a synonym to sca (screen(''closeall'')) -- everything is going to break now'
                    'quitting'
                    done=1;
                    response='shift-2 kill';
                end
            end
            if ctrlDown
                doValves(keyName(1)-asciiOne+1)=1;
                didValves=true;
            else
                ports(keyName(1)-asciiOne+1)=1;
                didHumanResponse=true;
            end
        elseif strcmp(keyName,'m')
            mThisLoop=1;

            if ~pressingM && ~paused && allowQPM

                manual=~manual;
                pressingM=1;
            end
        elseif strcmp(keyName,'a') % check for airpuff
            doPuff=true;
        end
    end
end

if ~mThisLoop && pressingM
    pressingM=0;
end
if ~pThisLoop && pressingP
    pressingP=0;
end