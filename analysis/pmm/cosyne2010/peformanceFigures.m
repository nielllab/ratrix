





%% get data
subjects={'231','234'}; s=1; % all colin, many target contrasts on 12, or many flanker onctrasts on 15, or joint contrast on colinear on 16
dateRange= [pmmEvent('231&234-jointSweep')+1 pmmEvent('231-test200msecDelay')]; filter{1}.type='16';
conditionType='allBlockIDs';
factor='targetContrast';  % at actually both, but we will show target Contrast



d=getSmalls('231',[dateRange]);
d=removeSomeSmalls(d,isnan(d.blockID));

%%
figure;
subplot(1,2,1);
doPlotPercentCorrect(d)
d=addYesResponse(d);


%% search for a good region
close all
bids=unique(d.blockID)
blockValues=d.blockID(diff(d.blockID)~=0);
trials=d.trialNumber(diff(d.blockID)~=0);
candTrials=[];
whichBlockDouble=[];
for i=1:length(bids)
    theseBlocks=find(blockValues==bids(i));
    theseTrials=trials(theseBlocks);
    lowBlocksBetween=diff(theseBlocks)<7;
    candTrials=[candTrials theseTrials(lowBlocksBetween)];
    whichBlockDouble=[whichBlockDouble i(ones(1,length(candTrials)))];
end


before=2000; after=2000;
for i=1:length(candTrials)
    outOfRange=d.trialNumber<candTrials(i)-before | d.trialNumber>candTrials(i)+after;
    x=removeSomeSmalls(d,outOfRange);
    figure; doPlotPercentCorrect(x)
    where=find(x.blockID==whichBlockDouble(i));
    plot(where,0.6*ones(1,length(where)),'r.')
end

%%
close all
n=2000;
startTrials=d.trialNumber(1):n:d.trialNumber(end)-n;
startTrials=[startTrials startTrials+n/2];
startTrials=[206000 245000 248000];

colors=jet(20);
for i=1:length(startTrials)
    outOfRange=d.trialNumber<startTrials(i) | d.trialNumber>startTrials(i)+n;
    x=removeSomeSmalls(d,outOfRange);
    for j=unique(x.blockID)
        if  sum(x.blockID==j)>150
            figure; doPlotPercentCorrect(x)
            where=find(x.blockID==j);
            plot(where,mean(x.correct(where))*ones(1,length(where)),'.','color',colors(j,:))
            title(startTrials(i))
       end
    end
end

%%
outOfRange=d.trialNumber<206100 | d.date>733996;
x=removeSomeSmalls(d,outOfRange);
figure; doPlotPercentCorrect(x,[],100,1)
set(gca,'ytick',[0.5 1],'yTickLabel',{'0.5','1'});
settings=[];
settings.LineWidth=3;
settings.AxisLineWidth=3;
settings.textObjectFontSize=12;
settings.fontSize=20;
cleanUpFigure(gcf,settings)
set(gcf,'Position',[50 50 1150 400])

%%

sweptImageParameters={'flankerOrientation','targetOrientation','flankerPosAngle','targetContrast','flankerContrast'}; % why does contrast have to be last?
or=-pi/8;
%sweptImageValues={or,or,or,[0 0.5],0.75};
%borderColor=[.9 0 0; .9 0 0];
sweptImageValues={or,or,or,[0 0.75],0};
borderColor=[0 0 .9; 0 0 .9];
antiAliasing=true;
useSymbolicFlanker=false;
[images]=getStimSweep(sweptImageParameters,sweptImageValues,borderColor,[],'column',false,antiAliasing,useSymbolicFlanker);

figure; montage(images,'DisplayRange',[0,255]);


%%

p=detectionModel
p=p.loadDataFromServer({'234'});

%% ROC
arrowsOn=false;
figure; p.plotROC([],[],'subject',arrowsOn)
xlabel(''); ylabel('');
set(gca,'xtickLabel',[0 1],'xtick',[0 1],'ytickLabel',[0 1],'ytick',[0 1])
settings.box='on'
cleanUpFigure(gcf,settings)
%% get blockstats
[seg_stats seg_CI seg_names seg_params]=getFlankerStats(subjects(s),'allBlockSegments',{'yes'},filter,dateRange);
[seg_stats seg_CI seg_names seg_params]=getFlankerStats(subjects(s),'allBlockSegments',{'pctCorrect'},filter,dateRange);
%%

