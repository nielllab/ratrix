function [r rewardSizeULorMS msPenalty msRewardSound msPenaltySound updateTM] = calcReinforcement(r,trialRecords, subject)
verbose=1;

%default
correct=0;

%make sure the field is there
if all(size(trialRecords)>0)
    if any(strcmp(fields(trialRecords),'correct'))
        correct=[trialRecords.correct];
    else
        warning('**trialRecords does not have the ''correct'' field yet')
    end

    %old code- "thisSessionIsCached" has been removed -pmm 2008/05/02
    % we do not cache the rewardScalar from database at the beginning of every session
    % after 03/26/2008 pmm
    % stop refilling cache if multiple trials in session
    %     if size(trialRecords,2) < 2
    %         r.thisSessionIsCached = 0;
    %     end
else
    warning('**trialRecords has size too small')
end
%correct=rand(1,10)>0.5 debug testing

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

% get rewardScalar from database if needed --- we do not rely on this code
% after 03/26/2008 pmm
% if ~r.thisSessionIsCached
%     sca
%
%     r.scalar = getDatabaseFact(subject, 'rewardScalar');
%     r.msPenalty = getDatabaseFact(subject, 'msPenalty');
%     r.thisSessionIsCached=1;
%     updateTM=1;
% else
%     updateTM=0;
% end
updateTM=0;



rewardSizeULorMS= r.scalar * r.rewardNthCorrect(n);
msPenalty=r.msPenalty;
msRewardSound=rewardSizeULorMS*getFractionOpenTimeSoundIsOn(r.reinforcementManager);
msPenaltySound=r.msPenalty*getFractionPenaltySoundIsOn(r.reinforcementManager);


if verbose
    disp(sprintf('if next trial is correct will reward %d ms, reward level %d',rewardSizeULorMS,n))
end

