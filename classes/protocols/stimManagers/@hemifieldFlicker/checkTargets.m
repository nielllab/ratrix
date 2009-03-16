function checkTargets(sm,xPosPcts,contrasts,targetPorts,distractorPorts,numPorts)

if size(xPosPcts,1)==size(contrasts,1)
    if size(contrasts,1)>1
        [junk inds]=sort(xPosPcts);
        sz=size(contrasts);
        inds=sub2ind(sz,inds,repmat(1:sz(2),sz(1),1));
        temp=contrasts(inds);
        [junk inds]=max(temp);
        [answers cols]=find(repmat(max(temp),size(temp,1),1)==temp);
        targetIsRight=logical(answers-1);
        if ~all(cols'==1:size(temp,2))
            error('nonunique answer')
        end
    else
        if ~any(xPosPcts==.5)
            targetIsRight=xPosPcts>.5;
        else
            error('xPosPct at .5')
        end
    end
else
    size(xPosPcts,1)
    size(contrasts,1)
    error('dims of contrasts and xPosPcts don''t match')
end
% checkNafcTargets(targetIsRight,targetPorts,distractorPorts,numPorts);
% 3/15/09 - fli removed this check because found trialRecords with freeDrinks-like target/distractor but nAFC tm
% see behavior/pmmTrialRecords/subjects/225/trialRecords_6811-7091_20080502T113147-20080502T130836.mat
% trialRecords(1)