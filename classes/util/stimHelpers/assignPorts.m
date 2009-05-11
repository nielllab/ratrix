function [targetPorts distractorPorts details]=assignPorts(details,lastTrialRec,responsePorts,TMclass,allowRepeats)

% figure out if this is a correction trial
lastResult=[];
lastCorrect=[];
lastWasCorrection=0;

switch TMclass
    case 'nAFC'
        if ~isempty(lastTrialRec) % if there were previous trials
            try
                lastResult=find(lastTrialRec.result);
            catch
                lastResult=[];
            end
            if isfield(lastTrialRec,'trialDetails') && isfield(lastTrialRec.trialDetails,'correct')
                lastCorrect=lastTrialRec.trialDetails.correct;
            else
                try
                    lastCorrect=lastTrialRec.correct;
                catch
                    lastCorrect=[];
                end
            end

            if any(strcmp(fields(lastTrialRec.stimDetails),'correctionTrial'))
                lastWasCorrection=lastTrialRec.stimDetails.correctionTrial;
            else
                lastWasCorrection=0;
            end

            if length(lastResult)>1
                lastResult=lastResult(1);
            end
        end

        % determine correct port
        if ~isempty(lastCorrect) && ~isempty(lastResult) && ~lastCorrect && length(lastTrialRec.targetPorts)==1 && (lastWasCorrection || rand<details.pctCorrectionTrials)
            details.correctionTrial=1;
            %'correction trial!'
            targetPorts=lastTrialRec.targetPorts; % same ports are correct
        else
            details.correctionTrial=0;
            targetPorts=responsePorts(ceil(rand*length(responsePorts))); %choose random response port to be correct answer
        end
        distractorPorts=setdiff(responsePorts,targetPorts);
        
    case 'freeDrinks'
        if ~isempty(lastTrialRec)
            try
                pNum = find(strcmp('reinforcement',{lastTrialRec.phaseRecords.phaseLabel}));
                rDetails=lastTrialRec.phaseRecords(pNum-1).responseDetails;
                lastResponse=find(rDetails.tries{end});
            catch err
                lastResponse=[];
            end
%             sca
%             keyboard
%             pNum
%             rDetails
        else
            lastResponse=[];
        end

        if length(lastResponse)>1
            lastResponse=lastResponse(1);
        end
        if allowRepeats
            targetPorts=responsePorts;
        else
            targetPorts=setdiff(responsePorts,lastResponse);   
        end
        distractorPorts=[];
        
    case 'autopilot'
        targetPorts=[1];
        distractorPorts=[];
    case 'goNoGo'
                if ~isempty(lastTrialRec) % if there were previous trials
            try
                lastResult=find(lastTrialRec.result);
            catch
                lastResult=[];
            end
            if isfield(lastTrialRec,'trialDetails') && isfield(lastTrialRec.trialDetails,'correct')
                lastCorrect=lastTrialRec.trialDetails.correct;
            else
                try
                    lastCorrect=lastTrialRec.correct;
                catch
                    lastCorrect=[];
                end
            end

            if any(strcmp(fields(lastTrialRec.stimDetails),'correctionTrial'))
                lastWasCorrection=lastTrialRec.stimDetails.correctionTrial;
            else
                lastWasCorrection=0;
            end

            if length(lastResult)>1
                lastResult=lastResult(1);
            end
        end

        % determine correct port
        if ~isempty(lastCorrect) && ~isempty(lastResult) && ~lastCorrect && length(lastTrialRec.targetPorts)==3 && (lastWasCorrection || rand<details.pctCorrectionTrials)
            details.correctionTrial=1;
            %'correction trial!'
            targetPorts=lastTrialRec.targetPorts; % same ports are correct
        else
            details.correctionTrial=0;
            targetPorts=responsePorts; %choose all response port to be correct answer
        end
        distractorPorts=setdiff(responsePorts,targetPorts);
        
    otherwise
        error('unknown TM class');
end

end % end function