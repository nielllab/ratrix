





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
sweptImageParameters={'flankerOrientation','targetOrientation','flankerPosAngle','targetContrast','flankerContrast'}; % why does contrast have to be last?
or=-pi/12;
sweptImageValues={or,or,or,1,0};
borderColor=[0 .8 0];
antiAliasing=false;
useSymbolicFlanker=true;
[images]=getStimSweep(sweptImageParameters,sweptImageValues,borderColor,[],'column',false,antiAliasing,useSymbolicFlanker);

figure; montage(images,'DisplayRange',[0,255]);

%%
sweptImageParameters={'flankerOrientation','targetOrientation','flankerPosAngle','targetContrast','flankerContrast'}; % why does contrast have to be last?
or=-pi/8;
sweptImageValues={or,or,or,[.25 .5 0.75 1].^1.6,[0 .25 .5 .75 1].^1.6}; % include a gamma
borderColor=0.8*ones(20,3);
borderColor(1:4,[1 2])=0;
borderColor([4 8 12 16 20],[2 3])=0;
borderColor(4,3)=.8;
antiAliasing=true;
useSymbolicFlanker=false;
[images]=getStimSweep(sweptImageParameters,sweptImageValues,borderColor,[],'column',false,antiAliasing,useSymbolicFlanker);
inds=fliplr(reshape([1:20],4,5)'); inds=inds(:);

figure; montage(images(:,:,:,inds),'DisplayRange',[0,255], 'Size',[4 5]);


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

%%
x=linspace(0,10,100)
subplot(2,1,1); ; hold off; plot(x,normpdf(x,3,1),'r'); hold on
plot(x,normpdf(x,3.5,1),'g'); axis([0 10 0 .5]) 
set(gca,'xtick',[],'ytick',[])
subplot(2,1,2); ; hold off; plot(x,normpdf(x,5,1.5),'r'); hold on
plot(x,normpdf(x,7,1.2),'g') ; axis([0 10 0 .5]) 
set(gca,'xtick',[],'ytick',[])
settings.LineWidth=3;
settings.AxisLineWidth=3;

settings.box='off'
cleanUpFigure(gcf,settings)

%% some distribtutions


%% plot gevs


% p.modelName='gevg-234'
% p=p.load();



%figure;
p.edges=linspace(.1,.7,100);
%p.plotModelFeatures([],[],{'sig&Noise'})
for i=1:25
    subplot(5,5,i)
    set(gca,'xtick',[],'ytick',[],'box','on','ylim',[0 2]);
    if mod(i,5)==1
        color=[0 0 .8];
    elseif i<=5

        
        color=[.8 0 0];
    else
        color=[.8 .8 .8];
    end
    set(gca,'YColor',color,'XColor',color)
    axis([.1 .7 0 14])
end

settings.LineWidth=3;
settings.AxisLineWidth=3;

cleanUpFigure(gcf,settings)
%% upside down plot features

if ~exist('tc','var') || isempty(tc)
    tc= p.tc;
end
if ~exist('fc','var') || isempty(fc)
    fc= p.fc;
end
if ~exist('features','var') || isempty(features)
    features= {'response','contrast','eye','attn'}; %from bottom to top
    weight=[3 3 2 2];
end
if ~exist('weight','var') || isempty(weight)
    weight= ones(1,length(features));
end
if ~exist('gutter','var') || isempty(gutter)
    gutter=max(weight)/8;
end
%calculate fInds and tInds from requested tc and fc
tInds=find(ismember(p.tc,tc));
fInds=find(ismember(p.fc,fc));
if any(~ismember(tc,p.tc)) || any(~ismember(fc,p.fc))
    p.tc
    p.fc
    tc
    fc;
    error('bad contrast choice')
end

%calculate bounds used for yFloors and heights used for yScales
bounds=[0 weight; repmat(gutter,1,length(weight)+1)];
bounds=bounds/sum(bounds(1:end-1));  %end -1 lets the top gutter not exist
height=bounds(1,2:end);
bounds=reshape(cumsum(bounds(:)),2,[])';  %'
h=length(fInds);
w=length(tInds);

for f=1:length(fInds)
    for t=1:length(tInds)
        subplot(h,w,(5-t)*length(fInds)+f); hold on;
        
        % set currrent tc and fc
        p.current.tc=p.tc(tInds(t));
        p.current.fc=p.fc(fInds(f));
        p.current.stdAttn=p.stdAttn(fInds(f),fInds(t));
        
        for i=1:length(features)
            yOffset=bounds(i,1);
            thresh=0.001;
            switch features{i}
                case 'attn'
                    y=p.gauss(p.loc,0,p.stdAttn(fInds(f),tInds(t)));
                    y=p.getAttentionEnvelope;
                    %yScale=height(i)/max(y);
                    yScale=height(i)/p.contrastHeight;
                    p.plotCurve(p.loc,y,[.6 .8 .8],'fill',yOffset,yScale,thresh);
                case 'eye'
                    y=p.gauss(p.loc,0,p.stdEye);
                    yScale=height(i)/max(y);
                    p.plotCurve(p.loc,y,[.6 .8 .8],'fill',yOffset,yScale,thresh);
                case 'contrast'
                    y=p.getContrastEnvelope;
                    yScale=height(i)/p.contrastHeight;
                    p.plotCurve(p.loc,y,[.8 .8 .8],'fill',yOffset,yScale,thresh);
                case {'responseWithContrastEnvelope','responseWithCombinedEnvelope','response'}
                    forceEyePos=0;
                    switch features{i}
                        case 'responseWithContrastEnvelope'
                            y=p.getContrastEnvelope;
                            yScale=height(i)/p.contrastHeight;
                            p.plotCurve(p.loc,y,[.8 .8 .8],'fill',yOffset,yScale,thresh);
                        case 'responseWithCombinedEnvelope'
                            y=p.getContrastEnvelope.*p.getAttentionEnvelope(forceEyePos);
                            yScale=height(i)/(p.contrastAttentionHeight*0.5);
                            p.plotCurve(p.loc,y,[.8 .8 .8],'fill',yOffset,yScale,thresh);
                        case 'response'
                            %no background
                    end
                    
                    y=p.nodeResponse(forceEyePos);
                    yScale=height(i)/(p.contrastAttentionHeight*2);
                    p.plotCurve(p.loc,y,[0 0 0],'verticalLines',yOffset,yScale);
                    
                    crit=p.crit(fInds(f),tInds(t));
                    plot(minmax(p.loc),yScale*crit([1 1])+yOffset,'k');
                    
                    whichAbove=find(y>crit);
                    if p.tc(tInds(t))>0
                        aboveColor=[0 .8 0]; %hit = green
                    else
                        aboveColor=[0.8 0 0]; % fa = red
                    end
                    p.plotCurve(p.loc(whichAbove),y(whichAbove),aboveColor,'verticalLines',yOffset,yScale);
                case 'Q-Q'
                    n=p.numIttn;
                    rank=1:n;
                    x=sort(permute(p.cache.dv(fInds(f),tInds(t),:),[3 2 1]));
                    maxX=x(end);
                    params=gevfit(x); %p.cache.gevparams(fInds(f),tInds(t));
                    y=gevinv((1+n-rank)/n,params(1),params(2),params(3));
                    plot(flipud(x)/maxX,y*(height(i)/maxX)+yOffset,'.','color',[0 0 0])
                case 'P-P'
                    error('not yet')
                case 'sig&Noise'
                    switch p.sdtDistributionType
                        case {'eqVarGaussian','gaussian'}
                            xn=p.cache.gauss.xn(fInds(f),tInds(t),:);
                            xs=p.cache.gauss.xs(fInds(f),tInds(t),:);
                            
                            ys=normpdf(p.edges,xs(1),xs(2));
                            yn=normpdf(p.edges,xn(1),xn(2));
                            plot(p.edges,yn,'r');
                            plot(p.edges,ys,'g');
                            
                            %plot([xn(1) xn(1)],ylim,'r')
                            %plot([xs(1) xs(1)],ylim,'g')
                            crit=p.crit(fInds(f),tInds(t));
                            %plot(crit([1 1]),ylim,'k')
                            
                        case {'gev'}
                            
                            xn=p.cache.gev.xn(fInds(f),tInds(t),:);
                            xs=p.cache.gev.xs(fInds(f),tInds(t),:);
                            
                            ys=gevpdf(p.edges,xs(1),xs(2),xs(3));
                            yn=gevpdf(p.edges,xn(1),xn(2),xn(3));
                            plot(p.edges,yn,'r');
                            plot(p.edges,ys,'g');
                            
                            %plot([xn(3) xn(3)],ylim,'r')
                            %plot([xs(3) xs(3)],ylim,'g')
                            crit=p.crit(fInds(f),tInds(t));
                            %plot(crit([1 1]),ylim,'k')
                            %set(gca,'xlim',[0 0.2],'ylim',[0 150])
                        otherwise
                            error
                    end
                case 'evFit'
                    signal=permute(p.cache.dv(fInds(f),tInds(t),:),[3 2 1]);
                    xs=p.cache.xs(fInds(f),tInds(t),:);  % could fit it fresh and store it if its not there
                    n=histc(signal,p.edges);
                    bar(p.edges,n/p.numIttn,'histc');
                    ys=gevpdf(p.edges,xs(1),xs(2),xs(3));
                    plot(p.edges,ys/sum(ys(:)),'g');
                    %set(gca,'xlim',[0 0.2],'ylim',[0 0.3])
                    %set(gca,'xlim',minmax(p.edges))
                otherwise
                    features{i}
                    error('bad')
            end % switch features
            %general sizing
            switch features{i}
                case {'responseWithContrastEnvelope','responseWithCombinedEnvelope','response','contrast','eye','attn'}
                    set(gca,'xlim',minmax(p.loc),'ylim',[0 1])
                    set(gca,'xtick',[],'ytick',[])
                    axis square
                    if t==1 && f==1
                        %pxlabel('visual position')
                        for ii=1:length(features)
                            xl=xlim;
                            name=features{ii};
                            if length(name)>10
                                name='response';
                            end
                            if w>2
                                %xx=xl(2)+diff(xl)*0.2; % on thr right if many plots (not to bump with C_f)
                                %turned off, cuz still too clutered
                            else
                                xx=xl(1)-diff(xl)*0.05;  % put it on the left if only one plot
                                text(xx,bounds(ii,1),name,'Rotation',90)
                            end
                            
                        end
                    end
                case {'Q-Q'}
                    axis square
                    set(gca,'xtick',[0 1],'ytick',[0 1])
                    set(gca,'xlim',[0 1],'ylim',[0 1])
                case {'evFit','sig&Noise'}
                    %set(gca,'xtick',[],'ytick',[])
                    
                    
            end
        end % for features
        if h>2 && t==1
            xl=xlim;
           % text(xl(1)-diff(xl)*0.2,mean(ylim),sprintf('C_{f}=%2.2f',p.fc(fInds(f))),'horizontalAlignment','right')
        end
        if h>2 && f==1
            yl=ylim;
            %text(mean(xlim),yl(2)+diff(yl)*0.2,sprintf('C_{t}=%2.2f',p.tc(tInds(t))),'horizontalAlignment','center')
        end
        
    end % for f
end  %for t