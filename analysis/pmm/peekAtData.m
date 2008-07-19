
format short g

%load smallData

daysBack=30;
conditionType='fourFlankers'; %'everything','fourFlankers','onlyTarget','allOrientations','allPixPerCycs'
verbose=0;
subject=smallData.info.subject;


if exist('stepUsed','var')
    stepFilter=(smallData.step==stepUsed);
    trialFilter=stepFilter;
else
    timeFilter=smallData.date>max(smallData.date)-daysBack;
    trialFilter=timeFilter;
end


contrasts=unique(smallData.targetContrast(trialFilter & ~isnan(smallData.targetContrast)));
devs =unique(smallData.deviation(trialFilter & ~isnan(smallData.deviation)));
flankerContrasts=unique(smallData.flankerContrast(trialFilter & ~isnan(smallData.flankerContrast)));
%contrasts(contrasts==0)=[];  %remove the no contrast condition ,  use correctResponseIsLeft?

%reconstructs the keypress that would be correct (could return this directly)
%this is used by the dprime calulation
smallData.correctAnswerID=(smallData.correctResponseIsLeft);
smallData.correctAnswerID(smallData.correctAnswerID==-1)=3;

%define conditions as subset of trials
%tempFilter = smallData.pixPerCycs==4;
goods = trialFilter & getGoods(smallData);% & tempFilter;
[conditionInds conditionNames]=getFlankerConditionInds(smallData,goods,conditionType);

numCorrect=[]; numAttempted=[]; dpr=[];
%DO THE ANALYSIS
for i=1:size(contrasts,2)         %for all target contrasts
    for j=1:size(conditionInds,1) %for all conditions
        for k=1:size(devs,2)      %for all deviations
            for m=1:size(flankerContrasts,2)

                %chooses a contrast and deviation and flanker contrast at this condition
                which= (smallData.targetContrast==contrasts(i)) & conditionInds(j,:) & (smallData.deviation==devs(k) & (smallData.flankerContrast==flankerContrasts(m)));  % why none of these?
                numTrials=sum(which);
                if numTrials>0
                    if verbose
                        disp(sprintf('there are %d trials to analyze here',sum(which)))
                        disp(sprintf('there are %d trials for this flanker contrast',sum(smallData.flankerContrast==flankerContrasts(m))))
                        disp(sprintf('there are %d trials for this condition and target contrast',sum((smallData.targetContrast==contrasts(i)) & conditionInds(j,:) )))
                        disp(sprintf('there are %d trials for this deviation, dev=%d',sum(smallData.deviation==devs(k)), devs(k)))
                    end

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
                            disp(sprintf('contrast: %3.3g condition: %d deviation: %d flankerContrast: %d', contrasts(i),j,devs(k),flankerContrasts(m)))
                            disp(sprintf('correct rejection and false alarms are RESTRICTED when they could have been sampled %2.2g times more frequently ',sum(whichNoSig)/sum(which)))
                        end
                    else
                        %use everything in the timeRange
                        if verbose
                            disp('*')
                            disp(sprintf('contrast: %3.3g condition: %d deviation: %d flankerContrast: %d', contrasts(i),j,devs(k),flankerContrasts(m)))
                            disp(sprintf('correct rejection and false alarms are sampled %2.2g times more frequently ',sum(whichNoSig)/sum(which)))
                        end
                    end

                    %percent correct
                    numCorrect(i,j,k,m) =sum(smallData.correct(which | reducedWhichNoSig));
                    numAttempted(i,j,k,m)=sum(which | reducedWhichNoSig);

                    %hitRate
                    %numCorrect(i,j,k,m) =sum(smallData.correct(which));
                    %numAttempted(i,j,k,m)=sum(which);

                    %d-prime
                    if verbose
                        flag='nothing';
                    else
                        flag='silent';
                    end

                    [dpr(i,j,k,m) anal]=dprime(smallData.response(which | whichNoSig),smallData.correctAnswerID(which | whichNoSig),flag);
                    analysis{i,j,k,m}=anal;
                else
                    dpr(i,j,k,m)=NaN;
                    analysis{i,j,k,m}=[];
                end
            end
        end
    end
