function doStimReconstruction(repeatResponses,repeatStim)

 figure

    repeatResponseIndex=getIndexedResponses(repeatResponses,1);

    expansionLength=ceil(1.5*size(filt,2));
    repeatStimExpanded=repeatStim(repmat([1:length(repeatStim)-expansionLength+1]',1,expansionLength)+repmat(0:expansionLength-1,length(repeatStim)-expansionLength+1,1));
    trigTimes=repeatResponseIndex{1}{1};
    trigTimes=trigTimes(trigTimes>=expansionLength)-expansionLength+1;
    trigs = repeatStimExpanded(trigTimes,:);

    % dimLength=floor(1.5*size(filt,1));
    % repeatResponseIndex=getIndexedResponses(repeatResponses,1);
    % rptSpkTimes=repeatResponseIndex{1}{1};
    % rptSpkTimes=rptSpkTimes(rptSpkTimes>=dimLength);
    %
    % trigs=repeatStim(repmat(rptSpkTimes',1,dimLength)+repmat(1-dimLength:0,size(rptSpkTimes',1),1));

    rptQuietTimes=repeatResponseIndex{1}{2};
    rptQuietTimes=rptQuietTimes(rptQuietTimes>=expansionLength)-expansionLength+1;%>=dimLength);
    numQuietToUse=3*length(repeatResponseIndex{1}{1});
    pctQuietToUse=numQuietToUse/length(rptQuietTimes);
    rptQuietTimes=rptQuietTimes(rand(1,length(rptQuietTimes))<pctQuietToUse);
    quiets=repeatStimExpanded(rptQuietTimes,:);%repeatStim(repmat(rptQuietTimes',1,dimLength)+repmat(1-dimLength:0,size(rptQuietTimes',1),1));

    numReconstructBins=500;
    [hTrig c]=hist(trigs,numReconstructBins);
    hTrig=hTrig/size(trigs,1);

    hQuiet =hist(quiets,c);
    hQuiet=hQuiet/size(quiets,1);

    subplot(5,1,1)
    imagesc(hTrig)
    subplot(5,1,2)
    imagesc(hQuiet)

    dimLength=expansionLength;
    rptStimReconstruct=zeros(numReconstructBins,length(repeatStim));
    resps=sum(repeatResponses);
    for i=dimLength:length(repeatStim)
        rptStimReconstruct(:,i-dimLength+1:i)=rptStimReconstruct(:,i-dimLength+1:i)+resps(i)*hTrig+(size(repeatResponses,1)-resps(i))*hQuiet;
    end
    means=mean(rptStimReconstruct);
    maxes=max(rptStimReconstruct);
    subplot(5,1,3)
    imagesc(rptStimReconstruct)
    subplot(5,1,4)
    plot(normalize(repeatStim),'k')
    hold on
    %plot(normalize(means),'r')
    plot(normalize(maxes),'b')
    legend({'stim','mean p(stim|resp)','max p(stim|resp)'})

    subplot(5,1,5)

    [xc lags]=xcorr(maxes,repeatStim,100,'coeff');
    plot(lags,xc,'k','LineWidth',2)
    hold on
    [garbage, scramble]=sort(rand(1,length(maxes)));
    plot(lags,xcorr(maxes(scramble),repeatStim,100,'coeff'),'b')
    legend('xcorr','scrambled')