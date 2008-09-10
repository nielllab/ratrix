function testAnalysis(sm)

blockLength=400;
numBlocks=30;
auditoryPerf=.7;
visualPerf=.9;
interference=.1;

detailRecords.HFdetailsPctCorrectionTrials=[];
detailRecords.SDdetailsPctCorrectionTrials=[];
detailRecords.modalitySwitchMethod={};
detailRecords.modalitySwitchType={};
detailRecords.containedManualPokes=[];
detailRecords.didHumanResponse=[];
detailRecords.containedForcedRewards=[];
detailRecords.didStochasticResponse=[];

detailRecords.date=[];
detailRecords.isBlocking=[];
detailRecords.currentModality=[];
detailRecords.isCorrection=[];
detailRecords.HFtargetPorts=[];
detailRecords.SDtargetPorts=[];

detailRecords.targetPorts={};
detailRecords.distractorPorts={};

detailRecords.correct=[];
detailRecords.response=[];

ports=[1 3];
t=now;
for n=1:numBlocks
    t=t+1;
    modality=rand>.5;

    for b=1:blockLength
        detailRecords.HFdetailsPctCorrectionTrials(end+1)=.5;
        detailRecords.SDdetailsPctCorrectionTrials(end+1)=.5;
        detailRecords.modalitySwitchMethod{end+1}='Random';
        detailRecords.modalitySwitchType{end+1}='ByNumberOfHoursRun';
        detailRecords.isCorrection(end+1)=0;
        detailRecords.containedManualPokes(end+1)=0;
        detailRecords.didHumanResponse(end+1)=0;
        detailRecords.containedForcedRewards(end+1)=0;
        detailRecords.didStochasticResponse(end+1)=0;

        detailRecords.currentModality(end+1)=modality;

        t=t+.01;
        detailRecords.date(end+1)=t;

        if .3<b/blockLength
            detailRecords.isBlocking(end+1)=0;
        else
            detailRecords.isBlocking(end+1)=1;
        end

        detailRecords.HFtargetPorts(end+1)=ports((rand>.5)+1);
        detailRecords.SDtargetPorts(end+1)=ports((rand>.5)+1);

        if modality
            detailRecords.targetPorts{end+1}=detailRecords.SDtargetPorts(end);
        else
            detailRecords.targetPorts{end+1}=detailRecords.HFtargetPorts(end);
        end
        detailRecords.distractorPorts{end+1}=ports(fliplr(ports==detailRecords.targetPorts{end}));

        if modality
            perf=auditoryPerf;
        else
            perf=visualPerf;
        end
        
        if ~detailRecords.isBlocking(end)
            if detailRecords.HFtargetPorts(end)==detailRecords.SDtargetPorts(end)
                perf=perf+interference;
            else
                perf=perf-interference;
            end
        end
        
        detailRecords.correct(end+1)=rand<perf;
        if detailRecords.correct(end)
            detailRecords.response(end+1)=detailRecords.targetPorts{end};
        else
            detailRecords.response(end+1)=detailRecords.distractorPorts{end};
        end
    end
end

analysis(sm,detailRecords,'test');