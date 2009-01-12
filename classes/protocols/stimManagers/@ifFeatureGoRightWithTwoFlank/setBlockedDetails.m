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
    

    isThere=ismember(blocking.sweptParameters,[fields(stimulus); {'targetContrast','targetOrientations'}']);
    if ~all(isThere)
        stimulus.blocking.sweptParameters{~isThere}
        warning(sprintf('found a request for "%s"', [stimulus.blocking.sweptParameters{~isThere}] ))
        error('it is expected that all blocked parameters are either fields on the stimulus manager or specially approved')
    end
    
    if size(trialRecords,2)>0
        thisTrial=trialRecords(end).trialNum+1
    else
        thisTrial=1;
    end

    
    switch stimulus.blocking.blockingMethod
        case 'daily'
            details.blockID=rem(ceil(now-blocking.anchorDay),numBlocks)
        case 'nTrials'  
            details.blockID=rem(floor(thisTrial/blocking.nTrials),numBlocks)     
        otherwise
            stimulus.blocking.blockingMethod
            error('bad blocking method')
    end

    if details.blockID==0
        %remainder of 0 counts as last blockID
        details.blockID=numBlocks;
    end
    
    if thisTrial==1 || trialRecords(end).stimDetails.blockID~=details.blockID;
        %start or reset
        details.trialThisBlock=1;
    else
        %advance
        details.trialThisBlock=trialRecords(end).stimDetails.trialThisBlock+1;
    end
    
    %set values for this block
    for i=1:numParameters
        %don't set directly in details
        %details.(stimulus.blocking.sweptParameters{i})=stimulus.blocking.sweptValues(i,details.blockID) 
        
        %rather trace out the value so selectStimulusParameters can find the ID
        setValues(i)=stimulus.blocking.sweptValues(i,details.blockID);             
    end
end