blockID=seg_params.factors.blockID;
bIDs=unique(blockID)
tcs=seg_params.factors.targetContrast;
for i=1:length(bIDs)
    %get rid of the 0 contrast in the blocked info
 tcsPerBlockID(i)=max(tcs(blockID==bIDs(i)));
 tcs(blockID==bIDs(i))=tcsPerBlockID(i);
end
fcs=seg_params.factors.flankerContrast;
tc=unique(tc); 
fc=unique(fc);
numTc=length(tc);
numFc=length(fc);
%% TC
figure; hold on
mn=[];
for t=1:numTc
    fw=0.03;
    w=find(fcs==0 & tcs==tc(t));
    mn(t)=mean(seg_stats(w));
    st=std(seg_stats(w));
    fill(tc(t)+fw*[1 1 -1 -1],mn(t)+st*[-1 1 1 -1],'c','edgeColor',[1 1 1],'faceColor',[.6 .8 1]);
end
w=find(fcs==0 & tcs>0);
offset=(0.05*w./max(w))-0.025;%by time
plot(tcs(w)+offset,seg_stats(w),'.k')
plot(tc,mn,'b')
set(gca,'xtickLabel',[0 tc],'xtick',[0 tc],'ytickLabel',[.5 1],'ytick',[.5 1])
axis([0 1.1 0 1])
settings=[];
settings.LineWidth=3;
settings.AxisLineWidth=3;
settings.fontSize=20;
cleanUpFigure(gcf,settings)
set(gcf,'Position',[50 50 400 300])

%% FC
figure; hold on
mn=[];
for f=1:numFc
    w=find(tcs==1 & fcs==fc(f));
    mn(f)=mean(seg_stats(w));
    st=std(seg_stats(w));
    fill(fc(f)+fw*[1 1 -1 -1],mn(f)+st*[-1 1 1 -1],'c','edgeColor',[1 1 1],'faceColor',[1 .8 .8]);
end
w=find(tcs==1);
offset=(0.05*w./max(w))-0.025;%by time
plot(fcs(w)+offset,seg_stats(w),'.k')
plot(fc,mn,'r')
set(gca,'xtickLabel',fc,'xtick',fc,'ytickLabel',[.5 1],'ytick',[.5 1])
axis([-0.1 1.1 0 1])
settings=[];
settings.LineWidth=3;
settings.AxisLineWidth=3;
settings.fontSize=20;
cleanUpFigure(gcf,settings)
set(gcf,'Position',[50 50 400 300])



%%  setup for pct triggered average

nSteps=[-1:0]; % 4 back 0 fwd
pad=diff(minmax(nSteps));
tcHist=nan(length(tcs)-pad,length(nSteps));
fcHist=nan(length(tcs)-pad,length(nSteps)); 
for i=1:length(nSteps)
tcHist(:,i)=tcs(1-min(nSteps)+nSteps(i):end+nSteps(i)-max(nSteps));
fcHist(:,i)=fcs(1-min(nSteps)+nSteps(i):end+nSteps(i)-max(nSteps));
end
adjTcs=tcs(1-min(nSteps):end);
adjFcs=fcs(1-min(nSteps):end);
adjCors=seg_stats(1-min(nSteps):end);
mnTc=mean(adjTcs)
mnFc=mean(adjFcs)
mnCor=mean(adjCors)
%% INCOMPLETE
%weightedHist=fcHist.*repmat(adjCors',1,length(nSteps));
weightedHist=tcHist(:,end-1).*adjCors';
% m = bootstrp(100, @mean,weightedHist);
figure; hold on
plot(tc,mnTc*mnCor([1 1 1 1]),'k-')
for t=1:numTc
    w=find(fcs==0 & tcs==tc(t));
    weightedHist(w,:)
   %
end


%%  Conditioned on one block before is not that interesting
figure; hold on
for t=1:numTc
    for f=1:numFc
        subplot(numFc,numTc,(t-1)*numFc+f); hold on;
        w=find(fcs==fc(f) & tcs==tc(t));
        w(w==1)=[];  %remove the 1st so that w-1 is always exists
        plot(tcs(w-1),seg_stats(w),'.')
    end
end


