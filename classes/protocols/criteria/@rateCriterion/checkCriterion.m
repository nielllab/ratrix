function [graduate, details] = checkCriterion(c,subject,trainingStep,trialRecords)

%determine what type trialRecord are
recordType='largeData'; %circularBuffer

thisSession=[trialRecords.sessionNumber]==trialRecords(end).sessionNumber;
thisStep=[trialRecords.trainingStepNum]==trialRecords(end).trainingStepNum;

trialsUsed=trialRecords(thisStep&thisSession);

graduate=0;
if ~isempty(trialRecords)
    %get the correct vector
    switch recordType
        case 'largeData'
            dates = datenum(cell2mat({trialsUsed.date}'));
            stochastic = [trialsUsed.didStochasticResponse];
            humanResponse = [trialsUsed.didHumanResponse];
            forcedRewards = [trialsUsed.containedForcedRewards]==1;

            %firstLick=cell2mat(trialRecords(:).responseDetails.times(1));
            numTrialsAnalyzed=length(trialsUsed);
            firstLick=nan(1,numTrialsAnalyzed);
            
            %ToDo: how can we get rid of this for loop? -pmm
            for i=1:numTrialsAnalyzed
                trialInd=i;
                f=fields(trialsUsed(trialInd).responseDetails);
                if any(strcmp(f,'times'))
                    firstLick(i)=cell2mat(trialsUsed(trialInd).responseDetails.times(1));
                else
                    firstLick(i)=-1;  % this will make it filtered by "tooFast" and not count towards the rate
                end 
                

            end

            %firstLick = 999* ones(size(trialRecords));
            thresh = 0.03; %30 ms
            tooFast = firstLick < thresh;
            ignore = stochastic | tooFast | humanResponse | forcedRewards;

%for testing:
%             if any(size(trialRecords,2)>10)
%                 sca
%                 ignore
%                 ignore
%             end

            dates = dates(~ignore);
        case 'circularBuffer'
            error('not written yet');
        otherwise
            error('unknown trialRecords type')
    end

    % determine the number of trials in the previous minutes
    numMinutes = c.consecutiveMins;
    trialsPerMin = zeros(1, numMinutes);
    for i = 1:numMinutes
        localDateRange = [i i-1] / (24*60); % a date range in minutes
        trialsPerMin(i) =  sum(dates > (now - localDateRange(1)) & dates < (now - localDateRange(2)));
    end

    % if all recent minutes were above the threshold rate
    if(all(trialsPerMin > c.trialsPerMin))
        graduate = 1;
    else
        graduate = 0;
    end


end


%play graduation tone

if graduate
    beep;
    WaitSecs(.2);
    beep;
    WaitSecs(.2);
    beep;
    WaitSecs(1);
    [junk stepNum]=getProtocolAndStep(subject);
    for i=1:stepNum+1
        beep;
        WaitSecs(.4);
    end
    if (nargout > 1)
        details.date = now;
        details.criteria = c;
        details.graduatedFrom = stepNum;
        details.allowedGraduationTo = stepNum + 1;
        details.trialsPerMin = trialsPerMin;
    end
end