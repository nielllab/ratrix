clear all

[f p ] =uigetfile('*.mat','trial record');
load(fullfile(p,f))

for tr = 1:length(trialRecords)-1
    xpos(tr) = trialRecords(tr).stimDetails.subDetails.xPosPcts;
    theta(tr) = trialRecords(tr).stimDetails.subDetails.orientations;
    correction(tr) = trialRecords(tr).stimDetails.subDetails.correctionTrial;

    targ(tr) = sign(trialRecords(tr).stimDetails.subDetails.target);
   if ~isempty(trialRecords(tr).trialDetails.correct)
       correct(tr) = trialRecords(tr).trialDetails.correct;
   end
end

display(sprintf('performed %d trials in %0.1f mins',length(trialRecords), 60*24*(datenum(trialRecords(end).date) - datenum(trialRecords(1).date))))

display(sprintf('correct = %0.2f bias = %0.2f',sum(correct)/length(correct),sum(targ)/length(targ)))

x = unique(xpos);
for i = 1:length(x)
    usetrials = find(xpos==x(i));
    display(sprintf('position %0.2f = %0.2f correct',x(i),sum(correct(usetrials))/length(usetrials)))
end

ori = unique(theta);
for i = 1:length(ori)
    usetrials = find(theta == ori(i));
   display( sprintf('theta %0.2f = %0.2f correct',ori(i),sum(correct(usetrials))/length(usetrials)))
end