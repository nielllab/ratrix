function analysis(sm,detailRecords,subjectID)
if all(detailRecords.pctCorrectionTrials==.5)
    %pass
else
    unique(detailRecords.pctCorrectionTrials)
    warning('standard hemifieldFlicker config violated')
end

options=cellfun(@union,detailRecords.targetPorts,detailRecords.distractorPorts,'UniformOutput',false);

goods=detailRecords.isCorrection==0 ...
    & cellfun(@ismember,num2cell(detailRecords.response),options) ...
    & ~detailRecords.containedManualPokes ...
    & ~detailRecords.didHumanResponse ...
    & ~detailRecords.containedForcedRewards ...
    & ~detailRecords.didStochasticResponse;

contrasts=detailRecords.contrast;
xPosPcts=detailRecords.xPosPct;
if all(contrasts(:)>=0) && all(xPosPcts(:)>=0)
    contrasts(isnan(contrasts))=-1;
    xPosPcts(isnan(xPosPcts))=-1;

    contrasts=sort(contrasts);
    xPosPcts=sort(xPosPcts);

    %any time flickers change location or contrast, increment session number.  also when trial is more than an hour since previous trial.
    sessionNum=cumsum([1    sign(    double((24*diff(detailRecords.date))>1)    +   sum(abs(diff(contrasts')'))   +  sum(abs(diff(xPosPcts')'))   )   ]);
else
    error('found contrasts or xPosPcts less than zero')
end

alpha=.05;

data.perf.phat=[];
data.perf.pci=[];
data.bias.phat=[];
data.bias.pci=[];
sessionContrasts={};
sessionXPosPcts={};
sessions=[];

trialsIncluded=0;
minTrials=25;
for i=1:max(sessionNum)
    trials=sessionNum==i & goods;

    if sum(trials)>=minTrials
        trialsIncluded=trialsIncluded+sum(trials);

        sessionContrasts{end+1}=unique(contrasts(:,trials)','rows');
        sessionXPosPcts{end+1}=unique(xPosPcts(:,trials)','rows');
        if size(sessionContrasts{end},1)~=1 || size(sessionXPosPcts{end},1)~=1
            error('found multiple contrasts or positions within a session')
        end
        sessionContrasts{end}=sessionContrasts{end}(sessionContrasts{end}~=-1);
        sessionXPosPcts{end}=sessionXPosPcts{end}(sessionXPosPcts{end}~=-1);
        
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

figName=sprintf('%s: hemifieldFlicker performance and bias',subjectID);
figure('Name',figName)
subplot(3,1,1)
c={'r' 'k'};
makePerfBiasPlot(sessions,data,c);
title(figName);

subplot(3,1,2)
for i=1:length(sessions)
plot(sessions(i),sessionContrasts{i},'k*','MarkerSize',10)
hold on
end
xlim([1 max(sessions)])
title('contrasts')

subplot(3,1,2)
for i=1:length(sessions)
plot(sessions(i),sessionXPosPcts{i},'k*','MarkerSize',10)
hold on
end
xlim([1 max(sessions)])
title('x positions')
xlabel('session')


pth='C:\Documents and Settings\rlab\Desktop\detailedRecords';
saveas(gcf,fullfile(pth,[subjectID '_hemifieldFlicker']),'png');