% qDoesRtEffectPerformance

% basic parameters
dateRange= [pmmEvent('231&234-jointSweep')+1 pmmEvent('231-test200msecDelay')];
subjects={'231','234'}

%define filters
filters=[];
f1.type='16';
switch 3
    case 1 % all
        filters{1}={f1};
    case 2
        mid.type='responseSpeedPercentile';
        mid.parameters.range=[.25 .75];
        fast.type='responseSpeedPercentile';
        fast.parameters.range=[0 .25];
        slow.type='responseSpeedPercentile';
        slow.parameters.range=[.75 1];
        filters{1}={f1,mid};
        filters{2}={f1,fast};
        filters{3}={f1,slow};
    case 3 %sliding window
        filters{1}={f1}; % start with all
               
        % add windows
        window=0.25;  % quartile
        numFilts=10;%4;   %4 causes no overlap, 4 or 10
        base=linspace(0,1-window,numFilts);
        for i=2:numFilts+1
            w.type='responseSpeedPercentile';
            w.parameters.range=base(i-1)+[0 window];
            filters{i}={f1,w};
        end
end

% get all the data and save it in a struct array
for i=1:length(subjects)
    for j=1:length(filters)
        [x.stats x.CI x.names x.params]=getFlankerStats(subjects(i),'allBlockIDs',{'pctCorrect','hits','CRs','RT'},filters{j},dateRange);
        data(i,j).hit=x.params.raw.numHits./(x.params.raw.numHits + x.params.raw.numMisses);
        data(i,j).fa=x.params.raw.numFAs./(x.params.raw.numFAs + x.params.raw.numCRs);
        data(i,j).pctCorrect=reshape(x.stats(1,:,1),[],1);
        data(i,j).pctCorrectCI=reshape(x.CI(1,:,1,:),[],2);
        reactionTimes{i,j}=x.params.RT;
    end
end

% save some xtra params
tcs=x.params.factors.targetContrast;
fcs=x.params.factors.flankerContrast;
numTc=length(unique(tcs));
numFilts=length(filters);
%% plot performance
close all
tc=.5; fc=1;
condInd=find(tcs==tc & fcs==fc); % choose a condition
colors=flipud(cool(numFilts-1));
for i=1:length(subjects)
    figure; hold on;
    set(gcf,'Position',[10 600 500 500])
    title([subjects{i} ])
    plot([0 1],[.5 .5],'k');
        axis([0 1 0 1])
    axis square
    set(gca,'xtick',[0 1],'ytick',[.5 1])
    set(gca,'xticklabel',{'fast','slow'},'yticklabel',{'50%','100%'})
    for j=2:numFilts
        windowCtr=mean(filters{j}{2}.parameters.range);
        if ismember(windowCtr,[0,.25,.5,.75]+1/8)
            color=[0 0 0];
            color=colors(j-1,:);
        else
            color=[.8 .8 .8];

        end
        plot(windowCtr,data(i,j).pctCorrect(condInd),'o','color',color); hold on
        plot(windowCtr([1 1]),data(i,j).pctCorrectCI(condInd,:),'-','color',color);
    end
    xlabel('response time (percentile)')
    ylabel('% correct')
    settings=[];settings.box='on';
    text(.05,.1,sprintf('C_T = %2.2f\nC_F = %2.2f',tc,fc))
    cleanUpFigure(gcf,settings)
end

%%
colors=flipud(cool(numFilts-1));
for i=1:length(subjects)
    figure; hold on;
    set(gcf,'Position',[10 600 500 500])
    title([subjects{i} ])
    plot([0 1],[0 1],'k');
    axis square
    set(gca,'xtick',[],'ytick',[])
    for j=[2:numFilts]  %[2 numFilts] choose all or first last
            plot(data(i,j).fa,data(i,j).hit,'.','color',colors(j-1,:));
            plot(data(i,j).fa(1:5:16),data(i,j).hit(1:5:16),'-o','color',colors(j-1,:));
            plot(data(i,j).fa(end-numTc:end),data(i,j).hit(end-numTc:end),'x','color',colors(j-1,:));
        if 0 %j>2  % skip the first and all data
            %relate to prev
            for k=1:length(tcs)
                plot([data(i,j-1).fa(k) data(i,j).fa(k)],[data(i,j-1).hit(k) data(i,j).hit(k)],'color',[.8 .8 .8])
            end
        end
    end
    settings=[];settings.box='on';
    cleanUpFigure(gcf,settings)
end


%% plot first quartile vs a
red=[1 0 0];
blue=[0 0 1];
black=[0 0 0];
mid=[.5 .5 .5];

symbol={'.','.','o'};

