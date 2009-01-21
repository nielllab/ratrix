function [didAPause paused done response doValves ports didValves didHumanResponse manual doPuff pressingM pressingP] = ...
  handleKeyboard(tm, keyCode, didAPause, paused, done, response, doValves, ports, didValves, ...
  didHumanResponse, manual, doPuff, pressingM, pressingP, allowQPM, originalPriority, priorityLevel, KbConstants)

% This function handles the keyboard input part of stimOGL.
% Part of stimOGL rewrite.
% INPUT: keyCode, didAPause, paused, done, response, doValves, ports, didValves, didHumanResponse, manual, doPuff, pressingM, pressingP, allowQPM,
%            originalPriority, priorityLevel
% OUTPUT: didAPause, paused, done, response, doValves, ports, didValves, didHumanResponse, manual, doPuff, pressingM, pressingP

% note: this function pretty much updates a bunch of flags....

%logwrite(sprintf('keys are down:',num2str(find(keyCode))));

mThisLoop = 0;
pThisLoop = 0;

shiftDown=any(keyCode(KbConstants.shiftKeys));
ctrlDown=any(keyCode(KbConstants.controlKeys));
atDown=any(keyCode(KbConstants.atKeys));
kDown=any(keyCode(KbConstants.kKey));
portsDown=false(1,length(KbConstants.portKeys));
%             arrowKeyDown=false; % initialize this variable
% 1/9/09 - phil to add stuff about arrowKeyDown
for pNum=1:length(KbConstants.portKeys)
    portsDown(pNum)=any(keyCode(KbConstants.portKeys{pNum}));
    %                 arrowKeyDown=arrowKeyDown || any(strcmp(KbName(keys(keyNum)),{'left','down','right'}));
end
            
%map a 1-key shortcut left center right reponse - this 
%            if arrowKeyDown
%                 for keyNum=1:length(keys)
%                     keyName=KbName(keys(keyNum));
%                     if strcmp(keyName,'left')
%                         %doValves(1)=1;
%                         ports(1)=1;
%                         didHumanResponse=true;
%                     end
%                     if strcmp(keyName,'down')
%                         %doValves(2)=1;
%                         ports(2)=1;
%                         didHumanResponse=true;
%                     end
%                     if  strcmp(keyName,'right')
%                         %doValves(3)=1;
%                         ports(3)=1;
%                         didHumanResponse=true;
%                     end
%                 end              
%            end
            
if kDown
    if any(keyCode(KbConstants.pKey))
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
    elseif any(keyCode(KbConstants.qKey)) && ~paused && allowQPM
        done=1;
        response='manual kill';
    elseif any(portsDown)
        if shiftDown
            if atDown && portsDown(2)
                %note that this misses shift-2 without 'k'...  :(
                'WARNING!!!  you just hit shift-2 ("@"), which mario declared a synonym to sca (screen(''closeall'')) -- everything is going to break now'
                'quitting'
                done=1;
                response='shift-2 kill';
            end
        end
        if ctrlDown
            doValves(portsDown)=1;
            didValves=true;
        else
            ports(portsDown)=1;
            didHumanResponse=true;
        end
    elseif any(keyCode(KbConstants.mKey))
        mThisLoop=1;

        if ~pressingM && ~paused && allowQPM

            manual=~manual;
            pressingM=1;
        end
    elseif any(keyCode(KbConstants.aKey))
        doPuff=true;
    elseif any(keyCode(KbConstants.rKey)) && strcmp(getRewardMethod(station),'localPump')
        doPrime(station);
    end
end
if ~mThisLoop && pressingM
    pressingM=0;
end
if ~pThisLoop && pressingP
    pressingP=0;
end

end % end function