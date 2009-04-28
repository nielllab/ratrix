function out = userPrompt(window,validInputs,type,typeParams)
% this function uses the PTB Screen to prompt for user input
% currently used for manual training step changes (k+t) and flushPorts calibration (k+f)
% INPUTS:
%   window - the PTB window pointer
%   validInputs - a cell array of vectors of valid inputs (one vector per 'prompt')
%   type - either 'manual ts' or 'flushPorts'
%   typeParams - a struct containing type-specific values
% OUTPUTS:
%   out - depends on type; the new trainingStep number if 'manual ts'; nothing if 'flushPorts'?

ListenChar(2);

KbName('UnifyKeyNames');

KbConstants.allKeys=KbName('KeyNames');
KbConstants.allKeys=lower(cellfun(@char,KbConstants.allKeys,'UniformOutput',false));
KbConstants.asciiZero=double('0');
KbConstants.numKeys={};
for i=1:10
    KbConstants.numKeys{i}=find(strncmp(char(KbConstants.asciiZero+i-1),KbConstants.allKeys,1));
end
KbConstants.enterKey=KbName('RETURN');
KbConstants.deleteKeys=[KbName('delete')]; %this errors on osx and is covered by unifykeynames: KbName('backspace')];
KbConstants.decimalKey=[KbName('.>') KbName('.')];

Screen('Preference', 'TextRenderer', 0);  % consider moving to station.startPTB
Screen('Preference', 'TextAntiAliasing', 0); % consider moving to station.startPTB
allowKeyboard=true;
Screen('FillRect',window,200*ones(1,3));
entry='';
out=[];

port=[];
numSquirts=[];
squirtDuration=[];
isi=[];

% error-check based on type
if ischar(type)
    if strcmp(type,'manual ts')
        if isfield(typeParams,'currentTsNum') && isfield(typeParams,'trainingStepNames')
            % pass
        else
            error('manual ts userPrompt needs currentTsNum and trainingStepNames');
        end
    elseif strcmp(type,'flushPorts')
        % nothing
    else
        error('unsupported type');
    end
else
    error('type must be a string');
end



while isempty(out)

    yTextPos=20;
    if strcmp(type,'manual ts')
        text=sprintf('Enter new trainingStepNum between %d and %d (current trainingStepNum is %d)',validInputs{1}(1),validInputs{1}(end),typeParams.currentTsNum);
        for j=1:length(typeParams.trainingStepNames)
            jtext=sprintf('Training step %d: %s',j,typeParams.trainingStepNames{j});
            Screen('DrawText',window,jtext,10,yTextPos,100*ones(1,3));
            yTextPos=yTextPos+20;
        end
        textprompt=sprintf('New trainingStepNum: %s',entry);
        i=1;
    else
        if isempty(port)
            text=sprintf('Select a port (%d-%d, %d for all ports):',validInputs{1}(2),validInputs{1}(end),validInputs{1}(1));
            i=1;
        elseif isempty(numSquirts)
            text=sprintf('Select number of water squirts (%d-%d):',validInputs{2}(1),validInputs{2}(2));
            i=2;
        elseif isempty(squirtDuration)
            text=sprintf('Select squirt duration in seconds (%d-%d):',validInputs{3}(1),validInputs{3}(2));
            i=3;
        else
            text=sprintf('Select delay between squirts in seconds (%d-%d):',validInputs{4}(1),validInputs{4}(2));
            i=4;
        end
        textprompt=sprintf('New value: %s',entry);
    end


    Screen('DrawText',window,text,10,yTextPos,100*ones(1,3));
    Screen('DrawText',window,textprompt,10,yTextPos+20,100*ones(1,3));
    Screen('Flip',window);

    % read from keyboard
    [keyIsDown,secs,keyCode]=KbCheck;
    if keyIsDown
        numsDown=false(1,length(KbConstants.numKeys));
        for nNum=1:length(KbConstants.numKeys)
            numsDown(nNum)=any(keyCode(KbConstants.numKeys{nNum}));
        end
        enterDown=any(keyCode(KbConstants.enterKey));
        deleteDown=any(keyCode(KbConstants.deleteKeys));
        decimalDown=any(keyCode(KbConstants.decimalKey));

        if any(numsDown) && allowKeyboard
            newNum=find(numsDown)-1;
            if length(newNum)==1
                entry=[entry char(newNum+KbConstants.asciiZero)];
            else
                % how did you have multiple number inputs? - we should ignore this
            end
        elseif deleteDown && allowKeyboard
            if ~isempty(entry)
                entry(end)=[];
            end
        elseif decimalDown && allowKeyboard
            entry=[entry '.'];
        elseif enterDown && allowKeyboard
            [entry valid]=checkValidity(entry,validInputs{i});
            if valid
                if strcmp(type,'manual ts')
                    out=uint16(entry);
                else
                    if isempty(port)
                        port=entry;
                    elseif isempty(numSquirts)
                        numSquirts=entry;
                    elseif isempty(squirtDuration)
                        squirtDuration=entry;
                    else
                        isi=entry;
                        out=[port numSquirts squirtDuration isi];
                    end
                    entry='';
                end
            else
                text=sprintf('Invalid entry! Please try again.');
                Screen('DrawText',window,text,10,60,100*ones(1,3));
                Screen('Flip',window);
                WaitSecs(3);
            end
        end
        allowKeyboard=false;
    else
        allowKeyboard=true;
    end

end % end while loop

end % end function

function [entry valid] = checkValidity(entry,valids)
if length(valids)==2 % check against a range
    if ~isempty(str2num(entry)) && str2num(entry)>=valids(1) && str2num(entry)<=valids(2)
        entry=str2double(entry);
        valid=true;
    else
        entry='';
        valid=false;
    end
else % check against a list of values
    if ~isempty(str2num(entry)) && ~isempty(find(valids==str2num(entry)))
        entry=str2double(entry);
        valid=true;
    else
        entry='';
        valid=false;
    end
end
end % end function