for i=1:length(subjects)
    figure; hold on;
    title([subjects{i} ])
    plot([0 1],[0 1],'k');
    axis square
    set(gca,'xtick',[],'ytick',[])
    for j=[2:3]%1:length(data)
        if j==1
            %the first
            plot(data(i,j).fa,data(i,j).hit,symbol{j},'color',black);
            plot(data(i,j).fa(1:5:16),data(i,j).hit(1:5:16),symbol{j},'color',blue);
            plot(data(i,j).fa(end-numTc:end),data(i,j).hit(end-numTc:end),symbol{j},'color',red);
        else
            %relate to the first
            plot(data(i,j).fa,data(i,j).hit,symbol{j},'color',mean([black; mid]));
            plot(data(i,j).fa(1:5:16),data(i,j).hit(1:5:16),symbol{j},'color',mean([blue; mid]));
            plot(data(i,j).fa(end-numTc:end),data(i,j).hit(end-numTc:end),symbol{j},'color',mean([red; mid]));
            for k=1:length(tcs)
                plot([data(i,1).fa(k) data(i,j).fa(k)],[data(i,1).hit(k) data(i,j).hit(k)],'color',[.8 .8 .8])
            end
        end
    end
end

% plot(fa,hit,'ok');
% plot(fa(end-numTc:end),hit(end-numTc:end),'or');
% plot(fa(1:5:16),hit(1:5:16),'ob');

%% quite stable across conditions (main difference is correct / incorrect)
numSubs=length(subjects);
numPlots=3;
tcs=x.params.factors.targetContrast(1,:);
fcs=x.params.factors.flankerContrast(1,:);
tcUnq=unique(tcs);
fcUnq=unique(fcs);
numTc=length(tcUnq);
numFc=length(fcUnq);


close all
types=x.names.rtCategories;
types={'all'}%,'correct','incorrect'}%,'yes','no','hits','misses','CRs','FAs'};
numTypes=length(types);
whichAnalaysis=1;
firstSub=1; % this should be locked to one, geven the way we do analysis
for j=1:numTypes
    whichType=j;
    figure
    for i=1:numSubs
        rt=reactionTimes{i,whichAnalaysis};
        subplot(numSubs,3,(i-1)*numPlots+1);
        mn=rt.mean(firstSub,find(fcs==fcUnq(1)),j); %fc is minimal ==0
        fst=rt.fast(firstSub,find(fcs==fcUnq(1)),j); %fc is minimal ==0
        %sd=rt.std(firstSub,find(fcs==fcUnq(1)),j);
        %plot([tcUnq; tcUnq],[mn-sd; mn+sd]);
        CI=reshape(rt.CI(firstSub,find(fcs==fcUnq(1)),j,:),[],2)';
        plot([tcUnq; tcUnq],CI); hold on
        plot(tcUnq,mn,'ko');
        %plot(tcUnq,fst,'kx');
        xlabel('tc'); ylabel('RT (sec)');
        %yl=ylim; set(gca,'ylim',[0 yl(2)],'xlim',[0 1.2]);
        set(gca,'ylim',[0 4],'xlim',[0 1.2]);
        axis square
        title([types{j} '-' subjects{i}])
                
        subplot(numSubs,3,(i-1)*numPlots+2);
        mn=rt.mean(firstSub,find(tcs==tcUnq(end)),j); %tc is maximal ==1
        fst=rt.fast(firstSub,find(tcs==tcUnq(end)),j);
        CI=reshape(rt.CI(firstSub,find(tcs==tcUnq(end)),j,:),[],2)';
        plot([fcUnq; fcUnq],CI); hold on
        plot(fcUnq,mn,'ko');
        %plot(fcUnq,fst,'kx');
        xlabel('fc'); ylabel('RT (sec)');
        %yl=ylim; set(gca,'ylim',[0 yl(2)],'xlim',[-.2 1.2]);
        set(gca,'ylim',[0 4],'xlim',[-.2 1.2]);
        axis square
        
        subplot(numSubs,3,(i-1)*numPlots+3);
        mn=rt.mean(firstSub,:,j); %tc is maximal ==1
        fst=rt.fast(firstSub,:,j); %tc is maximal ==1
        sd=rt.std(firstSub,:,j);
        sss=surf(tcUnq,fcUnq,reshape(mn,[],numTc));
        colormap([.5 .5 .5])
        xlabel('tc'); ylabel('fc'); zlabel('RT')
                set(gca,'zlim',[1 2]);
    end