end

pctCor=numCorrect./numAttempted;
dpr=dpr;
numAttempted=numAttempted;


%note: perf used to be (contrast x condition) now its (contrast x condition x dev x flankerContrast)
%... check plot assumptions


%which offset is used for this?!
%which flanker contrast is used for this?!
%% performance per contrast

figure
plotMethod='mostFrequentDevAndFlankerContrast' %'all devs and flankerContrasts';
plotParams=getPlotParameters(conditionType,conditionNames)
plotParams.featureVals.contrasts=contrasts;
plotParams.featureVals.devs=devs;
plotParams.featureVals.flankerContrasts=flankerContrasts;
plotPerformancePerContrastPerCondition(numCorrect, numAttempted, dpr, plotMethod, plotParams)
title(subject)
%%

% figure; surf(reshape(pctCor(end,:,:,end),size(pctCor,2),size(pctCor,3))); %highest targetContrast and flankerContrast at all conditions and devs
% zlabel('% correct'); xlabel('flanker offset'); ylabel('condition');


%% plot surfs

if size(devs,2)>1
    %target Contrast
    highContrast=1;
    lowContrast=1; %0.75
    lowContrastInd =find(contrasts==lowContrast);
    highContrastInd=find(contrasts==highContrast);

    %flankerContrast
    lowFlankerContrast=0;
    highFlankerContrast=1;
    lowFlankerContrastInd =find(flankerContrasts==lowFlankerContrast);
    highFlankerContrastInd=find(flankerContrasts==highFlankerContrast);


    figure
    title('effect of target contrast');
    surfColor=[0.2]*ones(size(dpr,2),size(dpr,3),3);
    h1=surf(reshape(dpr(highContrastInd,:,:,highFlankerContrastInd),size( dpr,2),size( dpr,3)),surfColor); %l contrast at all conditions and devs
    hold on
    surfColor=[0.6]*ones(size(dpr,2),size(dpr,3),3);
    h2=surf(reshape(dpr(lowContrastInd,:,:,highFlankerContrastInd),size( dpr,2),size( dpr,3)),surfColor); %lowest contrast at all conditions and devs
    zlabel('d-prime'); xlabel('flanker offset'); ylabel('condition');
    legend([h1,h2],{sprintf('%d%% target contrast',100*highContrast),sprintf('%d%% target contrast',100*lowContrast)})
    set(gca,'YTickLabel',conditionNames)
    set(gca,'XTickLabel',devs*16)


    figure
    title('effect of flanker contrast');
    surfColor=[0.2]*ones(size(dpr,2),size(dpr,3),3);
    h1=surf(reshape(dpr(lowContrastInd,:,:,highFlankerContrastInd),size( dpr,2),size( dpr,3)),surfColor); %l contrast at all conditions and devs
    hold on
    surfColor=[0.6]*ones(size(dpr,2),size(dpr,3),3);
    h2=surf(reshape(dpr(lowContrastInd,:,:,lowFlankerContrastInd),size( dpr,2),size( dpr,3)),surfColor); %lowest contrast at all conditions and devs
    zlabel('d-prime'); xlabel('flanker offset'); ylabel('condition');
    legend([h1,h2],{sprintf('%d%% flanker contrast',100*flankerContrasts(highFlankerContrastInd)),sprintf('%d%% flanker contrast',100*flankerContrasts(lowFlankerContrastInd))})
    set(gca,'YTickLabel',conditionNames)
    set(gca,'YTick',[1:length(conditionNames)])
    set(gca,'XTickLabel',devs*16)
    set(gca,'XTick',[1:length(devs)])
    get(gca)

end

