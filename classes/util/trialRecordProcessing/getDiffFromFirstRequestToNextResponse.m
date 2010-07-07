
function out=getDiffFromFirstRequestToNextResponse(times,tries,requestPorts,responsePorts,phaseLabelPerLick)
out=nan;
%old code used to compare to the "last" response lick, which which
%could be during reinforcement, and that would be wrong, now its fixed
%non phased records still use the last response, cuz they only log discrim
%phase
%2010/6/16 -pmm
%last=find(cell2mat(cellfun(@(x) ~any(isnan(x))&&any(x(responsePorts)==1),tries,'UniformOutput',false)),1,'last');

debuggerOn=false;  % this is useful for people would want to inspect types of nans, could become an optional arg if used
%nan's are caused on a smallish fraction of the trials


try
    
    %the first request lick:
    first=find(cell2mat(cellfun(@(x) ~any(isnan(x))&&any(x(requestPorts)==1)&&~any(x(responsePorts)==1),tries,'UniformOutput',false)),1,'first');
    if isempty(first)
        if debuggerOn
            out=-1;
        else
            out=nan;
        end
        return
    end
    %find all response licks:
    responseLickIDs=find(cell2mat(cellfun(@(x) ~any(isnan(x))&&any(x(responsePorts)==1)&&~any(x(requestPorts)==1),tries,'UniformOutput',false)));
    if isempty(responseLickIDs)
        if debuggerOn
            out=-2;
        else
            out=nan;
        end
        return
    end
    %find response licks that come AFTER the request:
    responseLickIDs(responseLickIDs<=first)=[];
    %choose the first of those responses:
    next=min(responseLickIDs);
    if ~isempty(first) && ~isempty(next)
        %the difference in time between the appropriate request lick aand
        %the response lick:
        out=times(next)-times(first);
        
        %confirm (note that confirmation only happens when licks are there... if not there RT will be nanned)
        if strcmp(phaseLabelPerLick(first),'waiting for request') & strcmp(phaseLabelPerLick(next),'discrim')
            %pass
        else
            %this can happen if there are no lick in discrim phase.  example: rat 231 trial 155706
            %also it can happen if there are any logged human responses.
            %in 300,000 trials of data for rat 231, 3 got here.
            %now our policy is to nan them.
            % anyone who wanted top wanted to inspect the causes of these
            % rare events, might want to do something like  return Inf.
            % but thats unintuitive to most users, so we return nans.
            % btw, none of these trials are deemd vaild trials by getGoods.
            % (result=-1)
            
            if debuggerOn
                out=-3; %temp to know frequency and inspect why
            else
                out=nan;
            end
            warning('first request must come from phase labeled ''waiting for request'' and next response must be in ''discrim'' phase ')
            
        end
    end
catch ex
    warning('this should never happen')
    keyboard
    %NOTE: it is important not to ERROR here, but to keyboard so a user
    %finds it, else, the single error on one trial will result in
    %nan'ing the whole session
end