end
%%  I DON'T QUITE TRUST THIS YET
close all
firstSub=1; % this should be locked to one, geven the way we do analysis
subjectAnalyzed=2;
whichAnalaysis=1;
rt=reactionTimes{subjectAnalyzed,whichAnalaysis};
numBins=20;
minTime=.5;
maxTime=2;

rt=reactionTimes{subjectAnalyzed,whichAnalaysis};
allResponses=[];
for j=1:length(tcs)
allResponses=[allResponses rt.raw{firstSub,j}.all];
end
allResponses=sort(allResponses);

figure
for t=1:numTc%:-1:1
    for f=1:numFc
      subplot(numTc,numFc,(t-1)*numFc+f);
      %figure
      set(gca,'YTickLabelMode','manual');  % gets rid of thre 10^6 symbol on y axis
      tc=tcUnq(t); fc=fcUnq(f);
      condInd=find(tcs==tc & fcs==fc);
      N=length(rt.raw{firstSub,condInd}.all);

      %text(minTime,0,sprintf('%2.2f,%2.2f',tc,fc)); hold on
      switch 'ks' 
          case 'hist'
              fa=rt.raw{firstSub,condInd}.FAs;
              cr=rt.raw{firstSub,condInd}.CRs;
              hit=rt.raw{firstSub,condInd}.hits;
              miss=rt.raw{firstSub,condInd}.misses;
              
              edges=linspace(minTime,maxTime,numBins);
              count=histc(hit,edges);
              bar(edges,count/(N*numBins*2),'histc'); hold on
              count=histc(miss,edges);
              bar(edges,-count/(N*numBins*2),'histc')
              set(gca,'ylim',[ -.002 .002])
          case 'ks'
              xi=linspace(minTime,maxTime,400);
              types={'hits','CRs','misses','FAs'};
              colors=[.6 .8 .6; .6 .8 .8; .8 .6 .8; .8 .6 .6];
              sgn=[1 -1 -1 1];
              for tt=1:length(types)
                  xx=rt.raw{firstSub,condInd}.(types{tt});
                  [f,xi] = ksdensity(xx,xi,'width',0.04); 
                  if 1 % scale to rates
                      p=f*min(diff(xi))*length(xx)/N;
                  else % normalize to condition occuring
                      p=f*min(diff(xi))*0.25;
                  end
                  p=p*10^5; % get rid of that pesky 10^6 symobl
                  fill([xi(1) xi xi(end)],[0 sgn(tt)*p 0]/N,'g','edgeAlpha',0,'faceColor',colors(tt,:)); hold on
                  fill([xi(1) xi xi(end)],[0 sgn(tt)*p 0]/N,'g','edgeColor',colors(tt,:)/2,'faceAlpha',0); 
                  if 0 %ismember(types{tt},{'hits','FAs'})
                      % mirror reflect outline of yes
                      fill([xi(1) xi xi(end)],[0 -sgn(tt)*p 0]/N,'g','edgeColor',[0 0 0],'faceAlpha',0); 
                  end
              end

              switch 'pctCorrect' %displayTest
                  case 'prob'
                      text(minTime,.3,sprintf('%2.2f - %2.2f',length(hit)/N,length(fa)/N));
                      text(minTime,-.3,sprintf('%2.2f - %2.2f',length(miss)/N,length(cr)/N));
                  case 'count'
                      text(minTime,.3,sprintf('%d - %d',length(hit),length(fa)));
                      text(minTime,-.3,sprintf('%d - %d',length(miss),length(cr)));
                  case 'pctCorrect'
                      text(minTime,-.3,sprintf('% 2.2f%%',100*data(subjectAnalyzed,whichAnalaysis).pctCorrect(condInd))); 
              end
              
              set(gca,'ylim',[ -.4 .25])     
              set(gca,'xlim',minmax(xi))
          case 'biasRatio'
              [f,xi] = ksdensity(hit); ph=f*min(diff(xi))*length(y)/N;
              [f,xi] = ksdensity(miss); pm=f*min(diff(xi))*length(n)/N;
              plot(xi,log(ph./pm)); hold on
              plot(edges,zeros(1,numBins),'k-')
              axis([0 3 -10 10])
      end
      
      if 0 % add midpoint of each
          %            med=median(rt.raw{firstSub,condInd}.all)
          %            plot(med([1 1]),ylim,'r-')
          
           numTr=length(allResponses);
           zz=median(allResponses);
           zz=allResponses(ceil(numTr/4)) % fraction of data
           plot(zz([1 1]),ylim,'k-')
      end
      %axis square
      set(gca,'xtick',[],'ytick',[])

      %title(sprintf('%2.2f,%2.2f',tc,fc));
    end  
