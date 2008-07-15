
format short g

%load smallData
daysBack=20;
verbose=1;
devs=unique(smallData.deviation);
dev=devs(1); numCorrect=[]; numAttempted=[]; dpr=[];

%
contrasts=unique(smallData.targetContrast(smallData.date>now-daysBack));
contrasts(contrasts==0)=[];  %remove the no contrast condition ,  use correctResponseIsLeft?

%reconstructs the keypress that would be correct (could return this directly)
%this is used by the dprime calulation
smallData.correctAnswerID=(smallData.correctResponseIsLeft);
smallData.correctAnswerID(smallData.correctAnswerID==-1)=3;

%define conditions as subset of trials
some = smallData.deviation==dev & smallData.date>now-daysBack & smallData.correctionTrial==0;
conditionInds=getFlankerConditionInds(smallData,some);

%DO THE ANALYSIS
for i=1:size(contrasts,2)         %for all contrast
    for j=1:size(conditionInds,1) %for all conditions

        %chooses a contrast
        which=(smallData.targetContrast==contrasts(i)) & conditionInds(j,:);


        %choose trials with no signal
        trialRange=zeros(size(which));  %restrict noSigTrials to the same time range (assume one continuous block- is that true?)
        trialRange(min(find(which)):max(find(which)))=1;
        whichNoSig=conditionInds(j,:) & (smallData.correctResponseIsLeft==1) & trialRange;


        restrictSampleOfNoSig=1;
        %if =0 then dprime will sample more (accoss "what contrast would have been") to get a better estimate of the no signal case
        %however, percent correct will be wrong! so if you set to zero,
        %plot hit rate instead of pct correct
        if restrictSampleOfNoSig
            %randomly draw N samples from the available candidates
            numSamples=min([sum(whichNoSig) sum(which)]);
            candidates=find(whichNoSig);
            randIndex=randperm(length(candidates));
            reducedWhichNoSig=zeros(size(whichNoSig));
            reducedWhichNoSig(candidates(randIndex(1:numSamples)))=1;
            if verbose
                disp('*')
                disp(sprintf('contrast: %3.3g condition: %d', contrasts(i),j))
                disp(sprintf('correct rejection and false alarms are RESTRICTED when they could have been sampled %2.2g times more frequently ',sum(whichNoSig)/sum(which)))
            end
        else
            %use everything in the timeRange
            if verbose
                disp('*')
                disp(sprintf('contrast: %3.3g condition: %d', contrasts(i),j))
                disp(sprintf('correct rejection and false alarms are sampled %2.2g times more frequently ',sum(whichNoSig)/sum(which)))
            end
        end

        %percent correct
        numCorrect(i,j) =sum(smallData.correct(which | reducedWhichNoSig));
        numAttempted(i,j)=sum(which | reducedWhichNoSig);

        %hitRate
        %numCorrect(i,j) =sum(smallData.correct(which));
        %numAttempted(i,j)=sum(which);

        %d-prime
        if verbose
            flag='nothing';
        else
            flag='silent'
        end
        [dpr(i,j) anal]=dprime(smallData.response(which | whichNoSig),smallData.correctAnswerID(which | whichNoSig),flag);
        analysis{i,j}=anal;
    end
end

perf3=numCorrect./numAttempted
dpr=dpr
numAttempted=numAttempted

%ploting params
someConditions=[1 2 ];
someConditions=[1:5];
someConditions=[1:7];
nm=length(someConditions);
blacken=[1:nm];

%choose colors
colors=hsv(nm);
colors(blacken,:)=0;  % set all to black
colors(2,:)=[1 0 0];  % VV is red
colors(6,:)=[0 1 0];  % V-target is green
colors(7,:)=[0 0 1];  % H-target is blue


smallDisplacement=([1:nm]-ceil(nm/2))/(nm*20);
alpha=0.05;

perf=perf3;
title('performance per condition per contrast')
subplot(211); hold on; ylabel('Percent Correct')  %when Signal Present and Absent
for condition=someConditions
    [performance, pci] = binofit(numCorrect(:,condition),numAttempted(:,condition),alpha);
    errorbar(contrasts+smallDisplacement(condition),performance,performance-pci(:,1),pci(:,2)-performance,'color',colors(condition,:))
end
for condition=someConditions
    plot(contrasts+smallDisplacement(condition),perf(:,condition),'.','MarkerSize',20,'color',colors(condition,:))
end
legend({'all','VV','VH','HV','HH','V','H'},'Location','NorthEastOutside')
hold off

perf=dpr
subplot(212); hold on; ylabel('Sensitivity (d-prime)')
for condition=someConditions
    plot(contrasts+smallDisplacement(condition),perf(:,condition),'.','MarkerSize',20,'color',colors(condition,:))
end
legend({'all','VV','VH','HV','HH','V','H'},'Location','NorthEastOutside')
hold off



%saveas(gcf,['out/graphs/collinearAt3dev-rat102' datestr(max(date),29) '.png'],'png');

%function  [numCorrect numAttempted]=getPerConditionCounts(smallData,contrasts,dev,daysBack);
%
%   for i=1:size(contrasts,2)
%         numCorrect(i,1)=sum(smallData.correct(smallData.targetContrast==contrasts(i) & smallData.deviation==dev & smallData.date>now-daysBack));
%         numCorrect(i,2)=sum(smallData.correct(smallData.targetContrast==contrasts(i) & smallData.deviation==dev & smallData.date>now-daysBack & smallData.targetOrientation==0 & smallData.flankerOrientation==0));
%         numCorrect(i,3)=sum(smallData.correct(smallData.targetContrast==contrasts(i) & smallData.deviation==dev & smallData.date>now-daysBack & smallData.targetOrientation==0 & smallData.flankerOrientation~=0));
%         numCorrect(i,4)=sum(smallData.correct(smallData.targetContrast==contrasts(i) & smallData.deviation==dev & smallData.date>now-daysBack & smallData.targetOrientation~=0 & smallData.flankerOrientation==0));
%         numCorrect(i,5)=sum(smallData.correct(smallData.targetContrast==contrasts(i) & smallData.deviation==dev & smallData.date>now-daysBack & smallData.targetOrientation~=0 & smallData.flankerOrientation~=0));
%
%         numAttempted(i,1)=sum(                (smallData.targetContrast==contrasts(i) & smallData.deviation==dev & smallData.date>now-daysBack));
%         numAttempted(i,2)=sum(                (smallData.targetContrast==contrasts(i) & smallData.deviation==dev & smallData.date>now-daysBack & smallData.targetOrientation==0 & smallData.flankerOrientation==0));
%         numAttempted(i,3)=sum(                (smallData.targetContrast==contrasts(i) & smallData.deviation==dev & smallData.date>now-daysBack & smallData.targetOrientation==0 & smallData.flankerOrientation~=0));
%         numAttempted(i,4)=sum(                (smallData.targetContrast==contrasts(i) & smallData.deviation==dev & smallData.date>now-daysBack & smallData.targetOrientation~=0 & smallData.flankerOrientation==0));
%         numAttempted(i,5)=sum(                (smallData.targetContrast==contrasts(i) & smallData.deviation==dev & smallData.date>now-daysBack & smallData.targetOrientation~=0 & smallData.flankerOrientation~=0));
%    end

