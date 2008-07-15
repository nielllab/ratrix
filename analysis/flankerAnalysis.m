function [stats plotParams]=flankerAnalysis(smallData, conditionType, plotType, performanceMeasure, stepUsed, verbose)
%assumes detection!  assumes goRightDetection (could be made more general) use correctResponseIsLeft?
%NEVER USE FOR DISCRIMINATION, including goToSide (unless you change all of the stats to be appropiate)
isDetection=1;




format short g



%load smallData

if ~exist('conditionType', 'var'); conditionType=[];end
if isempty(conditionType)
    conditionType='fourFlankers'; %'everything','fourFlankers','onlyTarget','allOrientations','allPixPerCycs'
end

if ~exist('plotType', 'var'); plotType=[];end
if isempty(plotType)
    plotType='performancePerContrastPerCondition'; %performancePerContrastPerCondition, surfFlankerContrast, surfTargetContrast, phaseEffect
end

if ~exist('performanceMeasure', 'var'); performanceMeasure=[];end
if isempty(performanceMeasure)
    performanceMeasure = 'pctCor'; % pctCor, dpr, eb
end

if ~exist('verbose', 'var'); verbose=[];end
if isempty(verbose)
    verbose=0;
end

subject=char(smallData.info.subject);

%timeFilter=smallData.date>max(smallData.date)-daysBack;
if ~exist('stepUsed', 'var'); stepUsed=[]; end
if isempty(stepUsed)
    trialFilter=ones(size(smallData.date));
else
    trialFilter=(smallData.step==stepUsed);
end

contrasts=unique(smallData.targetContrast(trialFilter & ~isnan(smallData.targetContrast)));
devs =unique(smallData.deviation(trialFilter & ~isnan(smallData.deviation)));
flankerContrasts=unique(smallData.flankerContrast(trialFilter & ~isnan(smallData.flankerContrast)));

if isDetection
    if ~contrasts(1)==0
        error('can''t be detection');
    else 
        %remove the no contrasts condition
        contrasts(contrasts==0)=[];  %remove the no contrast condition ,  

    end
    mergeWithSameTypeZeroContrast=1;
    if length(contrasts)==2
        restrictSampleOfNoSig=0;
    else
        restrictSampleOfNoSig=1; %you want to restrict because otherwise there appear to be more noSig conditions after mergeWithSameTypeZeroContrast
        %As long as there are multiple contrasts with equal probability of
        %occurring, everything should be cool, if not, check the size of the
        %restricted set
    end
end

% if isDiscrimination
%     mergeWithSameTypeZeroContrast=0;
%     restrictSampleOfNoSig=0;
% end

%reconstructs the keypress that would be correct (could return this directly)
%this is used by the dprime calulation
smallData.correctAnswerID=(smallData.correctResponseIsLeft);
smallData.correctAnswerID(smallData.correctAnswerID==-1)=3;

%define conditions as subset of trials
%tempFilter = smallData.pixPerCycs==4;
goods = trialFilter & getGoods(smallData,'withoutAfterError');% & tempFilter;
[conditionInds conditionNames]=getFlankerConditionInds(smallData,goods,conditionType);

%initialize
numCorrect=zeros(size(contrasts,2), size(conditionInds,1), size(devs,2), size(flankerContrasts,2)); 
numAttempted=numCorrect; 
numResponseRightward = numCorrect;
dpr=nan(size(numCorrect)); 