end
subplot(numTc,numFc,(numTc-1)*numFc+1);
set(gca,'xtick',[minTime maxTime])
xlabel('RT'); ylabel('probability')

subplot(numTc,numFc,(numTc-1)*numFc+1);
set(gca,'xtick',[minTime maxTime])
xlabel('RT'); ylabel('probability')

set(gcf,'Position',[10 50 800 700])
cleanUpFigure(gcf,settings)
%%


%%
d=getSmalls('231',dateRange);
%%
x=removeSomeSmalls(d,~getGoods(d,'withoutAfterError'))
x=removeSomeSmalls(x,x.responseTime>5)
x=addYesResponse(x);
% x=removeSomeSmalls(x,~x.targetContrast==0)
% x=removeSomeSmalls(x,~x.flankerContrast==1)
% x=removeSomeSmalls(x,hr>0.75)
%x=removeSomeSmalls(x,x.numRequests~=1)
r=x.responseTime;
y=x.responseTime(x.yes==1);
n=x.responseTime(x.yes==0);
N=length(y) +length(n)
[f,xi] = ksdensity(r); pr=f*min(diff(xi))*length(y)/N;
[f,xi] = ksdensity(y); py=f*min(diff(xi))*length(y)/N;
[f,xi] = ksdensity(n); pn=f*min(diff(xi))*length(n)/N;

close all; figure
numPlot=4;

subplot(numPlot,1,1)
plot(xi,pr,'k-'); hold on
set(gca,'xtick',[])
ylabel('p(response)')

subplot(numPlot,1,2)
plot(xi,py,'g'); hold on
plot(xi,pn,'b'); hold on
legend({'Y=p(response|yes,time)','N=p(response|no,time)'})
ylabel('p(response)')

subplot(numPlot,1,3)
plot(xi,log(py./pn),'k-'); hold on
plot(xi,zeros(1,length(xi)),'k-');
ylabel('bias : log(Y/N)')
axis([0 5 -4 4])


hit=x.responseTime(x.yes==1 & x.correct==1);
fa=x.responseTime(x.yes==1 & x.correct==0);
cr=x.responseTime(x.yes==0 & x.correct==1);
miss=x.responseTime(x.yes==0 & x.correct==0);

N=length(r);
xi=linspace(0,5,200);
[f,xi] = ksdensity(hit,xi); phit=f*min(diff(xi))*length(hit)/N;
[f,xi] = ksdensity(fa,xi); pfa=f*min(diff(xi))*length(fa)/N;
[f,xi] = ksdensity(cr,xi); pcr=f*min(diff(xi))*length(cr)/N;
[f,xi] = ksdensity(miss,xi); pmiss=f*min(diff(xi))*length(miss)/N;

subplot(numPlot,1,4)
plot(xi,(phit+pcr)./(phit+pcr+pmiss+pfa),'k-'); hold on
plot([0 5],[.5 .5],'k-')
ylabel('correct')
xlabel('response time (sec)')
%axis([0 5 -4 4])
cleanUpFigure
%%
d=getSmalls('231',dateRange);
%%
close all
x=addYesResponse(d);
x.rand=rand(1,length(d.date));
x.iti=diff([0 x.date]);
x=removeSomeSmalls(x,~getGoods(x,'withoutAfterError'))
x=removeSomeSmalls(x,x.responseTime>5)

%% blockType

figure
plot(x.responseTime(x.correct==1),x.blockID(x.correct==1)+0.7*x.rand(x.correct==1),'g.','MarkerSize',5); hold on 
plot(x.responseTime(x.correct==0),x.blockID(x.correct==0)+0.7*x.rand(1,x.correct==0),'r.','MarkerSize',5)
%plot(x.responseTime(x.yes==0),x.blockID(x.yes==0)+0.7*x.rand(x.yes==0),'ok','MarkerSize',5)
%plot(x.responseTime(x.yes==1),x.blockID(x.yes==1)+0.7*x.rand(x.yes==1),'bs','MarkerSize',5)

axis([0 5 0.5 20])
xlabel('time'); ylabel('blockType');
cleanUpFigure

%% actualTargetOnSecs

figure
plot(x.responseTime(x.correct==1),x.actualTargetOnSecs(x.correct==1),'g.','MarkerSize',5); hold on 
plot(x.responseTime(x.correct==0),x.actualTargetOnSecs(x.correct==0),'r.','MarkerSize',5)
%plot(x.responseTime(x.yes==0),x.blockID(x.yes==0)+0.7*x.rand(x.yes==0),'ok','MarkerSize',5)
%plot(x.responseTime(x.yes==1),x.blockID(x.yes==1)+0.7*x.rand(x.yes==1),'bs','MarkerSize',5)