plotPhase=0;
if plotPhase

    %     numTrials=2000;
    % d.targetPhase=floor(rand(1,numTrials)*4)*(2*pi)/4;
    % d.flankerPhase=floor(rand(1,numTrials)*4)*(2*pi)/4;
    % d.targetOrientation=floor(rand(1,numTrials)*2)*pi/2;
    % d.flankerOrientation=floor(rand(1,numTrials)*2)*pi/2;
    % d.correct=double(rand(1,numTrials)<0.6);


    %     switch conditionType
    %         case 'fourFlankers'
    %             thisContext=conditionInds(1,:); %VV
    %         otherwise
    %             error ('bad condition');
    %     end

    f1=figure; hold on;
    f2=figure; hold on;

    numConditions=size(conditionInds,1);
    numDevs=size(devs,2)
    for j=1:numConditions %for all conditions

        samePhase=(smallData.targetPhase==smallData.flankerPhase);
        antiPhase=(smallData.targetPhase==mod(smallData.flankerPhase+pi,2*pi));
        otherPhase=(~samePhase & ~antiPhase);



        for k=1:numDevs      %for all deviations

            dev=devs(k);
            samePhaseIndices=(samePhase & conditionInds(j,:) & some & smallData.deviation==dev);
            antiPhaseIndices=(antiPhase & conditionInds(j,:) & some & smallData.deviation==dev);
            otherPhaseIndices=(otherPhase & conditionInds(j,:) & some & smallData.deviation==dev);


            samePhaseResponses=(smallData.correct(samePhaseIndices));
            antiPhaseResponses=(smallData.correct(antiPhaseIndices));
            otherPhaseResponses=(smallData.correct(otherPhaseIndices));

            [P(1), PCI(1:2,1)] = binofit(sum(samePhaseResponses),length(samePhaseResponses));
            [P(2), PCI(1:2,2)] = binofit(sum(antiPhaseResponses),length(antiPhaseResponses));
            [P(3), PCI(1:2,3)] = binofit(sum(otherPhaseResponses),length(otherPhaseResponses));

            figure(f1); subplot(numDevs,numConditions,(j-1)*(numDevs)+k); hold on;
            smoothingWidth=300;

            [performance]=calculateSmoothedPerformances(samePhaseResponses',smoothingWidth,'boxcar','powerlawBW');
            plot(find(samePhaseIndices),performance,'color',plotParams.colors(j,:))

            [performance]=calculateSmoothedPerformances(antiPhaseResponses',smoothingWidth,'boxcar','powerlawBW');
            plot(find(antiPhaseIndices),performance,'color',plotParams.colors(j,:), 'LineStyle', '.');

            [performance]=calculateSmoothedPerformances(otherPhaseResponses',smoothingWidth,'boxcar','powerlawBW');
            plot(find(otherPhaseIndices),performance,'color',plotParams.colors(j,:), 'LineStyle', '-.')

            axis([min(find(samePhaseIndices)),max(find(samePhaseIndices)),.3,1])
            legend({sprintf('same; N=%d',sum(samePhaseIndices)), sprintf('anti; N=%d',sum(antiPhaseIndices)), sprintf('other; N=%d',sum(otherPhaseIndices))})
            text(min(find(samePhaseIndices)), .9,sprintf('Dev=%0.2g, %s', devs(k)*16, conditionNames{j}))

            if j==1 && k==1 %b/c we can't title subplots well
                text(min(find(samePhaseIndices)),0.7,sprintf('%s Step: %d',subject, stepUsed))
            end

            figure(f2); subplot(numDevs,numConditions,(j-1)*(numDevs)+k); hold on;
            bar(P,'c')
            errorbar([1:length(P)], P, P-PCI(1,:), PCI(2,:)-P)
            axis([0,length(P)+1,.3,1])
            if j==1 && k==1  %b/c we can't title subplots well
                text(min(find(samePhaseIndices)),0.7,sprintf('%s Step: %d',subject, stepUsed))
            end
        end
        %[d.targetPhase(otherPhase); d.flankerPhase(otherPhase)]

    end
end
%%
% figure
% subplot(211); surf(reshape(dpr( 1,:,:,end),size( dpr,2),size( dpr,3))); %lowest contrast at all conditions and devs
% title('lower contrast'); zlabel('d-prime'); xlabel('flanker offset'); ylabel('condition');
% subplot(212); surf(reshape(dpr( end,:,:,end),size( dpr,2),size( dpr,3))); %l contrast at all conditions and devs
% title('high contrast'); zlabel('d-prime'); xlabel('flanker offset'); ylabel('condition');





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

