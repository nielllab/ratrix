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

finalStep=7;
goods = goods & detailRecords.trainingStepNum==finalStep; %danger!

[a junk difficulty]=unique(sort(detailRecords.suffices)','rows');

difficulties=unique(difficulty);
if any(difficulties~=[1:size(a,1)]')
    error('bad difficulties')
end

badDifficulties=find(sum((a==0)')); %these should be coming through as nans -- why are they zeros?  see extractDetailFields...

if ~isempty(badDifficulties)
    a=a([1:size(difficulties,1)]~=badDifficulties,:);
    difficulties=difficulties([1:size(difficulties,1)]~=badDifficulties,:);
    goods=goods' & difficulty~=badDifficulties;
end

alpha=.05;
for d=1:length(difficulties)
    trials = goods & difficulty==difficulties(d);
    correct(d)=sum(trials' & detailRecords.correct);
    total(d) = sum(trials);
    strs{d}=sprintf('%d-%d',a(d,1),a(d,2));
end

[data.phat data.pci]=binofit(correct,total,alpha);

if all(data.pci(:,1)<data.pci(:,2))
    figName=sprintf('%s: morph performance',subjectID);
    figure('Name',figName)
    makeConfPlot(1:length(difficulties),data,'k');
    title(figName);
        set(gca,'XTick',1:length(difficulties));
    set(gca,'XTickLabel',strs);
else
    error('pci''s came back descending')
end

pth='C:\Documents and Settings\rlab\Desktop\detailedRecords';
saveas(gcf,fullfile(pth,[subjectID '_morph']),'png');