%axis([0 5 0.5 20])
xlabel('time'); ylabel('actualTargetOnSecs');
cleanUpFigure


%% trialThisBlock
figure
plot(x.responseTime(x.correct==1),x.trialThisBlock(x.correct==1)+0.7*x.rand(x.correct==1),'g.','MarkerSize',5); hold on 
plot(x.responseTime(x.correct==0),x.trialThisBlock(x.correct==0)+0.7*x.rand(1,x.correct==0),'r.','MarkerSize',5)
axis([0 5 0.5 150])
xlabel('time'); ylabel('trialThisBlock'); title(x.info.subject)
cleanUpFigure


%% nCorrectInARowCandidate
figure
plot(x.responseTime(x.correct==1),x.nCorrectInARowCandidate(x.correct==1)+0.7*x.rand(x.correct==1),'g.','MarkerSize',5); hold on 
plot(x.responseTime(x.correct==0),x.nCorrectInARowCandidate(x.correct==0)+0.7*x.rand(1,x.correct==0),'r.','MarkerSize',5)
%axis([0 5 0.5 150])
xlabel('time'); ylabel('nCorrectInARowCandidate'); title(x.info.subject)
cleanUpFigure

%% trialNumber
figure
plot(x.responseTime(x.correct==1),x.trialNumber(x.correct==1),'g.','MarkerSize',5); hold on 
plot(x.responseTime(x.correct==0),x.trialNumber(x.correct==0),'r.','MarkerSize',5)
axis([0 5 0.5 350000])
xlabel('time'); ylabel('trialNumber'); title(x.info.subject)
cleanUpFigure


id=max(find(x.date<pmmEvent('endToggle')));
plot(xlim,x.trialNumber([id id]),'k-')


%% step
figure
plot(x.responseTime(x.correct==1),x.step(x.correct==1)+0.7*x.rand(x.correct==1),'g.','MarkerSize',5); hold on 
plot(x.responseTime(x.correct==0),x.step(x.correct==0)+0.7*x.rand(1,x.correct==0),'r.','MarkerSize',5)
axis([0 5 9.5 19])
xlabel('time'); ylabel('step'); title(x.info.subject)
cleanUpFigure

%% hr since start
figure
day=floor(x.date);
[a b dayInd]=unique(day);
timeOfDay=mod(x.date,1);
firstTrialOfDayTime=timeOfDay(find(diff([0 day])~=0));
firstTrialOfDayTimeLong=firstTrialOfDayTime(dayInd);
hr=(timeOfDay-firstTrialOfDayTimeLong)*24;
%hist(hr)

plot(x.responseTime(x.correct==1),hr(x.correct==1),'g.','MarkerSize',5); hold on 
plot(x.responseTime(x.correct==0),hr(x.correct==0),'r.','MarkerSize',5)
%axis([0 5 0.5 150])
xlabel('response time'); ylabel('hrs into session'); title(x.info.subject)
cleanUpFigure

%% iti
xx=removeSomeSmalls(x,x.iti*24*60*60>20);

%
figure
plot(xx.responseTime(xx.correct==1),xx.iti(xx.correct==1)*24*60*60,'g.','MarkerSize',5); hold on 
plot(xx.responseTime(xx.correct==0),xx.iti(xx.correct==0)*24*60*60,'r.','MarkerSize',5)
%axis([0 5 0.5 150])

xlabel('time'); ylabel('iti (sec)'); title(xx.info.subject)
cleanUpFigure

%% numRequests
figure
plot(x.responseTime(x.correct==1),x.numRequests(x.correct==1)+0.7*x.rand(x.correct==1),'g.','MarkerSize',5); hold on 
plot(x.responseTime(x.correct==0),x.numRequests(x.correct==0)+0.7*x.rand(1,x.correct==0),'r.','MarkerSize',5)
%axis([0 5 0.5 150])

xlabel('time'); ylabel('numRequests'); title(x.info.subject)
cleanUpFigure

