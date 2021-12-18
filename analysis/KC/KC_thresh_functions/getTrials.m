function [idxTrials] = getTrials(conAndDurOrderedByTrialMeetCriteria,c,d,uniqueContrasts,uniqueDurations,behStateTrials) % large vs small pupil trial indicies
% Gets trial indicies for trials with that set of stim params & pupil state

     % Index trials by param & beh state

     % these trials might change each time thru the loop for 1 session
     clear trials
     trials = conAndDurOrderedByTrialMeetCriteria(1,:) == uniqueContrasts(c) & conAndDurOrderedByTrialMeetCriteria(2,:) == uniqueDurations(d);
     clear idxTrials
     idxTrials = find(trials == 1);

     % these trials don't change thru the loop for 1 session
     idxTrials = intersect(idxTrials,behStateTrials);

end

