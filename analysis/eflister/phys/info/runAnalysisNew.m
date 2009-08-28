%function runAnalysis(dims,whiteStim,whiteResponse,repeatStim,repeatResponses,edges)%nBins)


%function scratch
close all
clear all
clc
format long g

if 0 %fake data
    [repeatStim,repeatResponses,uniqueStims,uniqueResponses,whiteStim,whiteResponse,filt]=simulatedData;
else %real data
    load('g02 compiled data');

    repeatResponses=[full(repeatSpikes{3})]';
    repeatStim=mean([repeatStimVals{3}]');

    whiteResponse=[full(repeatSpikes{1})]';
    whiteStim=[repeatStimVals{1}]';
    smooth=0;
    if smooth
        %windowSize=19;
        windowSize=16;
        whiteStim=filter(bartlett(windowSize),1,whiteStim);
        repeatStim=filter(bartlett(windowSize),1,repeatStim);
    end
    whiteStim=whiteStim-mean(whiteStim);
    repeatStim=repeatStim-mean(repeatStim);
    
    filt=zeros(1,200);
    
    clear('repeatStimVals','repeatTimes','stims','uniqueTimes','uniqueStimVals','repeatSpikes','uniqueSpikes');
    'data loaded'
end

if 0
    doStimReconstruction(repeatResponses,repeatStim);

end


numMIDims=2;
nBins=50^numMIDims;
totalMI=1;
numRpts=size(repeatResponses,1);
[bestDims,edges]=doMID(totalMI,repeatStim,repeatResponses,[filt;zeros(numMIDims-1,length(filt))],nBins,numRpts);
%taking too long to run on whitestim (has to refilter the data every call), and i think i
%get bad answers when running on somethign short like repeatstim

%runAnalysis(normRows(bestDims),whiteStim,whiteResponse,repeatStim,repeatResponses,edges);

[stcDims klDims] = getSTCandKLdims();
stcDims=normRows(stcDims);
klDims=normRows(klDims);

dims=normRows(bestDims);












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


expansionLength=ceil(1*dimLength);
if 1 %do white
    whiteResponseIndex=getIndexedResponses(whiteResponse,1);
    spkTimes=whiteResponseIndex{1}{1};
    spkTimes=spkTimes(spkTimes>=expansionLength);
    trigs=whiteStim(repmat(spkTimes',1,expansionLength)+repmat(1-expansionLength:0,size(spkTimes',1),1));


    repeatResponseIndex=getIndexedResponses(repeatResponses,1);


    rptSpkTimes=repeatResponseIndex{1}{1};
    rptSpkTimes=rptSpkTimes(rptSpkTimes>=dimLength);

else
    trigs=repeatStim(repmat(rptSpkTimes',1,dimLength)+repmat(1-dimLength:0,size(rptSpkTimes',1),1));


end

sta=mean(trigs);
sta=sta/norm(sta);
expandedDims=[zeros(nDims,expansionLength-dimLength) fliplr(dims)];
expandedDims=normRows(expandedDims);