%% more Numrequest stuff
close all
figure
colors=jet(4);
for i=1:4
    subplot(2,1,1)
    r=x.responseTime(x.numRequests==i);
    N=length(r)
    xi=linspace(0,5,200);
    [f,xi] = ksdensity(r,xi); p=f/sum(f(:));
    plot(xi,p,'color',colors(i,:)); hold on
    

    hit=x.responseTime(x.yes==1 & x.correct==1 & x.numRequests==i);
    fa=x.responseTime(x.yes==1 & x.correct==0 & x.numRequests==i);
    cr=x.responseTime(x.yes==0 & x.correct==1 & x.numRequests==i);
    miss=x.responseTime(x.yes==0 & x.correct==0 & x.numRequests==i);
    if all([length(hit) length(fa) length(cr) length(miss)]>0)
        [f,xi] = ksdensity(hit,xi); phit=f*min(diff(xi))*length(hit)/N;
        [f,xi] = ksdensity(fa,xi); pfa=f*min(diff(xi))*length(fa)/N;
        [f,xi] = ksdensity(cr,xi); pcr=f*min(diff(xi))*length(cr)/N;
        [f,xi] = ksdensity(miss,xi); pmiss=f*min(diff(xi))*length(miss)/N;
        subplot(2,1,2)
        plot(xi,(phit+pcr)./(phit+pcr+pmiss+pfa),'color',colors(i,:)); hold on
        plot([0 5],[.5 .5],'k-')
        ylabel('correct')
        lgnames{i}=sprintf('%d Licks',i)
    else
        %text(0.2,.5, 'not enough data')
    end



end
legend(lgnames)
xlabel('response time (sec)')
cleanUpFigure
set(gcf,'Position',[10 50 400 800])
%%
whichPlots={'plotPerformance','plotTrialsPerDay','plotDPrime','plotLickAndRT',...
    'plotEvenMoreLickAndRT','plotResponseRaster','plotResponseDensity',...
    'plotMotorResponsePattern','plotTemporalROC',...
    'plotLocallyNormalizedEffect','plotContrastCurve','plotTheBodyWeights','plotBias',...
    'plotBiasScatter','plotRatePerDay','plotPerformancePerDaysTrial','plotMoreDetails'};
%whichPlots={,'plotRewardTime','plotFlankerAnalysis'};
n=length(whichPlots);
handles=1:n;
subplotParams.x=1;
subplotParams.y=1;
subplotParams.index=ones(1,n);
i=[1]
inspectRatResponses(x.info.subject,[],{'plotMotorResponsePattern'},handles(i),subplotParams,x)
%%
figure; 
%subplot(2,1,1)
[trialsPerDay correctPerDay]=makeDailyRaster(x.correct,x.yes,x.date,logical(ones(size(x.date))),[],5,x.info.subject{1},false,handles(i),subplotParams,false,true,false)
%subplot(2,1,2)
[trialsPerDay correctPerDay]=makeDailyRaster(x.correct,x.yes,x.date,x.responseTime>2.5,[],5,x.info.subject{1},false,handles(i),subplotParams,false,true,false)
%%

lengthHistory=3;
d.patternType=zeros(size(d.date));
which=getGoods(d,'forBias');
[count patternType uniques]=findResponsePatterns(d.response(which),lengthHistory,2,true);
if length(patternType)~=sum(which)  % uh oh
    error('can''t align pattern to trial')
end
d.patternType(which)=patternType;
x=removeSomeSmalls(d,~getGoods(d,'withoutAfterError'))
x=removeSomeSmalls(x,x.responseTime>5)
x=addYesResponse(x);


%Q what predicts the slow trials?
figure
patternIDs=unique(x.patternType);
for i=patternIDs
    hit=x.responseTime(x.yes==1 & x.correct==1 & i==patternType);
    fa=x.responseTime(x.yes==1 & x.correct==0 & i==patternType);
    cr=x.responseTime(x.yes==0 & x.correct==1 & i==patternType);
    miss=x.responseTime(x.yes==0 & x.correct==0 & i==patternType);
    
    N=length(r);
    xi=linspace(0,5,200);
    [f,xi] = ksdensity(hit,xi); phit=f*min(diff(xi))*length(hit)/N;
    [f,xi] = ksdensity(fa,xi); pfa=f*min(diff(xi))*length(fa)/N;
    [f,xi] = ksdensity(cr,xi); pcr=f*min(diff(xi))*length(cr)/N;
    [f,xi] = ksdensity(miss,xi); pmiss=f*min(diff(xi))*length(miss)/N;
    
    subplot(8,1,i)
    plot(xi,(phit+pcr)./(phit+pcr+pmiss+pfa),'k-'); hold on
    plot([0 5],[.5 .5],'k-')
    ylabel('correct')
    xlabel('response time (sec)')
    %axis([0 5 -4 4])

end
  cleanUpFigure
set(gcf,'Position',[10 50 400 800])
%%
xx=removeSomeSmalls(x,x.responseTime<2.5);
xx=x
hit=mean(xx.yes==1 & xx.correct==1);
fa=mean(xx.yes==1 & xx.correct==0);
cr=mean(xx.yes==0 & xx.correct==1);
miss=mean(xx.yes==0 & xx.correct==0);
fprintf('hit:%2.1f%% fa:%2.1f%% cr:%2.1f%% miss:%2.1f%%',hit*100,fa*100,cr*100,miss*100)



