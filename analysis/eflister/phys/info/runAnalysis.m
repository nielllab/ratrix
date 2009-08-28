function runAnalysis(dims,whiteStim,whiteResponse,repeatStim,repeatResponses,edges)%nBins)
%dims is nDims x dimLength
[nDims dimLength]=size(dims);

% whiteStimLength=size(whiteStim,2);
% expandedWhiteStim=whiteStim(repmat([1:dimLength]',1,whiteStimLength-dimLength+1)+repmat([0:whiteStimLength-dimLength],dimLength,1));
% filteredWhiteStim=fliplr(dims)*expandedWhiteStim; %nDims x t
% figure
% plot(filteredWhiteStim,'k')
% hold on
% plot(filter(dims,1,whiteStim)+1,'r')
% plot(conv(dims,whiteStim)+2,'b')
% legend({'expanded','filter','conv'})


expansionLength=ceil(1.5*dimLength);
if 0 %do white
    whiteResponseIndex=getIndexedResponses(whiteResponse,1);
    spkTimes=whiteResponseIndex{1}{1};
    spkTimes=spkTimes(spkTimes>=expansionLength);
    trigs=whiteStim(repmat(spkTimes',1,expansionLength)+repmat(1-expansionLength:0,size(spkTimes',1),1));

else
    repeatResponseIndex=getIndexedResponses(repeatResponses,1);


    rptSpkTimes=repeatResponseIndex{1}{1};
    rptSpkTimes=rptSpkTimes(rptSpkTimes>=dimLength);

    trigs=repeatStim(repmat(rptSpkTimes',1,dimLength)+repmat(1-dimLength:0,size(rptSpkTimes',1),1));


end

sta=mean(trigs);
sta=sta/norm(sta);
expandedDims=[zeros(nDims,expansionLength-dimLength) fliplr(dims)];
expandedDims=normRows(expandedDims);

figure



