function d=display(t)


%    display(t.trialManager)
%    display(t.stimManager)
%    display(t.criterion)
%    display(t.scheduler)

d='';
%following line causes 'can't find path specified' error?
%d=['\t\ttrialManager: ' display(t.trialManager) '\n\t\tstimManager: '
%display(t.stimManager) '\n\t\tcriterion: ' display(t.criterion) '\n\t\tscheduler: ' display(t.scheduler)];

%get rid of empty b/c it might  interfere with sprintf
if isempty(t.sessionRecords)
    dispSessionRecs='empty';
else
    dispSessionRecs=num2str(t.sessionRecords);
end

d=[d '\n\t\tpreviousSchedulerState: ' num2str(t.previousSchedulerState)  '\n\t\ttrialNum: ' num2str(t.trialNum) '\n\t\tsessionRecs: ' dispSessionRecs];

d=sprintf(d);