emptyAnalysis.hits=0; % we need to sum across these so, empty and NaNs get in the way,
emptyAnalysis.correctRejects=0;
emptyAnalysis.misses=0;
emptyAnalysis.falseAlarms=0;
emptyAnalysis.hitsPercent=NaN;
emptyAnalysis.correctRejectsPercent=NaN;
emptyAnalysis.missesPercent=NaN;
emptyAnalysis.falseAlarmsPercent=NaN;
emptyAnalysis.dprime=NaN;
emptyAnalysis.responseBias=NaN;

                    
%DO THE ANALYSIS
for i=1:size(contrasts,2)         %for all target contrasts
    for j=1:size(conditionInds,1) %for all conditions
        for k=1:size(devs,2)      %for all deviations
            for m=1:size(flankerContrasts,2)

                %chooses a contrast and  condition and deviation and flanker contrast 
                which= (smallData.targetContrast==contrasts(i)) & conditionInds(j,:) & (smallData.deviation==devs(k) & (smallData.flankerContrast==flankerContrasts(m)));  % why none of these?
                numTrials=sum(which);
                if numTrials>0
                    if verbose
                        disp(sprintf('there are %d trials to analyze here',sum(which)))
                        disp(sprintf('there are %d trials for this flanker contrast',sum(smallData.flankerContrast==flankerContrasts(m))))
                        disp(sprintf('there are %d trials for this condition and target contrast',sum((smallData.targetContrast==contrasts(i)) & conditionInds(j,:) )));
                        disp(sprintf('there are %d trials for this deviation, dev=%d',sum(smallData.deviation==devs(k)), devs(k)))
                    end

                    if mergeWithSameTypeZeroContrast 
                        %this only matters when there are multiple
                        %contrasts and analyzing detection! If there are
                        %only two contrasts, then don't bother. If doing
                        %discrimination, then don't bother. (Could even be bad)
                        
                        %choose trials with no signal
                        trialRange=zeros(size(which));  %restrict noSigTrials to the same time range (assume one continuous block- is that true?)
                        trialRange(min(find(which)):max(find(which)))=1;


                        whichNoSig=trialRange & (smallData.targetContrast==0) & conditionInds(j,:) & (smallData.deviation==devs(k) & (smallData.flankerContrast==flankerContrasts(m)));
                        %note that zero contrast condition remains the same,
                        %other contrast are paried up with some zero contrasts
                        %of the same type - if no zero contrast exist (ie
                        %discrimination) - then this has no effect, but beware
                        %of dicrimination psychophysics that has some zero contrast!
                        %this would arficicially


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
                            reducedWhichNoSig=whichNoSig;
                            if verbose
                                disp('*')
                                disp(sprintf('contrast: %3.3g condition: %d deviation: %d flankerContrast: %d', contrasts(i),j,devs(k),flankerContrasts(m)))
                                disp(sprintf('correct rejection and false alarms are sampled %2.2g times more frequently ',sum(whichNoSig)/sum(which)))
                            end
                        end
                        
                        % for pctCorrect
                        numCorrect(i,j,k,m) =sum(smallData.correct(which | reducedWhichNoSig));
                        numAttempted(i,j,k,m)=sum(which | reducedWhichNoSig);
                        numResponseRightward(i,j,k,m)=sum(smallData.response(which | reducedWhichNoSig)==3);
                        %assumes 2afc for bias to make sense 50/50%
                        
                        %for hitRate
                        %numSigsPresent(i,j,k,m)=sum(which);
                        %numHits(i,j,k,m)=sum(smallData.correct(which));
                        %numSigsAbsent(i,j,k,m)=sum(reducedWhichNoSig);
                        %numCR(i,j,k,m)=sum(smallData.correct(logical(reducedWhichNoSig)));

                 
                    else
                        numCorrect(i,j,k,m) =sum(smallData.correct(which));
                        numAttempted(i,j,k,m)=sum(which);
                        numResponseRightward(i,j,k,m)=sum(smallData.response(which)==3);
                        reducedWhichNoSig=zeros(size(smallData.correct));
                    end
                    
                    %d-prime
                    if verbose
                        flag='nothing';
                    else
                        flag='silent';
                    end

                    [dpr(i,j,k,m) anal]=dprime(smallData.response(which | reducedWhichNoSig),smallData.correctAnswerID(which | reducedWhichNoSig),flag);
                    analysis{i,j,k,m}=anal;
                else
                    
                    dpr(i,j,k,m) = NaN;
                    analysis{i,j,k,m}=emptyAnalysis;
                                       
                end
            end
        end
    end
end



    stats.numCorrect=numCorrect;
    stats.numAttempted=numAttempted;
    stats.numResponseRightward=numResponseRightward;

    %stats.dprAnalysis=analysis  %don't add the cell because it's the wrong format
    
    

    x=cell2mat(analysis);
    stats.hits=reshape([x.hits], size(numCorrect));
    stats.correctRejects=reshape([x.correctRejects], size(numCorrect));
    stats.misses=reshape([x.misses], size(numCorrect));
    stats.falseAlarms=reshape([x.falseAlarms], size(numCorrect));


switch performanceMeasure
    case 'pctCor'
        perf = numCorrect./numAttempted;
    case 'pctRightward'
        bias= numResponseRightward./numAttempted;
    case 'hitRate'
        numCorrect=stats.hits;  %total correct with no signal
        numAttempted=stats.misses+stats.hits; %total attempted with signal
    case 'correctRejections'
        numCorrect=stats.correctRejects; %total correct with no signal
        numAttempted=stats.correctRejects+stats.falseAlarms; %totally attempted with no signal
    case 'dpr'
        perf = dpr;
    case 'eb'
        error('eb does not exist yet')
    otherwise
        error('bad performanceMeasure')
end

