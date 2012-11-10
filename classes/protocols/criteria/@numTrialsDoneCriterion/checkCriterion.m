function [graduate details] = checkCriterion(c,subject,trainingStep,trialRecords)
% this criterion will graduate if we have done a certain number of trials in this trainingStep

if trialRecords(end).trialNumber > c.numTrialsNeeded && length(trialRecords) < c.numTrialsNeeded
    length(trialRecords)
    trialRecords(end).trialNumber
    c.numTrialsNeeded
    error('criterion is longer than the circular buffer set in @station/doTrials (roughly line 76) -- how architect?')
end

recordType='largeData'; %circularBuffer

thisStep=[trialRecords.trainingStepNum]==trialRecords(end).trainingStepNum;
thisStep(1:find(~thisStep,1,'last')) = false;
trialsUsed=trialRecords(thisStep);

details=[];
graduate=0;


if ~isempty(trialsUsed)
    %get the correct vector
    switch recordType
        case 'largeData'
            dates = datenum(cell2mat({trialsUsed.date}'));
            stochastic = [trialsUsed.didStochasticResponse];
            humanResponse = [trialsUsed.didHumanResponse];
            forcedRewards = [trialsUsed.containedForcedRewards]==1;
            
 
            
     
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
            
            ignore = stochastic | humanResponse | forcedRewards; %what about multiple port error?
            
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

    trialsDone = length(dates);
    graduate = trialsDone >= c.numTrialsNeeded;
    
end



if graduate
    playGraduationTone(subject);
end