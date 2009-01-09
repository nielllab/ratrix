

%%
%init this test
clear all
trialRecords=[];
details.a=9;
details.b=9;
%%
%basic setup
stimulus.blocking.type='nTrials'
stimulus.blocking.ntrials=3; %100
stimulus.blocking.parameters={'a','c','h'};
stimulus.blocking.values=[1 2 3 4;
                          1 0 1 0];

%stimulus.blocking.type='daily'
%stimulus.blocking.anchorDay=floor(now-5); %100

if ~isempty(stimulus.blocking)
    blocking=stimulus.blocking;
    %details=setBlockedDetails(details,stimulus.blocking,trialRecords)
    %function details=setBlockedDetails(details,blocking,trialRecords)
    %error check
    
    numBlocks=size(stimulus.blocking.values,2);
    numParameters=size(blocking.values,1);
    if length(blocking.parameters)~=numParameters
        numParameters=numParameters
        size(blocking.values)
        error('wrong number of parameters, value should be M x N == numParams x numBlocks')
    end
        
    isThere=ismember(blocking.parameters,fields(details));
    if ~all(isThere)
        stimulus.blocking.parameters{~isThere}
        warning(sprintf('found a request for "%s"', [stimulus.blocking.parameters{~isThere}] ))
        error('it is expected that all details have previously been intialized and defined in calcStim, and the blocking method is merely overwriting the randomly selected values... no new values can be set! double check your assumptions')
    end
    
    
    if size(trialRecords,2)>0
        thisTrial=trialRecords(end).trialNum+1
    else
        thisTrial=1;
    end

    
    switch stimulus.blocking.type
        case 'daily'
            details.blockID=rem(ceil(now-blocking.anchorDay),numBlocks)
        case 'nTrials'  
            details.blockID=rem(floor(thisTrial/blocking.ntrials),numBlocks)     
        otherwise
            stimulus.blocking.type
            error('bad blocking type')
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
        details.(stimulus.blocking.parameters{i})=stimulus.blocking.values(i,details.blockID)
    end
end

trialRecords(thisTrial).stimDetails=details
trialRecords(thisTrial).trialNum=thisTrial
details