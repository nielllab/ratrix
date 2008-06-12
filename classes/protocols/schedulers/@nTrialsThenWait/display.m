function d=display(s)
    d=['nTrialsThenWait (numTrials: ' num2str(s.numTrials) ' hoursBetweenSessions: ' num2str(s.hoursBetweenSessions) ')'];
    disp(d);
    disp(['possibleNumTrials: ' num2str(s.possibleNumTrials)])
    disp(['probOfNumTrials: ' num2str(s.probOfNumTrials)])
    disp(['possibleHoursBetweenSessions: ' num2str(s.possibleHoursBetweenSessions)])
    disp(['probOfHoursBetweenSessions: ' num2str(s.probOfHoursBetweenSessions)])
    disp(['isOn: ' num2str(s.isOn)])
    disp(['lastCompletedSessionEndTime: ' num2str(s.lastCompletedSessionEndTime)])
