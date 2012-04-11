%this should be a static method on trialManagers, but those are only
%available in the new matlab way of doing OOP -- we should eventually
%switch
function [targetPorts distractorPorts details]=assignPorts(details,lastTrialRec,responsePorts,TMclass,allowRepeats)

error('do not call this -- info should have been passed in to calcStim by trial manager')

lastResult = [];
lastCorrect = [];
lastResponse = [];
lastWasCorrection = false;

switch TMclass
    case {'nAFC','oddManOut','ball'}
        if ~isempty(lastTrialRec)
            try % may not have result field
                lastResult = find(lastTrialRec.result);
            end
            try % may not have trialDetails.correct field
                lastCorrect = lastTrialRec.trialDetails.correct;
            catch
                try % may not have correct field
                    lastCorrect = lastTrialRec.correct; %who normally sets this?  i can only find runRealTimeLoop.313 where it is inited to []
                end
            end
            
            try % may not have correctionTrial field
                lastWasCorrection = lastTrialRec.stimDetails.correctionTrial;
            end
            
            if length(lastResult)>1
                lastResult = lastResult(1);
            end
        end
        
        if any(ismember('pctCorrectionTrials',fields(details))) && ...
                ~isempty(lastCorrect) && ...
                ~isempty(lastResult) && ...
                ~lastCorrect && ...
                ((ismember(TMclass,{'nAFC','oddManOut'}) && length(lastTrialRec.targetPorts)==1) || ...
                (strcmp(TMclass,'goNoGo')                && length(lastTrialRec.targetPorts)==3) || ...
                (strcmp(TMclass,'ball')                  && length(lastTrialRec.targetPorts)==0)) && ...
                (lastWasCorrection || rand<details.pctCorrectionTrials)
            %correction trials are a very strange brew for goNoGo... i doubt its what we want...
            
            details.correctionTrial = 1;
            targetPorts = lastTrialRec.targetPorts;
        else
            details.correctionTrial = 0;
            if strcmp(TMclass,'goNoGo')
                targetPorts = responsePorts; %choose all response port to be correct answer
                %pmm:  these apear to be all "go" trials how do we get "no go" trials?
                % i guess the idea of a "trial" is bankrupt in this mode
                % the noGos are all the momement in time of waiting, which
                % could be trials... as long as there is no auditory cue and/or
                % flanker that is correlated with the noGo stimulus
            else
                targetPorts = responsePorts(ceil(rand*length(responsePorts)));
            end
        end
        
        distractorPorts = setdiff(responsePorts,targetPorts);
        
    case 'freeDrinks'
        if ~isempty(lastTrialRec)
            try
                pNum = find(strcmp('reinforcement',{lastTrialRec.phaseRecords.phaseLabel}));
                rDetails = lastTrialRec.phaseRecords(pNum-1).responseDetails;
                lastResponse = find(rDetails.tries{end});
            end
        end
        
        if length(lastResponse)>1
            lastResponse = lastResponse(1);
        end
        if allowRepeats
            targetPorts = responsePorts;
        else
            targetPorts = setdiff(responsePorts,lastResponse);
        end
        distractorPorts = [];
        
    case 'autopilot'
        %pass
        
    otherwise
        error('unknown TM class');
end

if ismember(TMclass,{'autopilot','ball'})
    targetPorts = [];
    distractorPorts = [];
end

if ismember(TMclass,{'ball'})
    sca
    keyboard
    if details.correctionTrial
        details.target = lastTrialRec.target; %.details?
    else
        details.target = sign(randn);
    end
end

end