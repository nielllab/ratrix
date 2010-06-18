
function out=getDiffFromFirstRequestToNextResponse(times,tries,requestPorts,responsePorts,phaseLabelPerLick)
out=nan;
first=find(cell2mat(cellfun(@(x) ~any(isnan(x))&&any(x(requestPorts)==1),tries,'UniformOutput',false)),1,'first');
%last=find(cell2mat(cellfun(@(x) ~any(isnan(x))&&any(x(responsePorts)==1),tries,'UniformOutput',false)),1,'last');
responseLickIDs=find(cell2mat(cellfun(@(x) ~any(isnan(x))&&any(x(responsePorts)==1),tries,'UniformOutput',false)));
responseLickIDs(responseLickIDs<=first)=[];
next=min(responseLickIDs);
if ~isempty(first) && ~isempty(next)
    out=times(next)-times(first);
    
    %confirm (note that confirmation only happens when licks are there... if not there RT will be nanned, like on mannual kill's)
    if strcmp(phaseLabelPerLick(first),'waiting for request') & strcmp(phaseLabelPerLick(next),'discrim')
        %pass
    else
        warning('first request must come from phase labeled ''waiting for request'' and next response must be in ''discrim'' phase ')
        keyboard
        
        %NOTE: it is important not to ERROR here, but to keyboard so a user
        %finds it, else, the single error on one trial will result in
        %nan'ing the whole session
        
        %old code used to compare to the "last" response lick, which which
        %could be during reinforcement, and that would be wrong, now its fixed
        %2010/6/16 -pmm
    end
end



