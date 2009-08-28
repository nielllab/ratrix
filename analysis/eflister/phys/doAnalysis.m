function doAnalysis
close all
clc
format long g

%pth='C:\Documents and Settings\rlab\Desktop\physAnalysis\data\best.cell.so.far\';
%file = 'best.cell.so.far';

pth = 'C:\Documents and Settings\rlab\Desktop\cell 2tmp\';
file = 'cell 2tmp';

cd(pth)



load(sprintf('%s compiled data.mat',file))

colors=['y','r','g','b'];
sizes=[25, 15, 20, 35];
order=[1,4,3,2];

if false
    figure(1)
    for stimNum=2:3
        subplot(2,2,stimNum-1)
        for specialNum=order
            spy([rptSpecials{stimNum,specialNum} zeros(size(repeatSpikes{stimNum},1),1) unqSpecials{stimNum,specialNum}]',colors(specialNum),sizes(specialNum));
            hold on
        end
        spy([repeatSpikes{stimNum} ones(size(repeatSpikes{stimNum},1),1) uniqueSpikes{stimNum}]','k',3);
        axis fill
        
        subplot(2,2,stimNum+1)
        colorPokes=[repeatPokes{stimNum} ones(size(repeatPokes{stimNum},1),1) uniquePokes{stimNum}]';
        spy(colorPokes,'k',1);
        hold on
        spy(colorPokes==32,'r',1);
        spy(colorPokes==64,'g',1);
        spy(colorPokes==128,'b',1);
        axis fill
    end
end


spks=load(sprintf('%s spks.txt',file));


figure(4)

% do 2-d isi

subplot(2,1,1)
isiRes = 50;
temp = log(diff(spks));
log_spk_diffs = round(isiRes*(temp-min(temp)+1));

twoDisi = sparse([],[],[],max(log_spk_diffs),max(log_spk_diffs),length(spks)-2);
for i=3:length(spks)
    x=log_spk_diffs(i-1);
    y=log_spk_diffs(i-2);
    twoDisi(x,y)=twoDisi(x,y)+1;
end

h=imagesc(twoDisi);
scalePts = [.1 1 3 10 100 500 1000 2000];
scale=round(isiRes*(log(scalePts/1000)-min(temp)+1));
h=get(h);
set(h.Parent,'XTickLabel',scalePts);
set(h.Parent,'XTick',scale);
set(h.Parent,'YTickLabel',scalePts);
set(h.Parent,'YTick',scale);
xlabel('isi 1 (ms)','FontSize',6)
ylabel('isi 2 (ms)','FontSize',6)
axis xy
title(sprintf('%s',file))
set(gca,'FontSize',6)

clear spks;
pack;


%figure(2)
trigSpks=find(repeatSpikes{1});
stims=repeatStimVals{1};

stims=nanmean(stims); %added 08/09, pretty sure this is what i meant...

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

sta=zeros(length(msSilenceRequired)+1,size(triggers,2));

rng=range(mean(triggers));
for silenceNum=1:length(msSilenceRequired)
    sta(silenceNum+1,:)=(silenceNum)*rng+mean(triggers(silences>msSilenceRequired(silenceNum),:));
    names{silenceNum+1}=sprintf('%d ms (%d)',msSilenceRequired(silenceNum),size(triggers(silences>msSilenceRequired(silenceNum),:),1));
end

burstTimes=find(rptSpecials{1,2});
bstTrigs=zeros(length(burstTimes),preTrig+postTrig+1);
numBstTrigs=0;

for bstNum=1:length(burstTimes)
    winStart = burstTimes(bstNum)-preTrig;
    winEnd = burstTimes(bstNum)+postTrig;
    
    if  winStart > 0 && winEnd < length(stims)
        numBstTrigs=1+numBstTrigs;
        newTrig = stims(winStart:winEnd);
        bstTrigs(numBstTrigs,:)=newTrig';
    end
end

bstTrigs=bstTrigs(1:numBstTrigs,:);
sta(1,:)=mean(bstTrigs);
names{1}=sprintf('burst (%d)',numBstTrigs);

%sta(1,:)=mean(triggers(burst',:));
%names{1}=sprintf('burst (%d)',sum(burst));

sta=sta';

%subplot(2,4,1)
figure(8)
plot(-preTrig:postTrig,sta)
hold on
plot(-preTrig:postTrig,repmat(rng*[0:size(sta,2)-1],size(sta,1),1),'k')
xlabel('ms after spike','FontSize',6);

set(gca,'FontSize',6)

title('sta','FontSize',6);

legend(names);


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

%subplot(2,4,2:3)
figure(9)
imagesc([cStim cTrig])
title('cStim and cTrig','FontSize',6);

%subplot(2,4,4)
figure(10)
imagesc(deltaC)
title('deltaC','FontSize',6);

pDims=dims(:,order);
pStims=stimSamp*pDims;
pTrigs=triggers*pDims;

%subplot(2,4,5)
figure(11)
plot(sortNormedEigs,'x')
title('eig vals','FontSize',6);
hold on
eigs=diag(eigs);
%plot(eigs(order),'ro')
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

%plot(klS2T,'bo')
plot(klT2S,'go')

[sortS2T orderS2T]=sort(klS2T);
[sortT2S orderT2S]=sort(klT2S);
orderS2T=fliplr(orderS2T);
orderT2S=fliplr(orderT2S);

%legend('normalized by stim variances','unnormalized','KL stim/trig','KL trig/stim');
legend('normalized by stim variances','KL trig/stim');

doKL=1;
if doKL
    newOrder=orderT2S;
    pDims=pDims(:,newOrder);
    pStims=pStims(:,newOrder);
    pTrigs=pTrigs(:,newOrder);
end

%subplot(2,4,6:7)
figure(12)
mrange=max(max(pDims(:,1:numDims)))-min(min(pDims(:,1:numDims)));
plot(pDims(:,1:numDims)+repmat(mrange*(0:numDims-1),size(pDims,1),1));
title('relevant dims','FontSize',6);

clear names;
for i=1:numDims
    names{i} = sprintf('dim %d',i);
end
set(gca,'FontSize',6)
%legend(names);
hold on
plot(repmat(mrange*(0:numDims-1),size(pDims,1),1),'k')
thisSTA=mean(triggers);
thisSTA=thisSTA-mean(thisSTA);
thisSTA=thisSTA/norm(thisSTA);
plot(repmat(thisSTA',1,numDims)+repmat(mrange*(0:numDims-1),size(pDims,1),1),'k')
XLim([0-length(thisSTA)/3 length(thisSTA)+length(thisSTA)/3]);

%subplot(2,4,8)
figure(13)
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
end

function thisOut = nanmean (theseStims)
theseNans=isnan(theseStims);
noNans=theseNans(:,1:end-1);
if any(noNans)
    error('wrong nans')
end
nanInds=find(diff(theseNans(:,end)));
switch length(nanInds)
    case 0
        thisOut = mean(theseStims,2);
    case 1
        thisOut = [mean(theseStims(1:nanInds,:),2); mean(theseStims(nanInds+1:end,1:end-1),2)];
    otherwise
        error('wrong nans')
end
if any(isnan(thisOut)) || length(thisOut)~=size(theseStims,1)
    error('wrong nans')
end
end