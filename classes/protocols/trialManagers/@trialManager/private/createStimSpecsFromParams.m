function [stimSpecs startingStimSpecInd] = createStimSpecsFromParams(trialManager,preRequestStim,preResponseStim,discrimStim,...
	targetPorts,distractorPorts,requestPorts,interTrialLuminance,hz,indexPulses)
%	INPUTS: 
%		trialManager - the trialManager object (contains the delayManager and responseWindow params)
%		preRequestStim - a struct containing params for the preOnset phase
%		preResponseStim - a struct containing params for the preResponse phase
%		discrimStim - a struct containing params for the discrim phase
%		targetPorts - the target ports for this trial
%		distractorPorts - the distractor ports for this trial
%		requestPorts - the request ports for this trial
%		interTrialLuminance - the intertrial luminance for this trial (used for the 'final' phase, so we hold the itl during intertrial period)
%		hz - the refresh rate of the current trial
%		indexPulses - something to do w/ indexPulses, apparently only during discrim phases
%	OUTPUTS: 
%		stimSpecs, startingStimSpecInd

% there are two ways to have no pre-request/pre-response phase:
%	1) have calcstim return empty preRequestStim/preResponseStim structs to pass to this function!
%	2) the trialManager's delayManager/responseWindow params are set so that the responseWindow starts at 0
%		- NOTE that this cannot affect the preOnset phase (if you dont want a preOnset, you have to pass an empty out of calcstim)

% should the stimSpecs we return be dependent on the trialManager class? - i think so...because autopilot does not have reinforcement, but for now nAFC/freeDrinks are the same...

% check for empty preRequestStim/preResponseStim and compare to values in trialManager.delayManager/responseWindow
% if not compatible, ERROR
% nAFC should not be allowed to have an empty preRequestStim (but freeDrinks can)
if isempty(preRequestStim) && strcmp(class(trialManager),'nAFC')
	error('nAFC cannot have an empty preRequestStim'); % i suppose we could default to the ITL here, but really shouldnt
end
responseWindowMs=getResponseWindowMs(trialManager);
if isempty(preResponseStim) && responseWindowMs(1)~=0
	error('cannot have nonzero start of responseWindow with no preResponseStim');
end

% get an optional autorequest from the delayManager
dm = getDelayManager(trialManager);
if ~isempty(dm)
	framesUntilOnset=floor(calcAutoRequest(dm)*hz/1000); % autorequest is in ms, convert to frames
else
	framesUntilOnset=[]; % only if request port is triggered
end
% get responseWindow
responseWindow=floor(responseWindowMs*hz/1000); % can you floor inf?

% now generate our stimSpecs
startingStimSpecInd=1;
i=1;
addedPreResponsePhase=0;
switch class(trialManager)
	case {'nAFC','freeDrinks','oddManOut','goNoGo','cuedGoNoGo'}
		% we need to figure out when the reinforcement phase is (in case we want to punish responses, we need to know which phase to transition to)
		if ~isempty(preResponseStim) && responseWindow(1)~=0
			addedPreResponsePhase=addedPreResponsePhase+1;
		end
		% optional preOnset phase
		if ~isempty(preRequestStim) &&  ismember(class(trialManager),{'nAFC','goNoGo','cuedGoNoGo'}) % only some classes have the pre-request phase if no delayManager in 'nAFC' class
			if preRequestStim.punishResponses
				criterion={[],i+1,requestPorts,i+1,[targetPorts distractorPorts],i+2+addedPhases};
			else
				criterion={[],i+1,requestPorts,i+1};
			end
			stimSpecs{i} = stimSpec(preRequestStim.stimulus,criterion,preRequestStim.stimType,preRequestStim.startFrame,...
			framesUntilOnset,preRequestStim.autoTrigger,preRequestStim.scaleFactor,0,hz,'pre-request','pre-request',preRequestStim.punishResponses,false);
			i=i+1;
            if isempty(requestPorts) && isempty(framesUntilOnset)
                error('cannot have empty requestPorts with no auto-request!');
            end
		end
		% optional preResponse phase
		if ~isempty(preResponseStim) && responseWindow(1)~=0
			if preResponseStim.punishResponses
				criterion={[],i+1,[targetPorts distractorPorts],i+2};
			else
				criterion={[],i+1};
			end
			stimSpecs{i} = stimSpec(preResponseStim.stimulus,criterion,preResponseStim.stimType,preResponseStim.startFrame,...
			responseWindow(1),preResponseStim.autoTrigger,preResponseStim.scaleFactor,0,hz,'pre-response','pre-response',preResponseStim.punishResponses,false);
			i=i+1;
		end
		% required discrim phase
		criterion={[],i+1,[targetPorts distractorPorts],i+1};
		if isinf(responseWindow(2))
			framesUntilTimeout=[];
		else
			framesUntilTimeout=responseWindow(2);
        end
        if isfield(discrimStim,'framesUntilTimeout') && ~isempty(discrimStim.framesUntilTimeout)
            if ~isempty(framesUntilTimeout)
                error('had a finite responseWindow but also defined framesUntilTimeout in discrimStim - CANNOT USE BOTH!');
            else
                framesUntilTimeout=discrimStim.framesUntilTimeout;
            end
        end
        
		stimSpecs{i} = stimSpec(discrimStim.stimulus,criterion,discrimStim.stimType,discrimStim.startFrame,...
			framesUntilTimeout,discrimStim.autoTrigger,discrimStim.scaleFactor,0,hz,'discrim','discrim',false,true,indexPulses); % do not punish responses here
        
        i=i+1;
		% required reinforcement phase
		criterion={[],i+1};
		stimSpecs{i} = stimSpec([],criterion,'cache',0,[],[],0,0,hz,'reinforced','reinforcement',false,false); % do not punish responses here
		i=i+1;
		% required final ITL phase
		criterion={[],i+1};
		stimSpecs{i} = stimSpec(interTrialLuminance,criterion,'cache',0,1,[],0,1,hz,'itl','intertrial luminance',false,false); % do not punish responses here
		i=i+1;
	case 'autopilot'
		% do autopilot stuff..
        % required discrim phase
		criterion={[],i+1,[targetPorts distractorPorts],i+1};
		if isinf(responseWindow(2))
			framesUntilTimeout=[];
		else
			framesUntilTimeout=responseWindow(2);
        end
        if isfield(discrimStim,'framesUntilTimeout') && ~isempty(discrimStim.framesUntilTimeout)
            if ~isempty(framesUntilTimeout)
                error('had a finite responseWindow but also defined framesUntilTimeout in discrimStim - CANNOT USE BOTH!');
            else
                framesUntilTimeout=discrimStim.framesUntilTimeout;
            end
        end
		stimSpecs{i} = stimSpec(discrimStim.stimulus,criterion,discrimStim.stimType,discrimStim.startFrame,...
			framesUntilTimeout,discrimStim.autoTrigger,discrimStim.scaleFactor,0,hz,'discrim','discrim',false,true,indexPulses); % do not punish responses here
		i=i+1;
        % required final ITL phase
		criterion={[],i+1};
		stimSpecs{i} = stimSpec(interTrialLuminance,criterion,'cache',0,1,[],0,1,hz,'itl','intertrial luminance',false,false); % do not punish responses here
		i=i+1;
		
	otherwise
		class(trialManager)
		error('unsupported trial manager class');
end


end % end function
		