%    expansionLength=ceil(1.5*size(filts,2));
    repeatStimExpanded=repeatStim(repmat([1:length(repeatStim)-expansionLength+1]',1,expansionLength)+repmat(0:expansionLength-1,length(repeatStim)-expansionLength+1,1));
    trigTimes=responseIndex{1};
    trigTimes=trigTimes(trigTimes>=expansionLength)-expansionLength+1;
    trigs = repeatStimExpanded(trigTimes,:);

    figure
    [h c]=hist(trigs,500);
    subplot(4,1,1)
    imagesc(h)
    subplot(4,1,2)
    plot(mean(trigs),'r')
    hold on
    plot([zeros(size(filts,1),expansionLength-size(filts,2)) filts]','k')
    plot([zeros(size(filts,1),expansionLength-size(filts,2)) bestDims]','b')
    subplot(4,1,3)
    c=cov(trigs);
    cNoDiag=c;
    cNoDiag(logical(eye(size(c,1))))=0;
    cNoDiag(logical(eye(size(c,1))))=sum(cNoDiag(:))/(size(c,1)^2-size(c,1));
    imagesc(cNoDiag)
    subplot(4,1,4)
    plot(diag(c))








figure
numFigs=3;
subplot(numFigs,1,1)
plot(sta,'k','LineWidth',2)
hold on
plot(expandedDims','r','LineWidth',2)
legend({'sta','recovered'})
title('recovered filters')

expandedDims=match2nd(sta,expandedDims);

subplot(numFigs,1,2)
plot(sta','k','LineWidth',2)
hold on
plot(expandedDims','r','LineWidth',2)
legend({'sta','recovered'})
title('aligned')

subplot(numFigs,1,3)
startDispInd=ceil(.1*length(whiteStim));
lastDispInd=startDispInd+300;%ceil(.02*length(whiteStim));

%filteredStim=rowConv(dims,whiteStim);
[garbage filteredStim]=orthAndFilt(dims,whiteStim);

plot(whiteStim(startDispInd:lastDispInd),'k','LineWidth',2)
hold on
filteredAligned=match2nd(whiteStim(startDispInd:lastDispInd),filteredStim(:,startDispInd:lastDispInd));
plot([filteredAligned]','r','LineWidth',2)
legend({'stim','filtered'})
title('stim convolved with recovered filters')

%[pSpkGivenStim binnedStim bins]=doHistograms(filteredStim,spkTimes,nBins);




[garbage projectedStim]=orthAndFilt(dims,repeatStim);
priorSpkProb=sum(repeatResponses(:)>0)/numel(repeatResponses);
priorSpkProb
[pSpkGivenStim binnedStim bins]=doHistograms(projectedStim,rptSpkTimes,edges,priorSpkProb,'mid');%nBins);




[garbage filteredRepeat]=orthAndFilt(dims,repeatStim);
[garbage binnedRepeat]=binStim(filteredRepeat,bins);
predictedResponse=lookup(pSpkGivenStim,binnedRepeat);

[garbage filteredSTARepeat]=orthAndFilt(fliplr(sta),repeatStim); %NOTE this flipped is critical -- doesn't work otherwise -- and i don't really know when to flip or not!
[pSpkGivenStimSTA binnedStimSTA binsSTA]=doHistograms(filteredSTARepeat,rptSpkTimes,edges,priorSpkProb,'sta');
[garbage binnedSTARepeat]=binStim(filteredSTARepeat,binsSTA);
predictedResponseSTA=lookup(pSpkGivenStimSTA,binnedSTARepeat);

figure
subplot(5,1,1)
spy(repeatResponses,'k')
axis fill
title('response used to recover filters and nonlinearity')

subplot(5,1,2)
psth=sum(repeatResponses)/size(repeatResponses,1);
plot(psth,'k')
hold on
plot(predictedResponse,'r')
plot(predictedResponseSTA,'b')
legend({'psth','predicted (MI)','predicted(STA)'})
title('prediction on data used to recover filters')

subplot(5,1,3)
[xc lags]=xcorr(predictedResponse,psth,100,'coeff');
plot(lags,xc,'r','LineWidth',2)
hold on
[garbage, scramble]=sort(rand(1,length(predictedResponse)));
plot(lags,xcorr(predictedResponse(scramble),psth,100,'coeff'),'k')

[xc lags]=xcorr(predictedResponseSTA,psth,100,'coeff');
plot(lags,xc,'b','LineWidth',2)
[garbage, scramble]=sort(rand(1,length(predictedResponseSTA)));
plot(lags,xcorr(predictedResponseSTA(scramble),psth,100,'coeff'),'k')

legend('xcorr (MI)','scrambled','xcorr (STA)','scrambled')

subplot(5,1,4)
novelRange=(1000:11000);
[garbage binnedWhite]=binStim(filteredStim,bins);
predictedResponse=lookup(pSpkGivenStim,binnedWhite);
plot(1.5*max(predictedResponse)*whiteResponse(novelRange),'k');
hold on
plot(predictedResponse(novelRange),'r');

[garbage filteredStimSTA]=orthAndFilt(fliplr(sta),whiteStim);
[garbage binnedWhiteSTA]=binStim(filteredStimSTA,binsSTA);
predictedResponseSTA=lookup(pSpkGivenStimSTA,binnedWhiteSTA);
plot(predictedResponseSTA(novelRange),'b');

legend({'actual','predicted (MI)','predicted (STA)'})
title('prediction on novel data')

subplot(5,1,5)
[xc lags]=xcorr(predictedResponse,whiteResponse,100,'coeff');
plot(lags,xc,'r','LineWidth',2)
hold on
[garbage, scramble]=sort(rand(1,length(predictedResponse)));
plot(lags,xcorr(predictedResponse(scramble),whiteResponse,100,'coeff'),'k')


[xc lags]=xcorr(predictedResponseSTA,whiteResponse,100,'coeff');
plot(lags,xc,'b','LineWidth',2)
[garbage, scramble]=sort(rand(1,length(predictedResponseSTA)));
plot(lags,xcorr(predictedResponseSTA(scramble),whiteResponse,100,'coeff'),'k')


legend('xcorr (MI)','scrambled','xcorr (STA)','scrambled')