%    expansionLength=ceil(1.5*size(filts,2));
    repeatStimExpanded=repeatStim(repmat([1:length(repeatStim)-expansionLength+1]',1,expansionLength)+repmat(0:expansionLength-1,length(repeatStim)-expansionLength+1,1));
    trigTimes=repeatResponseIndex{1}{1};
    trigTimes=trigTimes(trigTimes>=expansionLength)-expansionLength+1;
    trigs = repeatStimExpanded(trigTimes,:);

    filts=dims
    
    figure
    [h c]=hist(trigs,500);
    subplot(4,1,1)
    imagesc(h) %not working, don't know why
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
[pSpkGivenStim binnedStim bins]=doHistograms(projectedStim,rptSpkTimes,edges,priorSpkProb,'mid',numRpts);%nBins);




[garbage filteredRepeat]=orthAndFilt(dims,repeatStim);
[garbage binnedRepeat]=binStim(filteredRepeat,bins);
predictedResponse=lookup(pSpkGivenStim,binnedRepeat);

[garbage filteredSTARepeat]=orthAndFilt(fliplr(sta),repeatStim); %NOTE this flipped is critical -- doesn't work otherwise -- and i don't really know when to flip or not!
[pSpkGivenStimSTA binnedStimSTA binsSTA]=doHistograms(filteredSTARepeat,rptSpkTimes,edges,priorSpkProb,'sta',numRpts);
[garbage binnedSTARepeat]=binStim(filteredSTARepeat,binsSTA);
predictedResponseSTA=lookup(pSpkGivenStimSTA,binnedSTARepeat);


[garbage filteredSTC1Repeat]=orthAndFilt(fliplr(stcDims(1,:)),repeatStim); %still fliplr?
[garbage filteredSTC2Repeat]=orthAndFilt(fliplr(stcDims(1:2,:)),repeatStim);
[garbage filteredKL1Repeat]=orthAndFilt(fliplr(klDims(1,:)),repeatStim); %still fliplr?
[garbage filteredKL2Repeat]=orthAndFilt(fliplr(klDims(1:2,:)),repeatStim);

[pSpkGivenStimSTC1 binnedStimSTC1 binsSTC1]=doHistograms(filteredSTC1Repeat,rptSpkTimes,edges,priorSpkProb,'stc1',numRpts);
[pSpkGivenStimSTC2 binnedStimSTC2 binsSTC2]=doHistograms(filteredSTC2Repeat,rptSpkTimes,edges,priorSpkProb,'stc2',numRpts);
[pSpkGivenStimKL1 binnedStimKL1 binsKL1]=doHistograms(filteredKL1Repeat,rptSpkTimes,edges,priorSpkProb,'kl1',numRpts);
[pSpkGivenStimKL2 binnedStimKL2 binsKL2]=doHistograms(filteredKL2Repeat,rptSpkTimes,edges,priorSpkProb,'kl2',numRpts);

[garbage binnedSTC1Repeat]=binStim(filteredSTC1Repeat,binsSTC1);
[garbage binnedSTC2Repeat]=binStim(filteredSTC2Repeat,binsSTC2);
[garbage binnedKL1Repeat]=binStim(filteredKL1Repeat,binsKL1);
[garbage binnedKL2Repeat]=binStim(filteredKL2Repeat,binsKL2);

predictedResponseSTC1=lookup(pSpkGivenStimSTC1,binnedSTC1Repeat);
predictedResponseSTC2=lookup(pSpkGivenStimSTC2,binnedSTC2Repeat);
predictedResponseKL1=lookup(pSpkGivenStimKL1,binnedKL1Repeat);
predictedResponseKL2=lookup(pSpkGivenStimKL2,binnedKL2Repeat);


figure
subplot(5,1,1)
spy(repeatResponses,'k')
axis fill
title('response used to recover filters and nonlinearity')

subplot(5,1,2)
psth=sum(repeatResponses)/size(repeatResponses,1);


psth=psth/norm(psth);
predictedResponse=predictedResponse/norm(predictedResponse);
predictedResponseSTA=predictedResponseSTA/norm(predictedResponseSTA);
predictedResponseSTC1=predictedResponseSTC1/norm(predictedResponseSTC1);
predictedResponseSTC2=predictedResponseSTC2/norm(predictedResponseSTC2);
predictedResponseKL1=predictedResponseKL1/norm(predictedResponseKL1);
predictedResponseKL2=predictedResponseKL2/norm(predictedResponseKL2);

plot(psth,'k')
hold on
plot(predictedResponse,'r')
plot(predictedResponseSTA,'b')
plot(predictedResponseSTC1,'g')
plot(predictedResponseSTC2,'y')
plot(predictedResponseKL1,'m')
plot(predictedResponseKL2,'c')
legend({'psth','predicted (MI)','predicted(STA)','predicted(STC1)','predicted(STC2)','predicted(KL1)','predicted(KL2)'})
title('prediction on data used to recover filters')

xcovLen=400;

subplot(5,1,3)
[xc lags]=xcov(predictedResponse,psth,xcovLen,'coeff');
plot(lags,xc,'r','LineWidth',2)
hold on
[garbage, scramble]=sort(rand(1,length(predictedResponse)));
plot(lags,xcov(predictedResponse(scramble),psth,xcovLen,'coeff'),'k')

[xc lags]=xcov(predictedResponseSTA,psth,xcovLen,'coeff');
plot(lags,xc,'b','LineWidth',2)
[garbage, scramble]=sort(rand(1,length(predictedResponseSTA)));
plot(lags,xcov(predictedResponseSTA(scramble),psth,xcovLen,'coeff'),'k')

[xc lags]=xcov(predictedResponseSTC1,psth,xcovLen,'coeff');
plot(lags,xc,'g','LineWidth',2)
[xc lags]=xcov(predictedResponseSTC2,psth,xcovLen,'coeff');
plot(lags,xc,'y','LineWidth',2)
[xc lags]=xcov(predictedResponseKL1,psth,xcovLen,'coeff');
plot(lags,xc,'m','LineWidth',2)
[xc lags]=xcov(predictedResponseKL2,psth,xcovLen,'coeff');
plot(lags,xc,'c','LineWidth',2)

legend('xcov (MI)','scrambled','xcov (STA)','scrambled','xcov (STC1)','xcov (STC2)','xcov (KL1)','xcov (KL2)')

subplot(5,1,4)
novelRange=(1000:11000);
[garbage binnedWhite]=binStim(filteredStim,bins);
predictedResponse=lookup(pSpkGivenStim,binnedWhite);
%plot(1.5*max(predictedResponse)*whiteResponse(novelRange),'k');
whiteResponse=whiteResponse/norm(whiteResponse);
plot(whiteResponse(novelRange),'k')
hold on
predictedResponse=predictedResponse/norm(predictedResponse);
plot(predictedResponse(novelRange),'r');

[garbage filteredStimSTA]=orthAndFilt(fliplr(sta),whiteStim);
[garbage binnedWhiteSTA]=binStim(filteredStimSTA,binsSTA);
predictedResponseSTA=lookup(pSpkGivenStimSTA,binnedWhiteSTA);
predictedResponseSTA=predictedResponseSTA/norm(predictedResponseSTA);
plot(predictedResponseSTA(novelRange),'b');


[garbage filteredStimSTC1]=orthAndFilt(fliplr(stcDims(1,:)),whiteStim);
[garbage binnedWhiteSTC1]=binStim(filteredStimSTC1,binsSTC1);
predictedResponseSTC1=lookup(pSpkGivenStimSTC1,binnedWhiteSTC1);
predictedResponseSTC1=predictedResponseSTC1/norm(predictedResponseSTC1);
plot(predictedResponseSTC1(novelRange),'g');

[garbage filteredStimSTC2]=orthAndFilt(fliplr(stcDims(1:2,:)),whiteStim);
[garbage binnedWhiteSTC2]=binStim(filteredStimSTC2,binsSTC2);
predictedResponseSTC2=lookup(pSpkGivenStimSTC2,binnedWhiteSTC2);
predictedResponseSTC2=predictedResponseSTC2/norm(predictedResponseSTC2);
plot(predictedResponseSTC2(novelRange),'y');

[garbage filteredStimKL1]=orthAndFilt(fliplr(klDims(1,:)),whiteStim);
[garbage binnedWhiteKL1]=binStim(filteredStimKL1,binsKL1);
predictedResponseKL1=lookup(pSpkGivenStimKL1,binnedWhiteKL1);
predictedResponseKL1=predictedResponseKL1/norm(predictedResponseKL1);
plot(predictedResponseKL1(novelRange),'m');

[garbage filteredStimKL2]=orthAndFilt(fliplr(klDims(1:2,:)),whiteStim);
[garbage binnedWhiteKL2]=binStim(filteredStimKL2,binsKL2);
predictedResponseKL2=lookup(pSpkGivenStimKL2,binnedWhiteKL2);
predictedResponseKL2=predictedResponseKL2/norm(predictedResponseKL2);
plot(predictedResponseKL2(novelRange),'c');


legend({'actual','predicted (MI)','predicted (STA)','predicted(STC1)','predicted(STC2)','predicted(KL1)','predicted(KL2)'})
title('prediction on novel data')

subplot(5,1,5)
[xc lags]=xcov(predictedResponse,whiteResponse,xcovLen,'coeff');
plot(lags,xc,'r','LineWidth',2)
hold on
[garbage, scramble]=sort(rand(1,length(predictedResponse)));
plot(lags,xcov(predictedResponse(scramble),whiteResponse,xcovLen,'coeff'),'k')


[xc lags]=xcov(predictedResponseSTA,whiteResponse,xcovLen,'coeff');
plot(lags,xc,'b','LineWidth',2)
[garbage, scramble]=sort(rand(1,length(predictedResponseSTA)));
plot(lags,xcov(predictedResponseSTA(scramble),whiteResponse,xcovLen,'coeff'),'k')


[xc lags]=xcov(predictedResponseSTC1,whiteResponse,xcovLen,'coeff');
plot(lags,xc,'g','LineWidth',2)
[xc lags]=xcov(predictedResponseSTC2,whiteResponse,xcovLen,'coeff');
plot(lags,xc,'y','LineWidth',2)
[xc lags]=xcov(predictedResponseKL1,whiteResponse,xcovLen,'coeff');
plot(lags,xc,'m','LineWidth',2)
[xc lags]=xcov(predictedResponseKL2,whiteResponse,xcovLen,'coeff');
plot(lags,xc,'c','LineWidth',2)

legend('xcov (MI)','scrambled','xcov (STA)','scrambled','xcov (STC1)','xcov (STC2)','xcov (KL1)','xcov (KL2)')

