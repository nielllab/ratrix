function [r rewardSizeULorMS msPenalty msPuff msRewardSound msPenaltySound updateTM] = calcReinforcement(r,trialRecords, subject)
verbose=0;

correct=0;

if ~isempty(trialRecords)
    if any(strcmp(fields(trialRecords),'correct'))
        correct=[trialRecords.correct];
    else
        warning('**trialRecords does not have the ''correct'' field yet')
    end
else
    warning('**trialRecords has size too small')
end

%determine how many were correct in row before this
if correct(end)==0
    n=1;
elseif correct(end)==1
    sameInRow=diff([1 find(diff(correct)) length(correct)]);
    n=sameInRow(end)+1;
else
    warning('unknown correct val, setting to reward state 1,')
    n=1;
end

%if many correct in a row, use last entry in rewardNthCorrect
if n> size(r.rewardNthCorrect,2)
    n=size(r.rewardNthCorrect,2);
end

updateTM=0;

[rewardSizeULorMS msPenalty msPuff msRewardSound msPenaltySound] = calcCommonValues(r,r.rewardNthCorrect(n));

if verbose
    disp(sprintf('if next trial is correct will reward %d ms, reward level %d',rewardSizeULorMS,n))
end

