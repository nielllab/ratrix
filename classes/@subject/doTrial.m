function [subject r keepWorking secsRemainingTilStateFlip trialRecords station] ...
    =doTrial(subject,r,station,rn,trialRecords,sessionNumber)

if isa(r,'ratrix') && isa(station,'station') && (isempty(rn) || isa(rn,'rnet'))
    [p t]=getProtocolAndStep(subject);
    if t>0
        ts=getTrainingStep(p,t);

        [graduate keepWorking secsRemainingTilStateFlip subject r trialRecords station manualTs] ...
            =doTrial(ts,station,subject,r,rn,trialRecords,sessionNumber);
        %'subject'
%         newTrialRecords

        % 1/22/09 - if newTsNum is not empty, this means we want to manually move the trainingstep (not graduate)
        if manualTs
            newTsNum=[];
            [garbage currentTsNum]=getProtocolAndStep(subject);
            validTs=[1:getNumTrainingSteps(p)];
            entry='';
            priorityLevel=MaxPriority('GetSecs','KbCheck');
            Priority(priorityLevel);
            ListenChar(2);
            
            KbConstants.allKeys=KbName('KeyNames');
            KbConstants.allKeys=lower(cellfun(@char,KbConstants.allKeys,'UniformOutput',false));
            KbConstants.asciiZero=double('0');
            KbConstants.numKeys={};
            for i=1:10
                KbConstants.numKeys{i}=find(strncmp(char(KbConstants.asciiZero+i-1),KbConstants.allKeys,1));
            end
            KbConstants.enterKey=KbName('RETURN');
%             stopPTB(station);
%             startPTB(station);
            Screen('Preference', 'TextRenderer', 0);  % consider moving to station.startPTB
            Screen('Preference', 'TextAntiAliasing', 0); % consider moving to station.startPTB
            window=getPTBWindow(station);
            allowKeyboard=true;
            Screen('FillRect',window,200*ones(1,3));
            while isempty(newTsNum)
                
                text=sprintf('Enter new trainingStepNum between %d and %d (current trainingStepNum is %d)',validTs(1),validTs(end),currentTsNum);
                Screen('DrawText',window,text,10,20,100*ones(1,3));
                text=sprintf('New trainingStepNum: %s',entry);
                Screen('DrawText',window,text,10,40,100*ones(1,3));
                Screen('Flip',window);
                
                % read from keyboard
                [keyIsDown,secs,keyCode]=KbCheck; % do this check outside of function to save function call overhead
                if keyIsDown
                    numsDown=false(1,length(KbConstants.numKeys));
                    for nNum=1:length(KbConstants.numKeys)
                        numsDown(nNum)=any(keyCode(KbConstants.numKeys{nNum}));
                    end
                    enterDown=any(keyCode(KbConstants.enterKey));
                                        
                    if any(numsDown) && allowKeyboard
                        newNum=find(numsDown)-1;
                        if length(newNum)==1
                            entry=[entry char(newNum+KbConstants.asciiZero)];
                        else
                            % how did you have multiple number inputs? - we should ignore this
                        end
                    elseif enterDown && allowKeyboard
                        if ~isempty(str2num(entry)) && ~isempty(find(validTs==str2num(entry)))
                            newTsNum=uint16(str2num(entry));
                            trialRecords(end).result=[trialRecords(end).result ' ' entry];
                        else
                            text=sprintf('Invalid trainingStepNum! Please try again.');
                            Screen('DrawText',window,text,10,60,100*ones(1,3));
                            Screen('Flip',window);
                            entry='';
                            WaitSecs(3);
                        end
                    end
                    allowKeyboard=false;
                else
                    allowKeyboard=true;
                end
                
            end % end while loop
            
            % do we need to do this? datanet belongs to the trialManager, but we do not flag updateTM (because setup datanet is typically
            % done during station/doTrials (before we even care about updating tm)
            % so, we cant persist datanet across stim switching
            % stop datanet here if it exists - subject = setUpOrStopDatanet(subject,'stop',[]);
            % if that is causing it to hang...
            % also need to check to see if we want to start datanet/eyeTracker for newTsNum...wtf this sucks b/c all this is handled in doTrials
            % call setUpDatanet AFTER updating the subject's stepNum (this is used in trainingStep.setUpDatanet)
            % note that this will have bad interaction with the listener - stop(datanet) causes listener to shutdown
            % so user will have to manually restart listener after stim switching...
            if newTsNum~=currentTsNum
                %subject = setUpOrStopDatanet(subject,'stop',[]); % stop if datanet exists for the current trainingStep
                [subject r]=setStepNum(subject,newTsNum,r,sprintf('manually setting to %d',newTsNum),'ratrix');
                %params = Screen('Resolution', getScreenNum(station));
                %parameters = [];
                %parameters.refreshRate = params.hz;
                %parameters.subjectID = getID(subject);
                %subject = setUpOrStopDatanet(subject,'setup',parameters); % start datanet if exists for new trainingStep
            end
            keepWorking=1;
        end
        
        if graduate
            if getNumTrainingSteps(p)>=t+1
                [subject r]=setStepNum(subject,t+1,r,'graduated!','ratrix');
            else
                [subject r]=setStepNum(subject,t,r,'can''t graduate because no more steps defined!','ratrix');
            end
        end
    elseif t==0
        keepWorking=0;
        secsRemainingTilStateFlip=-1;
        newStep=[];
        updateStep=0;
    else
        error('training step is negative')
    end
else
    error('need ratrix and station and rnet objects')
end