%%
% subplot(2,1,2)
% [f,xi] = ksdensity(x.responseTime);
% plot(xi,log(f))
% xlabel('time'); ylabel('log(p)');

%%

%%  when do trials after 1,5 seconds occur?


%% many rats
close all
subjects={'227', '229', '230', '237', '232', '233'};

for i=1:length(subjects)
    x=getSmalls(subjects{i});
    x.rand=rand(1,length(x.date));
    subplot(3,2,i)
    plot(x.responseTime(x.correct==1),x.trialNumber(x.correct==1),'g.','MarkerSize',5); hold on
    plot(x.responseTime(x.correct==0),x.trialNumber(x.correct==0),'r.','MarkerSize',5)
    axis([0 5 0.5 300000])
     title(x.info.subject)
end
xlabel('time'); ylabel('trialNumber');
cleanUpFigure

%% draw event
close all
id=min(find(x.step==10));
id=136648;
id=118613; %min(find(x.trainingStepName>15))
id=118613; min(find(x.schedulerClass>15))
x.trialNumber(id)
datestr(x.date(id))
f=fields(x);
f={'trainingStepName','date','sessionNumber','protocolName','manualVersion','autoVersion','schedulerClass','criterionClass','numRequests','firstIRI','responseTime','actualRewardDuration','proposedRewardDuration','response','blockID','flankerOff'}
for i=1:length(f)
    subplot(4,4,i)
    
    plot(x.trialNumber,x.(f{i})); hold on
    plot(x.trialNumber([id id]), ylim,'k-')
    title(f{i})
end

%% other rats same time

close all
subjects= {'231','232'}; {'229', '230', '232'}%{'231','234','227'};
figure
for i=1:length(subjects)
    x=getSmalls(subjects{i},dateRange);
    x.rand=rand(1,length(x.date));
    x=removeSomeSmalls(x,x.responseTime>10);
    subplot(1,2,i)
    plot(x.responseTime(x.correct==1),x.trialNumber(x.correct==1),'g.','MarkerSize',5); hold on
    plot(x.responseTime(x.correct==0),x.trialNumber(x.correct==0),'r.','MarkerSize',5)
        axis([0 5 ylim])
     title(x.info.subject)
     set(gca,'ytick',[])
     
end
    subplot(1,2,1); ylabel('trial'); xlabel('RT')
%%
close all
figure
subjects= {'229', '230', '232','231','234','227'};
subjects= {'231','232'};
for i=1:length(subjects)
    x=getSmalls(subjects{i},dateRange);
    x.rand=rand(1,length(x.date));
    x=removeSomeSmalls(x,x.responseTime>10);
    x=addYesResponse(x);
    subplot(1,2,i)
    r=x.responseTime;
    hit=x.responseTime(x.yes==1 & x.correct==1 );
    fa=x.responseTime(x.yes==1 & x.correct==0 );
    cr=x.responseTime(x.yes==0 & x.correct==1 );
    miss=x.responseTime(x.yes==0 & x.correct==0 );
    if all([length(hit) length(fa) length(cr) length(miss)]>0)
        [f,xi] = ksdensity(hit,xi); phit=f*min(diff(xi))*length(hit)/N;
        [f,xi] = ksdensity(fa,xi); pfa=f*min(diff(xi))*length(fa)/N;
        [f,xi] = ksdensity(cr,xi); pcr=f*min(diff(xi))*length(cr)/N;
        [f,xi] = ksdensity(miss,xi); pmiss=f*min(diff(xi))*length(miss)/N;
        plot(xi,(phit+pcr)./(phit+pcr+pmiss+pfa),'k-'); hold on
        plot([0 5],[.5 .5],'k-')
        ylabel('correct')
        set(gca,'xlim',[0 5],'ylim',[0 1])
        %lgnames{i}=sprintf('%d Licks',i)
        title(subjects{i})
        
        [f,xi] = ksdensity(r,xi); p=f*min(diff(xi))*length(r)/N;
        plot(xi,(p/max(p(:))),'r-'); hold on       
    else
        text(0.2,.5, 'not enough data')
    end
end
%legend(lgnames)
xlabel('response time (sec)')
cleanUpFigure
set(gcf,'Position',[10 50 400 800])


%% 
for i=1:length(subjects)
    subplot(3,1,i)
    axis([0 5 ylim])
end
xlabel('time'); ylabel('trialNumber');
cleanUpFigure

%% check alligned in raw and smalls: RT,trialNumber & correct
d=getSmalls('231',dateRange);

