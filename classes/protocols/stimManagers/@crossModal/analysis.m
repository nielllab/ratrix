function analysis(sm,detailRecords,subjectID)
if all(detailRecords.HFdetailsPctCorrectionTrials==.5) && all(detailRecords.SDdetailsPctCorrectionTrials==.5) && all(strcmp(detailRecords.modalitySwitchMethod,'Random')) && all(strcmp(detailRecords.modalitySwitchType,'ByNumberOfHoursRun'))
    %pass
else
    unique(detailRecords.HFdetailsPctCorrectionTrials) 
    unique(detailRecords.SDdetailsPctCorrectionTrials) 
    unique(detailRecords.modalitySwitchMethod)
    unique(detailRecords.modalitySwitchType)
    warning('standard crossModal config violated')
end

options=cellfun(@union,detailRecords.targetPorts,detailRecords.distractorPorts,'UniformOutput',false);

goods=detailRecords.isCorrection==0 ...
    & cellfun(@ismember,num2cell(detailRecords.response),options) ...
    & ~detailRecords.containedManualPokes ...
    & ~detailRecords.didHumanResponse ...
    & ~detailRecords.containedForcedRewards ...
    & ~detailRecords.didStochasticResponse;

%any time isBlocking or currentModality changes state, increment session number.  also when trial is more than an hour since previous trial.
sessionNum=cumsum([1    sign(    double((24*diff(detailRecords.date))>1)    +   abs(diff(detailRecords.isBlocking))   +   abs(diff(detailRecords.currentModality))   )   ]);

agrees=detailRecords.HFtargetPorts==detailRecords.SDtargetPorts;
conflicts=detailRecords.HFtargetPorts~=detailRecords.SDtargetPorts;
if any(agrees & conflicts) || any(~agrees & ~conflicts)
    error('can''t agree and conflict or do neither')
end

alpha=.05;

visual.agree.perf.phat=[];
visual.agree.perf.pci=[];
visual.agree.bias.phat=[];
visual.agree.bias.pci=[];
visual.conflict.perf.phat=[];
visual.conflict.perf.pci=[];
visual.conflict.bias.phat=[];
visual.conflict.bias.pci=[];
visual.alone.perf.phat=[];
visual.alone.perf.pci=[];
visual.alone.bias.phat=[];
visual.alone.bias.pci=[];

visual.sessions.crossModal=[];
visual.sessions.alone=[];

audio=visual;

trialsIncluded=0;
minTrials=25; %if higher than blockingLength, will miss alones
for i=1:max(sessionNum)
    trials=sessionNum==i & goods;

    if sum(trials)>=minTrials
        trialsIncluded=trialsIncluded+sum(trials);

        isBlocking=unique(detailRecords.isBlocking(trials));
        modality=unique(detailRecords.currentModality(trials));

        if length(isBlocking) == 1 && length(modality) == 1
            switch modality
                case 0
                    type=visual;
                case 1
                    type=audio;
                otherwise
                    error('bad modality')
            end

            if ~isBlocking
                totalAgrees=sum(trials & agrees);
                correctAgrees=sum(trials & agrees & detailRecords.correct);
                responseRightAgrees=sum(trials & agrees & detailRecords.response==3);

                totalConflicts=sum(trials & conflicts);
                correctConflicts=sum(trials & conflicts & detailRecords.correct);
                responseRightConflicts=sum(trials & conflicts & detailRecords.response==3);

                [phat pci]=binofit([correctAgrees responseRightAgrees correctConflicts responseRightConflicts],[totalAgrees totalAgrees totalConflicts totalConflicts],alpha);
            else
                totalAlones=sum(trials);
                correctAlones=sum(trials & detailRecords.correct);
                responseRightAlones=sum(trials & detailRecords.response==3);
                [phat pci]=binofit([correctAlones responseRightAlones],[totalAlones totalAlones],alpha);
            end

            if all(pci(:,1)<pci(:,2))
                if ~isBlocking
                    ind=1;
                    type.agree.perf.phat(end+1)=phat(ind);
                    type.agree.perf.pci(end+1,:)=pci(ind,:);

                    ind=2;
                    type.agree.bias.phat(end+1)=phat(ind);
                    type.agree.bias.pci(end+1,:)=pci(ind,:);

                    ind=3;
                    type.conflict.perf.phat(end+1)=phat(ind);
                    type.conflict.perf.pci(end+1,:)=pci(ind,:);

                    ind=4;
                    type.conflict.bias.phat(end+1)=phat(ind);
                    type.conflict.bias.pci(end+1,:)=pci(ind,:);

                    type.sessions.crossModal(end+1)=i;
                else
                    ind=1;
                    type.alone.perf.phat(end+1)=phat(ind);
                    type.alone.perf.pci(end+1,:)=pci(ind,:);

                    ind=2;
                    type.alone.bias.phat(end+1)=phat(ind);
                    type.alone.bias.pci(end+1,:)=pci(ind,:);

                    type.sessions.alone(end+1)=i;
                end
            else
                error('pci''s came back descending')
            end

            switch modality
                case 0
                    visual=type;
                case 1
                    audio=type;
                otherwise
                    error('bad modality')
            end
        else
            error('found isBlocking or currentModality changing state during session')
        end
    else
        fprintf('skipping a %d session\n',sum(trials))
    end
end
fprintf('included %d clumped of %d good trials (%g%%)\n',trialsIncluded,sum(goods),round(100*trialsIncluded/sum(goods)));

figure('Name',sprintf('%s: crossModal performance and bias',subjectID))
c={'r' 'k'};
subplot(3,2,1)
makePerfBiasPlot(visual.sessions.alone,visual.alone,c);
title('visual')
ylabel('alone')

subplot(3,2,2)
makePerfBiasPlot(audio.sessions.alone,audio.alone,c);
title('audio')

subplot(3,2,3)
makePerfBiasPlot(visual.sessions.crossModal,visual.agree,c);
ylabel('agree')

subplot(3,2,4)
makePerfBiasPlot(audio.sessions.crossModal,audio.agree,c);

subplot(3,2,5)
makePerfBiasPlot(visual.sessions.crossModal,visual.conflict,c);
ylabel('conflict')
xlabel('session')

subplot(3,2,6)
makePerfBiasPlot(audio.sessions.crossModal,audio.conflict,c);
xlabel('session')
pth='C:\Documents and Settings\rlab\Desktop\detailedRecords';
saveas(gcf,fullfile(pth,[subjectID '_crossModal']),'png');

doParams=false;
if doParams
    figure('Name',sprintf('%s: crossModal params',subjectID))
    subplot(6,1,1)
    plot(detailRecords.HFdetailsContrasts(:,goods)');
    title('HF Contrasts')

    subplot(6,1,2)
    plot(detailRecords.HFdetailsXPosPcts(:,goods)');
    title('HF X Pos')

    subplot(6,1,3)
    plot([detailRecords.SDdetailsLeftAmplitude(goods)' detailRecords.SDdetailsRightAmplitude(goods)']);
    title('SD amps')

    subplot(6,1,4)
    plot(detailRecords.blockingLength(goods));
    title('blocking length')

    subplot(6,1,5)
    plot(detailRecords.currentModalityTrialNum(goods));
    title('modality (0=HF(visual); 1=SD(auditory))')

    subplot(6,1,6)
    days=floor(detailRecords.date(goods));
    days=days-min(days);
    plot(days);
    title('day')
end
end