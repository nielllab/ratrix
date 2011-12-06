function [out type]=getBasicFacts(r,displayOn)
%returns a structure with the step and current reward scalar and current
%penalty for all rats

if ~exist('displayOn','var')
    displayOn=0;
end

type={'subj', 'step', 'reward','scalar', 'penalty'};
subjectIDs=getSubjectIDs(r);
count=0;

for i=1:size(subjectIDs,2)
    count=count+1;
    s=getSubjectFromID(r,subjectIDs(i));
    [p step ] =getProtocolAndStep(s);
    out{count,1}=subjectIDs{i};
    out{count,2}=step;


    if ~isempty(p)

        ts=getTrainingStep(p,step);
        tm=getTrialManager(ts);
        sm=getStimManager(ts);
        if isa(tm,'trialManager')
            rm=getReinforcementManager(tm);
        elseif isa(tm,'struct')
            rm=getReinforcementManager(tm.trialManager);
        else
            error('bad tm')
        end
            
        %calculate the reward the rat would get after 100 corrects
        [trialRecords(1:100).correct]=deal(true);
%         [trialRecords(1:100).stimManagerClass]=deal(class(sm));
%         %asymetric needs too much history for now.
        if ~isa(rm,'cuedReinforcement') && ~isa(rm,'asymetricReinforcement') % cued breaks b/c it requires calcstim's details
            [rm rewardSizeULorMS requestRewardSizeULorMS msPenalty] = calcReinforcement(rm,trialRecords, s);
        else
            rewardSizeULorMS=nan;
            msPenalty=nan;
        end
        stimName=class(sm);
        rewardName=class(rm);
        protocolName=getName(p);
        ln=11;
        if length(stimName)>ln
            stimName=stimName(1:ln);
        end
        if length(rewardName)>ln
            rewardName=rewardName(1:ln);
        end
        if length(protocolName)>ln
            if strcmp(protocolName(1:7),'version')
                protocolName=[protocolName(60:68) protocolName(8:11)];
            else
            protocolName=protocolName(1:ln);
            end
        end

        out{count,3}=rewardSizeULorMS;
        out{count,4}=getScalar(rm);
        out{count,5}=msPenalty;
        out{count,6}=stimName;
        out{count,7}=rewardName;
        out{count,8}=protocolName;
        try
            if isa(sm,'stimManager')
                out{count,9}=getCurrentShapedValue(sm);
                out{count,10}=getPercentCorrectionTrials(sm); %all SM need to report this if they have it!
            else
                out{count,9}=nan;
                out{count,10}=nan;
            end
        catch ex
            warning('probably the stim manager does not have that method')
            getReport(ex)
                out{count,9}=nan;
                out{count,10}=nan;
        end


    else
        out{count,3}=nan;
        out{count,4}=nan;
        out{count,5}=nan;
        out{count,6}=nan;
        out{count,7}=nan;
        out{count,8}=nan;
        out{count,9}=nan;
        out{count,10}=nan;
    end


end

subs=out(:,1);
[a order]=unique(subs);
out=out(order,:);

if displayOn
    disp(type)
    disp(out)
end