% 
% 
% 
% switch performanceMeasure
%     case 'pctCor'
%         perf = numCorrect./numAttempted;
%     case 'pctRightward'
%         bias= numResponseRightward./numAttempted;
%     case 'hitRate'
%         numCorrect=numHits;
%         numAttempted=numSigsPresent;
%     case 'correctRejections'
%         numCorrect=numCR;
%         numAttempted=numSigsAbsent;
%     case 'dpr'
%         perf = dpr;
%     case 'eb'
%         error('eb does not exist yet')
%     otherwise
%         error('bad performanceMeasure')
% end



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


%note: perf used to be (contrast x condition) now its (contrast x condition x dev x flankerContrast)
%... check plot assumptions


%which offset is used for this?!
%which flanker contrast is used for this?!
%% performance per value

        plotParams=getPlotParameters(conditionType,conditionNames)
        plotParams.featureVals.contrasts=contrasts;
        plotParams.featureVals.devs=devs;
        plotParams.featureVals.flankerContrasts=flankerContrasts;
        title(subject)
        
switch plotType
    case 'performancePerContrastPerCondition'

        plotMethod='mostFrequentDevAndFlankerContrast' %'all devs and flankerContrasts';
        valueName = 'contrasts';
        plotPerformancePerValuePerCondition(numCorrect, numAttempted, numResponseRightward, performanceMeasure, valueName, plotMethod, plotParams)

    case 'performancePerDeviationPerCondition'

        plotMethod='allTargetAndFlankerContrasts'
        valueName = 'devs';
        plotPerformancePerValuePerCondition(numCorrect, numAttempted, numResponseRightward,performanceMeasure, valueName, plotMethod, plotParams)

    case 'biasPerDeviationPerCondition'

        plotMethod='allTargetAndFlankerContrasts'
        valueName = 'devs';
        plotPerformancePerValuePerCondition(numCorrect, numAttempted, numResponseRightward,performanceMeasure, valueName, plotMethod, plotParams)

    case 'surfFlankerContrast'
        if ~size(devs,2)>1; error('more deviations needed'); end
        title('effect of flanker contrast');
        surfColor=[0.2]*ones(size(perf,2),size(perf,3),3);
        h1=surf(reshape(perf(lowContrastInd,:,:,highFlankerContrastInd),size( perf,2),size( perf,3)),surfColor); %l contrast at all conditions and devs
        hold on
        surfColor=[0.6]*ones(size(perf,2),size(perf,3),3);
        h2=surf(reshape(perf(lowContrastInd,:,:,lowFlankerContrastInd),size( perf,2),size( perf,3)),surfColor); %lowest contrast at all conditions and devs
        zlabel(performanceMeasure); xlabel('flanker offset'); ylabel('condition');
        legend([h1,h2],{sprintf('%d%% flanker contrast',100*flankerContrasts(highFlankerContrastInd)),sprintf('%d%% flanker contrast',100*flankerContrasts(lowFlankerContrastInd))})
        set(gca,'YTickLabel',conditionNames)
        set(gca,'YTick',[1:length(conditionNames)])
        set(gca,'XTickLabel',devs*16)
        set(gca,'XTick',[1:length(devs)])
        get(gca)

    case 'surfTargetContrast'
        if ~size(devs,2)>1; error('more deviations needed'); end
        title('effect of target contrast');
        surfColor=[0.2]*ones(size(perf,2),size(perf,3),3);
        h1=surf(reshape(perf(highContrastInd,:,:,highFlankerContrastInd),size( perf,2),size( perf,3)),surfColor); %l contrast at all conditions and devs
        hold on
        surfColor=[0.6]*ones(size(perf,2),size(perf,3),3);
        h2=surf(reshape(perf(lowContrastInd,:,:,highFlankerContrastInd),size( perf,2),size( perf,3)),surfColor); %lowest contrast at all conditions and devs
        zlabel(performanceMeasure); xlabel('flanker offset'); ylabel('condition');
        legend([h1,h2],{sprintf('%d%% target contrast',100*highContrast),sprintf('%d%% target contrast',100*lowContrast)})
        set(gca,'YTickLabel',conditionNames)
        set(gca,'XTickLabel',devs*16)

    case 'phaseEffect'
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
                samePhaseIndices=(samePhase & conditionInds(j,:) & trialFilter & smallData.deviation==dev);
                antiPhaseIndices=(antiPhase & conditionInds(j,:) & trialFilter & smallData.deviation==dev);
                otherPhaseIndices=(otherPhase & conditionInds(j,:) & trialFilter & smallData.deviation==dev);


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
    otherwise
        error('bad plotType');
end



%%

% figure; surf(reshape(pctCor(end,:,:,end),size(pctCor,2),size(pctCor,3))); %highest targetContrast and flankerContrast at all conditions and devs
% zlabel('% correct'); xlabel('flanker offset'); ylabel('condition');

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

