function [details setValues]=setBlockedDetails(stimulus,trialRecords,details)

if ~isempty(stimulus.blocking)
    blocking=stimulus.blocking;
    
    %error check
    numBlocks=size(stimulus.blocking.sweptValues,2);
    numParameters=size(blocking.sweptValues,1);
    if length(blocking.sweptParameters)~=numParameters
        numParameters=numParameters
        size(blocking.sweptValues)
        error('wrong number of parameters, value should be M x N == numParams x numBlocks')
    end
    
    isThere=ismember(blocking.sweptParameters,[fields(stimulus); {'targetContrast','targetOrientations','flankerOn', 'flankerOff'}']); 
    if ~all(isThere)
        stimulus.blocking.sweptParameters{~isThere}
        warning(sprintf('found a request for "%s"', [stimulus.blocking.sweptParameters{~isThere}] ))
        error('it is expected that all blocked parameters are either fields on the stimulus manager or specially approved')
    end
    
    if any(strcmp(blocking.sweptParameters,'fpaRelativeTargetOrientation')) || any(strcmp(blocking.sweptParameters,'flankerOffset')) 
        error('have not done a visual confirmation of blocked flankerOffset or fpa')
        error('relative orientation has not been tested and confrimed yet..make sure that block force and orientation don''t collide')
    end
    
    if size(trialRecords,2)>0
        thisTrial=trialRecords(end).trialNumber+1
    else
        thisTrial=1;
    end
    
    
    switch stimulus.blocking.blockingMethod
        case 'daily'
            blockID=rem(ceil(now-blocking.anchorDay),numBlocks)
        case 'nTrials'
            blockID=rem(floor(thisTrial/blocking.nTrials),numBlocks)
        otherwise
            stimulus.blocking.blockingMethod
            error('bad blocking method')
    end
    
    if blockID==0
        %remainder of 0 counts as last blockID
        blockID=numBlocks;
    end
    
    % figure out if the step is new
    if thisTrial>2
        temp=diff([trialRecords.trainingStepNum]);
        newStep=temp(end)~=0;
    else
        newStep=false; % don't consider it a new step for the first 2 trials, avoid resent on second trial
    end
    
    % figure out if the parameters are new
    if  thisTrial>1
        if isfield(trialRecords(end),'stimDetails') && isfield(trialRecords(end).stimDetails,'blockPermutation')
            newNumberOfParameters=size(stimulus.blocking.sweptValues,2)~=size(trialRecords(end).stimDetails.blockPermutation,2);
        else
            newNumberOfParameters=true; % treat: from no params to some params --> new params
        end
    else
        newNumberOfParameters=true; % treat: from no params to some params --> new params
    end
    
    
    if thisTrial==1 || ~ismember('blockID',fields(trialRecords(end).stimDetails)) || newStep || ...  % if first trial, or first trial this step
            newNumberOfParameters || ... if number of parameters change
            (~stimulus.blocking.shuffleOrderEachBlock && trialRecords(end).stimDetails.blockID~=blockID) ||... % if changes in blockID which is unpermuted
            (stimulus.blocking.shuffleOrderEachBlock && trialRecords(end).stimDetails.blockID~=trialRecords(end).stimDetails.blockPermutation(blockID))       % if changes in blockID which *IS* permuted
        %start or reset
        details.trialThisBlock=1;
    else
        %advance
        details.trialThisBlock=trialRecords(end).stimDetails.trialThisBlock+1;
    end
    
    %get the blockID into details
    if stimulus.blocking.shuffleOrderEachBlock
        % if the first trial of the first block
        if (details.trialThisBlock==1 && blockID==1) || newStep || newNumberOfParameters ||(~ismember('stimDetails',fields(trialRecords)) ||  ~ismember('blockPermutation',fields(trialRecords(end).stimDetails)))
            details.blockPermutation=randperm(size(stimulus.blocking.sweptValues,2)); %reset
        else
            details.blockPermutation=trialRecords(end).stimDetails.blockPermutation; %keep it till reset block
        end
        details.blockID=details.blockPermutation(blockID);
    else
        details.blockID=blockID;
    end
    
    %set values for this block
    for i=1:numParameters
        %don't set directly in details
        %details.(stimulus.blocking.sweptParameters{i})=stimulus.blocking.sweptValues(i,details.blockID)
        
        %rather trace out the value so selectStimulusParameters can find the ID
        setValues(i)=stimulus.blocking.sweptValues(i,details.blockID);
    end
end

