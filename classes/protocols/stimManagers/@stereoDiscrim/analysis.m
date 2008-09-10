function analysis(sm,detailRecords,subjectID)
if all(detailRecords.pctCorrectionTrials==.5)
    %pass
else
    unique(detailRecords.pctCorrectionTrials)
    warning('standard stereoDiscrim config violated')
end

options=cellfun(@union,detailRecords.targetPorts,detailRecords.distractorPorts,'UniformOutput',false);

goods=detailRecords.isCorrection==0 ...
    & cellfun(@ismember,num2cell(detailRecords.response),options) ...
    & ~detailRecords.containedManualPokes ...
    & ~detailRecords.didHumanResponse ...
    & ~detailRecords.containedForcedRewards ...
    & ~detailRecords.didStochasticResponse;

amps=sort([detailRecords.leftAmplitude;rightAmplitude]);

    %any time amplitdues change, increment session number.  also when trial is more than an hour since previous trial.
    sessionNum=cumsum([1    sign(    double((24*diff(detailRecords.date))>1)    +   sum(abs(diff(amps')'))    )   ]);


alpha=.05;

data.perf.phat=[];
data.perf.pci=[];
data.bias.phat=[];
data.bias.pci=[];
amplitudes=[];
sessions=[];

trialsIncluded=0;
minTrials=25;
for i=1:max(sessionNum)
    trials=sessionNum==i & goods;

    if sum(trials)>=minTrials
        trialsIncluded=trialsIncluded+sum(trials);

        a=unique(amps(:,trials)','rows');
        if size(a,1)~=1
            error('found multiple amplitudes within a session')
        end
        amplitdues(end+1,:)=a;

        total=sum(trials);
        correct=sum(trials & detailRecords.correct);
        responseRight=sum(trials & detailRecords.response==3);
        [phat pci]=binofit([correct responseRight],[total total],alpha);

        if all(pci(:,1)<pci(:,2))

            ind=1;
            data.perf.phat(end+1)=phat(ind);
            data.perf.pci(end+1,:)=pci(ind,:);

            ind=2;
            data.bias.phat(end+1)=phat(ind);
            data.bias.pci(end+1,:)=pci(ind,:);

            sessions(end+1)=i;
        else
            error('pci''s came back descending')
        end
    else
        fprintf('skipping a %d session\n',sum(trials))
    end
end
fprintf('included %d clumped of %d good trials (%g%%)\n',trialsIncluded,sum(goods),round(100*trialsIncluded/sum(goods)));

figName=sprintf('%s: stereoDiscrim performance and bias',subjectID);
figure('Name',figName)
subplot(2,1,1)
c={'r' 'k'};
makePerfBiasPlot(sessions,data,c);
title(figName);

subplot(2,1,2)
for i=1:length(sessions)
plot(sessions(i),amplitudes(i,:),'k*','MarkerSize',10)
hold on
end
xlim([1 max(sessions)])
title('amplitudes')
xlabel('session')


pth='C:\Documents and Settings\rlab\Desktop\detailedRecords';
saveas(gcf,fullfile(pth,[subjectID '_stereoDiscrim']),'png');