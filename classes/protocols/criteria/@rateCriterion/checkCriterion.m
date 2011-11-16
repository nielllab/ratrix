function [graduate, details] = checkCriterion(c,subject,trainingStep,trialRecords)

%determine what type trialRecord are
recordType='largeData'; %circularBuffer

thisSession=[trialRecords.sessionNumber]==trialRecords(end).sessionNumber;
thisStep=[trialRecords.trainingStepNum]==trialRecords(end).trainingStepNum;

trialsUsed=trialRecords(thisStep&thisSession);

graduate=0;
if ~isempty(trialsUsed)
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
            
            if isfield(trialsUsed,'phaseRecords')
                % this has to be a cell array b/c phaseRecords aren't always the same across trials
                times = cellfun(@getRelativeTimesPhased,{trialsUsed.phaseRecords},'UniformOutput',false);
            else
                % this has to be a cell array b/c times aren't always there across trials
                times = cellfun(@getTimesNonphased,{trialsUsed.responseDetails},'UniformOutput',false);
            end
            firstLickC=cellfun(@getFirstLick,times,'UniformOutput',false);
            thresh = 0.03; %30 ms
            try
                firstLick=cell2mat(firstLickC);
                tooFast = firstLick < thresh; %edf asks: why are we filtering these out?
            catch e
                %last times can be {{nan}}, eg on stochastic free drinks
                tooFast = cellfun(@(x) iscell(x) || x<thresh,firstLickC);
            end
            %             %ToDo: how can we get rid of this for loop? -pmm
            %             for i=1:numTrialsAnalyzed
            %                 trialInd=i;
            %                 f=fields(trialsUsed(trialInd).responseDetails);
            %                 if any(strcmp(f,'times')) && ~isempty(trialsUsed(trialInd).responseDetails.times)
            %                     firstLick(i)=cell2mat(trialsUsed(trialInd).responseDetails.times(1));
            %                 else
            %                     firstLick(i)=-1;  % this will make it filtered by "tooFast" and not count towards the rate
            %                 end
            %
            %
            %             end
            
            %firstLick = 999* ones(size(trialRecords));

            ignore = stochastic | tooFast | humanResponse | forcedRewards; %what about multiple port error?
            
            %for testing:
            %             if any(size(trialRecords,2)>10)
            %                 sca
            %                 ignore
            %                 ignore
            %             end
            
            try
            dates = dates(~ignore);
            catch
                sca
                keyboard
            end
        case 'circularBuffer'
            error('not written yet');
        otherwise
            error('unknown trialRecords type')
    end
    
    trialsPerMin = sum(dates > (now - c.consecutiveMins/(24*60)))/c.consecutiveMins;
    graduate = trialsPerMin > c.trialsPerMin;
    
end

if graduate
    playGraduationTone(subject);
    
    if (nargout > 1)
        details.date = now;
        details.criteria = c;
        details.graduatedFrom = stepNum;
        details.allowedGraduationTo = stepNum + 1;
        details.trialsPerMin = trialsPerMin;
    end
end


end % end function

function out=getFirstLick(thisTrialTimes)
out=nan;
if ~isempty(thisTrialTimes)
    out=thisTrialTimes(1);
end
end