%%
close all
x=removeSomeSmalls(d,d.step~=16);
x=removeSomeSmalls(x,x.sessionNumber~=527);
[datestr(x.date(1)) ' to ' datestr(x.date(end))]
[num2str(x.trialNumber(1)) ' to ' num2str(x.trialNumber(end))]

subplot(2,1,1)
    plot(x.responseTime(x.correct==1),x.trialNumber(x.correct==1),'g.','MarkerSize',5); hold on
    plot(x.responseTime(x.correct==0),x.trialNumber(x.correct==0),'r.','MarkerSize',5)
        axis([0 10 ylim])
     title('fan''s RT')
     set(gca,'ytick',[])
     
     subplot(2,1,2)
    plot(X.responseTime(x.correct==1),x.trialNumber(x.correct==1),'g.','MarkerSize',5); hold on
    plot(X.responseTime(x.correct==0),x.trialNumber(x.correct==0),'r.','MarkerSize',5)
        axis([0 10 ylim])
     title('philip''s RT')
     set(gca,'ytick',[])
%%    
     D=load('\\reinagel-lab.ad.ucsd.edu\rlab\Rodent-Data\behavior\pmeierTrialRecords\subjects\231\trialRecords_201137-201742_20090728T111511-20090728T124508')
%%

for i=1:length(D.trialRecords)
   X.trialNumber(i)=D.trialRecords(i).trialNumber;
   
   j=2;  % 2nd phase is discrim, check that
   if ~strcmp(D.trialRecords(i).phaseRecords(j).phaseLabel,'discrim')
       error('bad phase label in spot 2')
   else
       %get it
       D.trialRecords(i).phaseRecords(j).responseDetails.tries{end};
       X.response(i)=find(D.trialRecords(i).phaseRecords(j).responseDetails.tries{end});
       
       
       %this is a better way to calc RT
       X.RT(i)=D.trialRecords(i).phaseRecords(j).responseDetails.startTime... %raw phase start
           +D.trialRecords(i).phaseRecords(j).responseDetails.times{end}...   %last respose in discrim (relative to this phase start)
           -D.trialRecords(i).phaseRecords(1).responseDetails.startTime...    %raw phase start, first phase, thus trial start
           -D.trialRecords(i).phaseRecords(1).responseDetails.times{end};     %last respose in waiting for request (relative to this phase start)
       
       %discrimStart(i)=D.trialRecords(i).phaseRecords(j).responseDetails.startTime;
       %trialStart(i)=D.trialRecords(i).phaseRecords(1).responseDetails.startTime;
       %responseTimeRelDiscrim(i)=D.trialRecords(i).phaseRecords(j).responseDetails.times{end};    %last respose in discrim
       %requestTimeRelTrial(i)=D.trialRecords(i).phaseRecords(1).responseDetails.times{end}; %last respose in waiting for request
       
       X.numTriesInDiscrim(i)=length(D.trialRecords(i).phaseRecords(j).responseDetails.tries);
       %check assumptions
       if find(D.trialRecords(i).phaseRecords(j).responseDetails.tries{end})==2; 
         error('center request not allowed for response')
       end
       if X.numTriesInDiscrim(i)>2
           for k=1:X.numTriesInDiscrim(i)-1
               if find(D.trialRecords(i).phaseRecords(j).responseDetails.tries{k})~=2;
                   error('previous licks in discrim must NOT be response')
               else
                   %fprintf('check lick %d on trial %d, successfullly not a response during discrim\n',k,X.trialNumber(i))
               end
           end
       end
       
       X.numTriesInWaiting(i)=length(D.trialRecords(i).phaseRecords(1).responseDetails.tries);
       if find(D.trialRecords(i).phaseRecords(1).responseDetails.tries{end})~=2; 
         error('waiting phase must end with a center request')
       end
       if X.numTriesInWaiting(i)>2
           for k=1:X.numTriesInWaiting(i)-1
               if find(D.trialRecords(i).phaseRecords(1).responseDetails.tries{k})==2;
                   error('previous licks in waiting must NOT be request')
               else
                   fprintf('check lick %d on trial %d, successfullly not a request during waiting\n',k,X.trialNumber(i))
               end
           end
       end
   end
end
X.responseTime=X.relativeResponseTime-X.relativeRequestTime;
abs(x.responseTime-X.responseTime);
%%
all( x.trialNumber==X.trialNumber)
all( x.numRequests==X.numTriesInDiscrim)
all(X.responseTime==X.RT)
%%

plot(requestTimeRelTrial); hold on; plot(responseTimeRelDiscrim,'r');
figure; plot(discrimStart-trialStart,'r');