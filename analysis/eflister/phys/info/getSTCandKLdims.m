function [stcDims klDims] = getSTCandKLdims

file = 'g02';

load(sprintf('%s compiled data',file))



    trigSpks=find(repeatSpikes{1});
    stims=repeatStimVals{1};
    
    smooth=1;
    if smooth
        %windowSize=19;
        windowSize=16;
        stims=filter(bartlett(windowSize),1,stims);
    end
    
    stims=stims-mean(stims);

    preTrig = 140;
    postTrig = -15;
    
    msSilenceRequired = [0 1 5 10 50 75 100];
    %burstMsSilenceRequired = 100;
    %burstMsFollowerRequired = 5;
    
    silences = zeros(1,length(trigSpks));
    %burst = false(1,length(trigSpks));
    triggers = zeros(length(trigSpks),preTrig+postTrig+1);
    stimSamp = zeros(length(trigSpks),preTrig+postTrig+1);

    totalSpikes=0;
    totalStimSamps=0;
    for spikeNum=2:length(trigSpks)-1
        winStart = trigSpks(spikeNum)-preTrig;
        winEnd = trigSpks(spikeNum)+postTrig;
        
        if  winStart > 0 && winEnd < length(stims)
            
            newTrig = stims(winStart:winEnd);

            if ~any(isnan(newTrig))

                totalSpikes=totalSpikes+1;
                triggers(totalSpikes,:) = newTrig';  
                silences(totalSpikes) = trigSpks(spikeNum)-trigSpks(spikeNum-1);
                %burst(totalSpikes) = silences(totalSpikes) > burstMsSilenceRequired && trigSpks(spikeNum+1)-trigSpks(spikeNum) < burstMsFollowerRequired;
               
                sampDone = 0;
                while ~sampDone
                    stimSampStart=ceil(rand*(length(stims)-preTrig-postTrig));
                    stimSampEnd=stimSampStart+preTrig+postTrig;               
                    if stimSampStart > 0 && stimSampEnd < length(stims)
                        newStimSamp = stims(stimSampStart:stimSampEnd);
                        if any(isnan(newStimSamp))
                            'error 1 - got a nan'
                        else
                            sampDone = 1;
                        end
                    end
                end
                
                totalStimSamps=totalStimSamps+1;        
                stimSamp(totalStimSamps,:) = newStimSamp';
            else
                'error 2 - got a nan'
            end
            
            
        end
    end    
    
    
    stimSamp=stimSamp(1:totalStimSamps,:);
    triggers=triggers(1:totalSpikes,:);
    

    
    
    msIso=50;
    %numDims=22;
    %numDims=13;
    numDims=size(stimSamp,2);
    triggers=triggers(silences>msIso,:);
    
    %do stc
    cStim=cov(stimSamp);
    cTrig=cov(triggers);
    deltaC=cTrig-cStim;
    [dims,eigs]=eig(deltaC);     
        
    stimSamp=stimSamp(1:size(triggers,1),:);
    clear('repeatStimVals','repeatTimes','stims','uniqueTimes','uniqueStimVals');
    pack
    
    stimVars=var(stimSamp*dims);
    normedEigs=diag(eigs)./stimVars';

    [sortNormedEigs,order]=sort(abs(normedEigs));
    sortNormedEigs=flipud(sortNormedEigs);
    order=flipud(order);
    
    subplot(2,4,2:3)
    imagesc([cStim cTrig])
    title('cStim and cTrig','FontSize',6);

    subplot(2,4,4)
    imagesc(deltaC)
    title('deltaC','FontSize',6);
    
    pDims=dims(:,order);
    pStims=stimSamp*pDims;
    pTrigs=triggers*pDims;        

    subplot(2,4,5)
    plot(sortNormedEigs,'x')
    title('eig vals','FontSize',6);
    hold on
    eigs=diag(eigs);
    plot(eigs(order),'ro')
    set(gca,'FontSize',6) 
    
    numBins=100;
    klS2T=zeros(1,length(order));
    klT2S=zeros(1,length(order));
    stimProbs=zeros(length(order),numBins);
    trigProbs=zeros(length(order),numBins);
    for i=1:length(order)
        [stimCounts bins]=hist(pStims(1:size(triggers,1),i),numBins);
        trigCounts = hist(pTrigs(:,i),bins);
        stimProbs(i,:) = (stimCounts+1)/sum(stimCounts+1);
        trigProbs(i,:) = (trigCounts+1)/sum(trigCounts+1);
        klS2T(i)=sum(stimProbs(i,:).*log(stimProbs(i,:)./trigProbs(i,:)));
        klT2S(i)=sum(trigProbs(i,:).*log(trigProbs(i,:)./stimProbs(i,:)));
    end

    plot(klS2T,'bo')
    plot(klT2S,'go')
    
    [sortS2T orderS2T]=sort(klS2T);
    [sortT2S orderT2S]=sort(klT2S);
    orderS2T=fliplr(orderS2T);
    orderT2S=fliplr(orderT2S);
        
    legend('normalized by stim variances','unnormalized','KL stim/trig','KL trig/stim');           
    
    stcDims = pDims(:,1:2)';
    
    newOrder=orderT2S;
    pDims=pDims(:,newOrder);
    pStims=pStims(:,newOrder);
    pTrigs=pTrigs(:,newOrder);
    
    klDims = pDims(:,1:2)';
    
    subplot(2,4,6:7)
    range=max(max(pDims(:,1:numDims)))-min(min(pDims(:,1:numDims)));
    plot(pDims(:,1:numDims)+repmat(range*(0:numDims-1),size(pDims,1),1));
    title('relevant dims','FontSize',6);

    clear names;
    for i=1:numDims
        names{i} = sprintf('dim %d',i);
    end
    set(gca,'FontSize',6)    
    %legend(names);
    hold on
    plot(repmat(range*(0:numDims-1),size(pDims,1),1),'k')
    thisSTA=mean(triggers);
    thisSTA=thisSTA-mean(thisSTA);
    thisSTA=thisSTA/norm(thisSTA);
    plot(repmat(thisSTA',1,numDims)+repmat(range*(0:numDims-1),size(pDims,1),1),'k')
    XLim([0-length(thisSTA)/3 length(thisSTA)+length(thisSTA)/3]);

    subplot(2,4,8)
    h2=plot(pTrigs(:,1),pTrigs(:,2),'r.','MarkerSize',1);
    hold on
    h1=plot(pStims(:,1),pStims(:,2),'k.','MarkerSize',1);
    title('projections','FontSize',6);
    set(gca,'FontSize',6)        
    legend([h1(1) h2(1)],'stims','triggers')
    
    figure(3)
    toPlot=5;
    subplot(toPlot+1,1,1)
    hist([reshape(stimSamp(1:size(triggers,1),:),size(triggers,1)*size(triggers,2),1) ...
          reshape(triggers,size(triggers,1)*size(triggers,2),1)], ...
         50);
    legend('stims','triggers');
    title('stim and trigger distributions');
     
    for i=1:toPlot
        subplot(toPlot+1,1,i+1)
        hist([pStims(1:size(triggers,1),i) pTrigs(:,i)],50);
    end