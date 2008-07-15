function [stimManager updateSM stimSpecs soundTypes LUT details scaleFactors targetPorts distractorPorts isCorrection] = calcStim(stimManager,trialManagerClass,phases,criteria,frameRate,responsePorts,totalPorts,width,height,trialRecords)
% calcStim() for the phasedStim stimulus manager
% test run with minimal options
% just draw a box or something useless....
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% calculate updateSM, scaleFactor, finalPhase
updateSM=0;
isCorrection=0;
rewardDuration = 100; %maybe have this as a field to phasedStim constructor

%finalPhase = length(phases); %finalPhase is just the location of the last phase in the stimSpec array (not counting progressives at the end)
                                % moved to doTrial


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% calculate details, type, targetPorts, distractorPorts, isCorrection
% only handle the phasedStim trialManager class for now
switch trialManagerClass
    case 'phasednAFC'
        %type='trigger';
        % insert pctCorrectionTrials=.5 into each stimSpec
        details.pctCorrectionTrials=.5; % need to change this to be passed in from trial manager
        
        % handle correction trial and lastResponse logic
        if ~isempty(trialRecords)
            lastResponse=find(trialRecords(end).response);
            lastCorrect=trialRecords(end).correct;
            if any(strcmp(fields(trialRecords(end).stimDetails), 'correctionTrial'))
                lastWasCorrection=trialRecords(end).stimDetails.correctionTrial;
            else
                lastWasCorrection=0;
            end
            if length(lastResponse)>1
                lastResponse=lastResponse(1); %this makes sure that lastResponse points the first field in the last trialRecord?
            end
        else
            % we have no records in trialRecords
            lastResponse=[];
            lastCorrect=[];
            lastWasCorrection=0;
        end
        
        % assign correction trial if: lastCorrect=0 AND (lastWasCorrection
        % or rand < our set percentage of CorrectionTrials)
        if ~isempty(lastCorrect) && ~isempty(lastResponse) && ~lastCorrect && (lastWasCorrection || rand<details.pctCorrectionTrials)
            details.correctionTrial=1;
            'correction trial!'
            % assign targetPorts to be same as previous trial
            targetPorts = trialRecords(end).targetPorts;
            isCorrection=1;
        else
            % not a correction trial
            details.correctionTrial=0;
            targetPorts=responsePorts(ceil(rand*length(responsePorts))); % this just picks a random port from the response ports {1,3}
        end
        
        distractorPorts = setdiff(responsePorts,targetPorts); % the distractor ports are all response ports that are not target ports
        targetPorts
        
        
    otherwise
        error('unsupported trialManager class for now');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% create stimSpecs (most of the customization is here)
% we need to create stimSpecs now - also set lengthOfStims
% loop through each phase
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Some parameters for the visual stimuli
params=[0.5,4, 0,-99,1, 0.001,0.5,0.5]; % some random parameters here
orients=[0:pi/10:pi]; % we need 2 orientations for each phase; total of 10 orientations
stim = zeros(100,100,2); % preallocate stim
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initialization of stimSpecs and soundTypes - also decide how many progressive subphases you have here
numProgressivePhases = 3; % NUMBER OF PROGRESSIVE SUBPHASES
stimSpecs = cell(1, length(phases) + numProgressivePhases); % preallocate stimSpecs to be length of phases
soundTypes = cell(1, length(phases) + numProgressivePhases); % preallocate soundTypes
lengthOfStims = 0; % initialize lengthOfStims
scaleFactors = cell(1,length(phases)+numProgressivePhases); % preallocate scaleFactors
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% for each phase, give it two frames of computeGabors into a stimSpec
for i=1:length(phases)
%for i=1:1
    for j=1:2
        params(4)=orients(2*(i-1)+mod(j,10)+1);
        stim(:,:,j) = computeGabors(params,0.5,100,100,'square','normalizeVertical',1);
        lengthOfStims = lengthOfStims + 1; %increment total length of stims for this phase
 %       figure; imagesc(stim(:,:,j));
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % now create a stimSpec object from the stim for this phase and the associated graduation criterion (passed in from doTrial and stored in the TM)
	% first need to convert from the criterion {'any', nextPhase} to be specified as {[1,2,3], nextPhase} 
	criterion = criteria{i};
	for k=1:2:length(criterion)-1
		stringSet = criterion{k};
		switch stringSet
			case 'any'
				criterion{k} = [1:totalPorts];
			case 'request'
				criterion{k} = setdiff([1:totalPorts], responsePorts);
			case 'response'
				criterion{k} = responsePorts;
			case 'target'
				criterion{k} = targetPorts;
			case 'distractor'
				criterion{k} = distractorPorts;
			case 'none'
				criterion{k} = [];
			otherwise
				error('invalid port set specified');
		end
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % handle each phase differently - construct stimSpec and soundType here
    switch i
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % handle non-progressive cases
        case 1
            % if we have progressive phases, wait phase needs to point to first progressive phase
            if numProgressivePhases > 0
                criterion{2} = length(phases) + 1;
            end
            stimSpecs{i} = stimSpec(stim,criterion,'loop',[],rewardDuration,2000,{0.999, setdiff([1:totalPorts], responsePorts)});
            soundTypes{i} = {responseWait(), requestWait()};
        %    soundTypes{i} = {responseWait()};
        case 3
            stimSpecs{i} = stimSpec(stim,criterion,'toggle','reward',rewardDuration,75,[]);
            soundTypes{i} = {startCorrect()};
        case 4
            stimSpecs{i} = stimSpec(stim,criterion,'toggle',[],rewardDuration,75,[]);
            soundTypes{i} = {startWrong()};
        case 5
            stimSpecs{i} = stimSpec(stim,criterion,'loop',[],rewardDuration,150,[]);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % progressive case
        case 2
            % generate progressive subphases at end of stimSpecs cell array
            storedCr = criterion;
            for progressiveCounter=1:numProgressivePhases
                if progressiveCounter ~= numProgressivePhases
                    criterion = {setdiff([1:totalPorts], responsePorts), progressiveCounter+length(phases)+1}; % this progressive subphase points to the next one
                else
                    criterion = {setdiff([1:totalPorts], responsePorts), i}; % this progressive subphase points to the discrim phase
                end
                stimSpecs{progressiveCounter+length(phases)} = stimSpec(stim,criterion,'loop','reward',25,[],[]); %shorter reward duration, no autorequest
                soundTypes{progressiveCounter+length(phases)} = {requestWait()};
                scaleFactors{length(phases)+progressiveCounter} = getScaleFactor(stimManager); %temporary for now
            end
            % now generate the discrim phase
            stimSpecs{i} = stimSpec(stim,storedCr,'loop','reward',rewardDuration,[],[]); % construct discrim stimSpec
            %soundTypes{i} = {requestWait()};
        otherwise
            error('should not be here');
    end
    
    % temporary definition of scaleFactors (same for each phase)
    scaleFactors{i} = getScaleFactor(stimManager); % get scaleFactors
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end


% set LUT
LUT=getLUT(stimManager);
