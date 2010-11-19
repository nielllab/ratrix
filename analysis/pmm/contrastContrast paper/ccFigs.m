





%% compute explain

path='C:\pmeier\Analysis Records\contrastContrast';
rat=imread(fullfile(path,'rat.tif'));
explain=imread(fullfile(path,'yn2afc.tif'));

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

%% plot explain
%close(1); 
figure(1); cleanUpFigure
for i=1:3
    switch i
        case 1
            a(i)=axes('position', [.1 .55 .3 .3])
            montage(rat(500:1900,500:2400,1:3));
        case 2
            a(2)=axes('position', [.05 .01 .4 .45])
            montage(explain(300:2000,700:2400,1:3)); %axis square
        case 3
            a(3)=axes('position', [.5 .1 .5 .75])
            montage(images(:,:,:,inds),'DisplayRange',[0,255], 'Size',[4 5]);
            ylabel('target contrast')
            xlabel('flanker contrast')
    end
    
    set(a(i),'xtick',[],'ytick',[])
    settings.turnOffTics=1;
    settings.LineWidth=0;
    settings.alphaLabel=lower(char(64+i));
    cleanUpFigure(a(i),settings)
end
%%  calculate for tcs & fcs
dateRange= [pmmEvent('231&234-jointSweep')+1 pmmEvent('231-test200msecDelay')]; filter{1}.type='16';
%[stats CI names params]=getFlankerStats({'234'},'allBlockSegments',{'hits','CRs','dpr'},filter,dateRange); 
[stats CI names params]=getFlankerStats({'234'},'allBlockIDs',{'hits','CRs','dpr','crit'},filter,dateRange); % dprimeMCMC
%

%% more of same in segs
[seg_stats seg_CI seg_names seg_params]=getFlankerStats({'234'},'allBlockSegments',{'dpr','crit'},filter,dateRange);
blockID=seg_params.factors.blockID;
bIDs=unique(blockID)
tcs=seg_params.factors.targetContrast;
for i=1:length(bIDs)
    %get rid of the 0 contrast in the blocked info
 tcsPerBlockID(i)=max(tcs(blockID==bIDs(i)));
 tcs(blockID==bIDs(i))=tcsPerBlockID(i);
end
fcs=seg_params.factors.flankerContrast;
tc=unique(tcs); 
fc=unique(fcs);
numTc=length(tc);
numFc=length(fc);

%% plot tcs
close(2);
figure(2); cleanUpFigure
subplot(2,2,1);
curvesOn=0;
which=[1:5:20];
colors=customColorMap([0 1], [.6 .6 .8; .1 .1 .9],4);
params.colors(which,:)=colors; % overwrite
conditions=names.conditions(which);
doHitFAScatter(stats,CI,names,params,[],conditions,0,curvesOn,0,0,0,1,[]);


subplot(4,2,2); hold on
x=linspace(-3,5,300);
d=stats(1 , which(2) ,strcmp(names.stats,'dpr'));
crit=stats(1 , which(2) ,strcmp(names.stats,'crit'));
critLine=norminv(stats(1 , which(2) ,strcmp(names.stats,'CRs')));
plot(critLine([1 1]),[0 1],'color',[.8 .8 .8])
%plot(crit([1 1]),[0 1],'color',[.8 0 .8])
plot(x,normpdf(x,0,1),'k'); 
plot(x,normpdf(x,d,1),'color',colors(2,:)); 
axis([-3 5 0 0.5])
set(gca,'xtick',[],'ytick',[])

subplot(4,2,4); hold on
d=stats(1 , which(end) ,strcmp(names.stats,'dpr'))
crit=stats(1 , which(end) ,strcmp(names.stats,'crit'));
critLine=norminv(stats(1 , which(end) ,strcmp(names.stats,'CRs')));
critLine2=norminv(1-stats(1 , which(end) ,strcmp(names.stats,'hits')),d,1);
if critLine2~=critLine
    error('violates the way d'' should work')
end
plot(critLine([1 1]),[0 1],'color',[.8 .8 .8])
%plot(crit([1 1]),[0 1],'color',[.8 0 .8])
plot(x,normpdf(x,0,1),'k'); 
plot(x,normpdf(x,d,1),'color',colors(end,:)); 
axis([-3 5 0 0.5])
set(gca,'xtick',[],'ytick',[])
xlabel('decision variable')

subplot(2,2,3); hold on
mn=[];
tc=unique(params.factors.targetContrast)
for t=1:numTc
    fw=0.03;
    w=find(fcs==0 & tcs==tc(t));
    mn(t)=mean(seg_stats(1,w,strcmp(seg_names.stats,'dpr')));
    st=std(seg_stats(1,w,strcmp(seg_names.stats,'dpr')));
    fill(tc(t)+fw*[1 1 -1 -1],mn(t)+st*[-1 1 1 -1],'c','edgeColor',[1 1 1],'faceColor',colors(t,:));
    
    %plot(tc(t),stats(1 , which(t) ,strcmp(names.stats,'dpr')),'.','color',params.colors(which(t),:))
end
xlabel('target contrast'); ylabel('d''')

w=find(fcs==0 & tcs>0);
offset=(0.05*w./max(w))-0.025;%by time
axis([0 1.2 0 3])
plot(tcs(w)+offset,seg_stats(1,w,find(strcmp(seg_names.stats,'dpr'))),'.k')
%plot(tc,mn,'b')
%set(gca,'xtickLabel',[0 tc],'xtick',[0 tc],'ytickLabel',[.5 1],'ytick',[.5 1])
%axis([0 1.1 0 1])
% set(gcf,'Position',[50 50 400 300])

subplot(2,2,4); hold on
mn=[];
tc=unique(params.factors.targetContrast)
for t=1:numTc
    fw=0.03;
    w=find(fcs==0 & tcs==tc(t));
    mn(t)=mean(seg_stats(1,w,strcmp(seg_names.stats,'crit')));
    st=std(seg_stats(1,w,strcmp(seg_names.stats,'crit')));
    fill(tc(t)+fw*[1 1 -1 -1],mn(t)+st*[-1 1 1 -1],'c','edgeColor',[1 1 1],'faceColor',colors(t,:)); %[.6 .8 1]
    %plot(tc(t),stats(1 , which(t) ,strcmp(names.stats,'crit')),'.','color',params.colors(which(t),:))
end
xlabel('target contrast'); ylabel('criterion')
axis([0 1.2 -1 1])



w=find(fcs==0 & tcs>0);
offset=(0.05*w./max(w))-0.025;%by time
plot(tcs(w)+offset,seg_stats(1,w,find(strcmp(seg_names.stats,'crit'))),'.k')
%plot(tc,mn,'b')

settings=[];
settings.LineWidth=2;
settings.AxisLineWidth=2;
settings.fontSize=12;

subplot(2,2,1); settings.alphaLabel='a'; cleanUpFigure(gca,settings)
subplot(4,2,2); settings.alphaLabel='b'; cleanUpFigure(gca,settings)
subplot(4,2,4); settings.alphaLabel='c'; cleanUpFigure(gca,settings)
subplot(2,2,3); settings.alphaLabel='d'; cleanUpFigure(gca,settings)
subplot(2,2,4); settings.alphaLabel='e'; cleanUpFigure(gca,settings)

%% plot fcs
close(3); 
figure(3); cleanUpFigure
subplot(2,2,1);
curvesOn=0;
which=[16:20];
conditions=names.conditions(which);
colors=customColorMap([0 .3 1], [ .1 .1 .9;  .6 .2 .5;  .8 .2 .2],5)
params.colors(which,:)=colors; % overwrite
doHitFAScatter(stats,CI,names,params,[],conditions,0,curvesOn,0,0,0,1,[]);

subplot(4,2,2); hold on
d=stats(1 , which(1) ,strcmp(names.stats,'dpr'));
crit=stats(1 , which(1) ,strcmp(names.stats,'crit'));
critLine=norminv(stats(1 , which(1) ,strcmp(names.stats,'CRs')));
critLine2=norminv(1-stats(1 , which(1) ,strcmp(names.stats,'hits')),d,1);
% if critLine2~=critLine
%     error('violates the way d'' should work')
% end
x=linspace(-3,5,300);
plot(critLine([1 1]),[0 1],'color',[.8 .8 .8])
%plot(crit([1 1]),[0 1],'color',[.8 0 .8])
plot(x,normpdf(x,0,1),'k'); 
plot(x,normpdf(x,d,1),'color',colors(1,:)); 
axis([-3 5 0 0.5])
set(gca,'xtick',[],'ytick',[])

subplot(4,2,4); hold on
d=stats(1 , which(end) ,strcmp(names.stats,'dpr'));
crit=stats(1 , which(end) ,strcmp(names.stats,'crit'));
critLine=norminv(stats(1 , which(end) ,strcmp(names.stats,'CRs')));
plot(critLine([1 1]),[0 1],'color',[.8 .8 .8])
%plot(crit([1 1]),[0 1],'color',[.8 0 .8])
plot(x,normpdf(x,0,1),'k'); 
plot(x,normpdf(x,d,1),'color',colors(end,:)); 
axis([-3 5 0 0.5])
set(gca,'xtick',[],'ytick',[])
xlabel('decision variable')

subplot(2,2,3); hold on
mn=[];
tc=unique(params.factors.targetContrast)
for f=1:numFc
    fw=0.03;
    w=find(fcs==fc(f) & tcs==1);
    mn(f)=mean(seg_stats(1,w,strcmp(seg_names.stats,'dpr')));
    st=std(seg_stats(1,w,strcmp(seg_names.stats,'dpr')));
    fill(fc(f)+fw*[1 1 -1 -1],mn(f)+st*[-1 1 1 -1],'c','edgeColor',[1 1 1],'faceColor',colors(f,:));
    
    %plot(tc(f),stats(1 , which(f) ,strcmp(names.stats,'dpr')),'.','color',colors(f,:))
end
xlabel('flanker contrast'); ylabel('d''')

w=find(tcs==1);
offset=(0.05*w./max(w))-0.025;%by time
axis([-0.2 1.2 0 3])
plot(fcs(w)+offset,seg_stats(1,w,find(strcmp(seg_names.stats,'dpr'))),'.k')
%plot(tc,mn,'b')
%set(gca,'xtickLabel',[0 tc],'xtick',[0 tc],'ytickLabel',[.5 1],'ytick',[.5 1])
%axis([0 1.1 0 1])
% set(gcf,'Position',[50 50 400 300])

subplot(2,2,4); hold on
mn=[];
tc=unique(params.factors.targetContrast)
for f=1:numFc
    fw=0.03;
    w=find(fcs==fc(f) & tcs==1);
    mn(f)=mean(seg_stats(1,w,strcmp(seg_names.stats,'crit')));
    st=std(seg_stats(1,w,strcmp(seg_names.stats,'crit')));
    fill(fc(f)+fw*[1 1 -1 -1],mn(f)+st*[-1 1 1 -1],'c','edgeColor',[1 1 1],'faceColor',colors(f,:));
    %plot(fc(f),stats(1 , which(f) ,strcmp(names.stats,'crit')),'.','color',colors(f,:))
end
xlabel('flanker contrast'); ylabel('criterion')
axis([-0.2 1.2 -1 1])

w=find(tcs==1);
offset=(0.05*w./max(w))-0.025;%by time
plot(fcs(w)+offset,seg_stats(1,w,find(strcmp(seg_names.stats,'crit'))),'.k')
%plot(fc,mn,'b')

settings=[];
settings.LineWidth=2;
settings.AxisLineWidth=2;
settings.fontSize=12;

subplot(2,2,1); settings.alphaLabel='a'; cleanUpFigure(gca,settings)
subplot(4,2,2); settings.alphaLabel='b'; cleanUpFigure(gca,settings)
subplot(4,2,4); settings.alphaLabel='c'; cleanUpFigure(gca,settings)
subplot(2,2,3); settings.alphaLabel='d'; cleanUpFigure(gca,settings)
subplot(2,2,4); settings.alphaLabel='e'; cleanUpFigure(gca,settings)

%%  calculate for tcs & fcs
dateRange= [pmmEvent('231&234-jointSweep')+1 pmmEvent('231-test200msecDelay')]; filter{1}.type='16';
%[stats CI names params]=getFlankerStats({'234'},'allBlockSegments',{'hits','CRs','dpr'},filter,dateRange); 
[stats CI names params]=getFlankerStats({'234'},'allBlockIDs',{'hits','CRs','dpr','crit'},filter,dateRange); % dprimeMCMC

c=names.conditions;
k=2;             k=3;
arrows={c{1},c{6},k; c{6},c{11},k; c{11},c{16},k;...
    c{2},c{7},k; c{7},c{12},k; c{12},c{17},k;...
    c{3},c{8},k; c{8},c{13},k; c{13},c{18},k;...
    c{4},c{9},k; c{9},c{14},k; c{14},c{19},k;...
    c{5},c{10},k; c{10},c{15},k; c{15},c{20},k};

arrows={c{1},c{2},k; c{2},c{3},k; c{3},c{4},k; c{4},c{5},k;...
    c{6},c{7},k; c{7},c{8},k; c{8},c{9},k; c{9},c{10},k;...
    c{11},c{12},k; c{12},c{13},k; c{13},c{14},k; c{14},c{15},k;...
    c{16},c{17},k; c{17},c{18},k; c{18},c{19},k; c{19},c{20},k};


params.colors(:)=.8;
params.colors([1:5:20],:)=customColorMap([0 1], [.6 .6 .8; .1 .1 .9],4); % overwrite target
params.colors([16:20],:)=customColorMap([0 .3 1], [ .1 .1 .9;  .6 .2 .5;  .8 .2 .2],5); %flankers
type_colors=params.colors
type_tcs=params.factors.targetContrast;
type_fcs=params.factors.flankerContrast;
figure(4)
subplot(1,2,1)
doHitFAScatter(stats,CI,names,params,{'234'},[],0,0,0,0,0,1,arrows);  % note bias - say yes more when close


[stats CI names params]=getFlankerStats({'234'},'allBlockSegments',{'hits','CRs','dpr','crit'},filter,dateRange);
tcs=params.factors.targetContrast;
fcs=params.factors.flankerContrast; 
subplot(2,4,3)
for t=1:numTc
    for f=1:numFc
        which=find(tcs==tc(t) & fcs==fc(f)); a=sqrt(length(which));
        y(f)=mean(stats(1,which,3)); er(f)=std(stats(1,which,3))/a;
        whichColor=find(type_tcs==tc(t) & type_fcs==fc(f));
        plot(fc([f f]),y(f)+[-er(f) er(f)],'color',type_colors(whichColor,:)); hold on
    end
    plot(fc,y,'k')
end
axis([-.1 1.1 -.2 3]); 

subplot(2,4,7)
for t=1:numTc
    for f=1:numFc
        which=find(tcs==tc(t) & fcs==fc(f)); a=sqrt(length(which));
        y(f)=mean(stats(1,which,4)); er(f)=std(stats(1,which,4))/a;
        whichColor=find(type_tcs==tc(t) & type_fcs==fc(f));
        plot(fc([f f]),y(f)+[-er(f) er(f)],'color',type_colors(whichColor,:)); hold on
        %n(whichColor)=length(which)
    end
    plot(fc,y,'k')
end
axis([-.1 1.1 -1 1]); set(gca,'ytick',[-1 0 1])


[stats CI names params]=getFlankerStats({'231'},'allBlockSegments',{'hits','CRs','dpr','crit'},filter,dateRange);
tcs=params.factors.targetContrast;
fcs=params.factors.flankerContrast;

subplot(2,4,4)
for t=1:numTc
    for f=1:numFc
        which=find(tcs==tc(t) & fcs==fc(f)); 
        v=stats(1,which,3); v(isinf(v))=[]; a=sqrt(length(v));
        y(f)=mean(v); er(f)=std(v)/a;
        whichColor=find(type_tcs==tc(t) & type_fcs==fc(f));
        plot(fc([f f]),y(f)+[-er(f) er(f)],'color',type_colors(whichColor,:)); hold on
    end
    plot(fc,y,'k')
end
axis([-.1 1.1 -.2 3]); 

subplot(2,4,8)
for t=1:numTc
    for f=1:numFc
        which=find(tcs==tc(t) & fcs==fc(f)); a=sqrt(length(which));
        v=stats(1,which,4); v(isinf(v))=[]; a=sqrt(length(v));
        y(f)=mean(v); er(f)=std(v)/a;
        whichColor=find(type_tcs==tc(t) & type_fcs==fc(f));
        plot(fc([f f]),y(f)+[-er(f) er(f)],'color',type_colors(whichColor,:)); hold on
    end
    plot(fc,y,'k')
end
axis([-.1 1.1 -1 1]); set(gca,'ytick',[-1 0 1])

cleanUpFigure(gcf,settings)
settings=[];
subplot(1,2,1); settings.alphaLabel='a'; cleanUpFigure(gca,settings)
subplot(2,4,3); ylabel('d'''); xlabel('C_F'); settings.alphaLabel='b'; cleanUpFigure(gca,settings)
subplot(2,4,4);  xlabel('C_F'); settings.alphaLabel='c'; cleanUpFigure(gca,settings) %ylabel('d''');
subplot(2,4,7); ylabel('bias criterion'); xlabel('C_F'); settings.alphaLabel='d'; cleanUpFigure(gca,settings)
subplot(2,4,8);  xlabel('C_F'); settings.alphaLabel='e'; cleanUpFigure(gca,settings) %ylabel('bias criterion');
set(gcf,'Position',[-2 133 1043 510])


%% alpha
figure

p=detectionModel('searchSearch_20100805T121258'); %basic, 234 w/ gaussVe & alpha: 1,0,fit, has power contrast
axisHandles=p.plotModelWithDistribution({'234-gaussVe-a_0','234-gaussVe-a_1','234-gaussVe-a_f'}) %alpha

settings=[];
for i=1:length(axisHandles)
    settings.alphaLabel=lower(char(64+i));
    axes(axisHandles(i));
    cleanUpFigure(axisHandles(i),settings);
end

aH=[1 5 9];
order=[2 1 3]
for i=1:length(aH)
    axes(axisHandles(aH(i)));
    alpha=p.cache.groupModelParams{order(i)}(1); % 1st is alpha
    text(.65,.45,['\alpha' sprintf('= %1.2f',alpha)])
end
cleanUpFigure
%% bias

modelIDs=[]
settings=[];
%p=detectionModel('searchSearch_20100801T122349'); %96x10
%modelIDs=[53 55 5 7]+1;

% p.modelName='searchSearch_20100805T093642'; p=p.load() % 48x10, now incompatible with current model rules
% nm={'234-gaussVe-a_f-dn','234-gaussVe-a_f-b_cost-dn','231-gaussVe-a_f-dn','231-gaussVe-a_f-b_cost-dn'}
% for i=1:4
%     modelIDs(i)=strmatch(nm{i},p.cache.groupModelNames)
% end

p=detectionModel('searchSearch_20100820T034322'); %bias comparison x40 
modelIDs=[3 4 1 2];


%%
figure;
for i=1:4
    subplot(2,2,i);
    p=ifDataNotThereLoadFromServerAndFillCache(p,p.getSubjectsNamesFromModelStr(p.cache.groupModelNames{modelIDs(i)}))
    p.viewModel(true,'',p.cache.groupModelFeatures{modelIDs(i)},p.cache.groupModelParams{modelIDs(i)},1,0);
    xlabel(''); ylabel(''); set(gca,'xtick',[],'ytick',[])
    if ismember(i,[2 4])
        b=p.cache.groupModelParams{modelIDs(i)}(4); % 4th ine is bias
    else
        b=0;
    end
    text(.65,.45,sprintf('b= %1.2f',b))
    settings.alphaLabel=lower(char(64+i));
    cleanUpFigure(gca,settings)
end
subplot(2,2,3)
xlabel('false alarms rate'); ylabel('hit rate'); set(gca,'xtick',[0 1],'ytick',[0 1])

subplot(2,2,1); title('subject 1 - no bias')
subplot(2,2,2); title('subject 1 - with bias')
subplot(2,2,3); title('subject 2 - no bias')
subplot(2,2,4); title('subject 2 - with bias')
cleanUpFigure
%% pdf

p=detectionModel('searchSearch_20100810T145838'); % 48x2, use LLR, no bug
n.alpha={'fit'}; 
n.bias={'cost'}; 
n.var={'scales'};
n.pdf={'gaussVe','gaussVs','exp','gam','logn'}  
n.gamma={'yoked'};
n.plus={'dn'};

n.subjects={'234','231'};
%subplot(2,1,1); title('subject 1') 
p.modelCompareForPoster(p.getSearchSearchModelNames(n))


n.pdf={'gaussVe'}%'gaussVs','gam'}  
p=detectionModel('searchSearch_20100813T023729'); % 10x10, use LLR, no bug
p.modelCompareForPoster(p.getSearchSearchModelNames(n),[],0,1)



% n.subjects={'231'};
% %subplot(2,1,2); title('subject 2')
% p.modelCompareForPoster(p.getSearchSearchModelNames(n))

%% parameter compare -Vs
close all
p=detectionModel('searchSearch_20100813T023729'); % 10x10, use LLR, no bug
values=p.parameterErrorbars('231-gaussVs-a_f-b_cost-dn')
set(gca,'ylim',[-.5 10],'xtick',[1:8],'xtick',[],'xticklabel',[])


modelID=find(strcmp(p.cache.namesOfModels,'231-gaussVs-a_f-b_cost-dn'));
featureNames=p.cache.groupModelFeatures{modelID}
nm=p.getSymbolNames(featureNames);
value=median(values)
for i=1:length(nm)
    text(i,-1.5,nm{i},'HorizontalAlignment','center')
    text(i,-2.2,num2str(value(i),'%4.2f'),'HorizontalAlignment','center')
end
%% parameter compare -Ve 231
close all
p=detectionModel('searchSearch_20100816T145446');  %231dnx10x50
values=p.parameterErrorbars;
set(gca,'ylim',[-.5 10],'xticklabel',[])

nm=p.getSymbolNames(p.modelFeatures);
value=median(values);
for i=1:length(nm)
    text(i,-1.5,nm{i},'HorizontalAlignment','center')
    text(i,-2.2,num2str(value(i),'%4.2f'),'HorizontalAlignment','center')
end

%%
p=detectionModel('searchSearch_20100813T193828'); % 10x10, use LLR, no bug
p.modelCompareForPoster({'234-gaussVe-a_f'},[],0)

%% check good model
close all
figure
p=detectionModel('searchSearch_20100814T141515');  %234dnx10x50
p.modelCompareForPoster({'234-gaussVe-a_f-b_cost-dn'},[],0,0)

p=detectionModel('searchSearch_20100816T145446');  %231dnx10x50
p.modelCompareForPoster({'231-gaussVe-a_f-b_cost-dn'},[],0,0)
%set(gca,'ylim',[-5 40])

%% best models viewed
p=detectionModel('searchSearch_20100814T141515');  %234dnx10x50
subplot(1,2,1); values=p.parameterErrorbars;
set(gca,'ylim',[-0.5 7],'xticklabel',[])
ylabel('parameter value')

nm=p.getSymbolNames(p.modelFeatures);
value=median(values);
%value=p.constrainValues(p.cache.modelParams',p.modelFeatures,1)
for i=1:length(nm)
    text(i,-1.5,nm{i},'HorizontalAlignment','center')
    text(i,-2.0,num2str(value(i),'%4.2f'),'HorizontalAlignment','center')
end

p=detectionModel('searchSearch_20100816T145446');  %231dnx10x50
subplot(1,2,2); values=p.parameterErrorbars;
set(gca,'ylim',[-0.5 7],'xticklabel',[])

nm=p.getSymbolNames(p.modelFeatures);
value=median(values);
%value=p.constrainValues(p.cache.modelParams',p.modelFeatures,1)
for i=1:length(nm)
    text(i,-1.5,nm{i},'HorizontalAlignment','center')
    text(i,-2.0,num2str(value(i),'%4.2f'),'HorizontalAlignment','center')
end

%% check error
values=p.constrainValues(p.cache.groupModelParamsHistory{modelID},p.cache.groupModelFeatures{modelID},0);


%% scatter-correlation of params
figure
p=detectionModel('searchSearch_20100814T141515');  %234dnx10x50
subplot(2,2,1); [t f]=p.parameterScattergram([],[2 3]); %axis([0 6 0 6]); 
w1=t./f; %w1(w1<0)=[];
subplot(4,2,5); e=linspace(1,8,20); hist(w1,e)
%p.parameterScattergram([],[4 5])
xlabel('\mu_T / \mu_F')

p=detectionModel('searchSearch_20100816T145446');  %231dnx10x50
subplot(2,2,2); [t f]=p.parameterScattergram([],[2 3]); %axis([0 6 0 6])
w2=t./f; w2(w2<0)=nan;

subplot(4,2,7); e=linspace(1,8,20); hist(w2,e)
xlabel('\mu_T / \mu_F')
%p.parameterScattergram([],[4 5])


subplot(2,2,4); 
plot([.5 2.5],[1 1],'k');  hold on
ylabel('\mu_T / \mu_F')
cleanUpFigure
b=boxplot([w1 w2],{'s1','s2'},'color',[0 0 0]);
set(b,'MarkerEdgeColor',[1 1 1])
set(gca,'ylim',[0 5],'ytick',[0:5])
%% FA signif
p=detectionModel('searchSearch_20100814T141515');  %234dnx10x50
p=detectionModel('searchSearch_20100816T145446');  %231dnx10x50
[data params]=p.getDataFromSubjectCache;
ind1=find(params.tcs==0.25 & params.fcs==0);
ind2=find(params.tcs==1 & params.fcs==0);
n1=data.numNoSig(ind1);
n2=data.numNoSig(ind2);
x1=data.numCRs(ind1);
x2=data.numCRs(ind2);
[delta CI]=diffOfBino(x1,x2,n1,n2,'agrestiCaffo',0.05)
[delta CI]=diffOfBino(x1,x2,n1,n2,'agrestiCaffo',0.01)
[delta CI]=diffOfBino(x1,x2,n1,n2,'agrestiCaffo',0.00001)

%% the ones shown
p.modelCompareForPoster({'234-gaussVe-a_0','234-gaussVe-a_f','234-gaussVe-a_f-dn','234-gaussVe-a_f-b_cost-dn',...
    '231-gaussVe-a_0','231-gaussVe-a_f','231-gaussVe-a_f-dn','231-gaussVe-a_f-b_cost-dn'}) %'234-gaussVe-a_0',
%%  distribution
figure
modelID=88; %56 8 88
noiseColor=[0 0 0];
signalColor=[.8 0 0]
p.plotDistributions([],[],p.cache.groupModelFeatures{modelID},p.cache.groupModelParams{modelID},noiseColor,signalColor)

for i=1:20
   subplot(4,5,i);
   set(gca,'xtick',[],'ytick',[],'xlim',[-3 5]); 
   axis([0 10 0 .6]) % for gam
   xlabel('')
end
cleanUpFigure
%% 
%p=detectionModel('searchSearch_20100729T103420'); %basic, 234 w/ gaussVe & alpha: 1,0,fit, has power contrast
%'searchSearch_20100728T134944'; %basic, 234 w/ gaussVe & alpha: 1,0,fit
%p=detectionModel('searchSearch_20100729T104405'); % 234, 3 pdfs: Vi,Vs, gam
%p=detectionModel('searchSearch_20100729T125010'); % 234, 3 dn pdfs: Ve,Vs, gam
%p.modelName='searchSearch_20100729T131352'; p=p.load() %231 3 pdfs: Ve,Vs, gam  all w/ dn
p=detectionModel('searchSearch_20100801T122349'); %96x10
p.plotModelWithDistribution({'234-gaussVe-a_f-b_cost-dn','231-gaussVe-a_f-dn','231-gaussVe-a_f-b_cost-dn',}) %why bias helps
p.plotModelWithDistribution({'231-gam-a_f-b_cost-dn','234-gaussVe-a_f-b_cost-dn','234-gam-a_f-b_cost-dn'})
p.plotModelWithDistribution({'234-gaussVe-a_f-b_cost','234-gaussVe-a_f-b_cost-dn','231-gaussVe-a_f-b_cost-dn'})
cleanUpFigure
set(gcf,'Position',[209   280   980   818])

%% browsing
figure; modelID=56; % 8 55 56
p.cache.groupModelFeatures{modelID}
x=p.cache.groupModelParams{modelID};
%x(3)=0; %fm;  --> curved grid becomes a curved line
%x(7)=-1000 %falloff
x(4)=-.25 %bias
p.viewModel(true,'',p.cache.groupModelFeatures{modelID},x,true,true);

%% more browsing
p.plotModelWithDistribution({'234-gaussVe-a_0-b_cost-dn','231-gaussVe-a_0-b_cost-dn','234-gaussVe-a_f-b_cost-dn','231-gaussVe-a_f-b_cost-dn'})
p.plotModelWithDistribution({'234-gam-a_0-b_cost-dn','231-gam-a_0-b_cost-dn','234-gam-a_f-b_cost-dn','231-gam-a_f-b_cost-dn'})

%% see the range of fallOff
p=detectionModel('searchSearch_20100801T122349'); %96x10
n=length(p.cache.namesOfModels);
fallOff=nan(1,n);
for i=1:n
    fInd=find(strcmp('fallOff',p.cache.groupModelFeatures{i}));
    if ~isempty(fInd)
        fallOff(i)=1/(1+exp(p.cache.groupModelParams{i}(fInd)));
    end
end

figure; hist(fallOff)
%% plot fallOff2sigma
%p=detectionModel('searchSearch_20100801T122349'); %96x10 OLD
%p=detectionModel('searchSearch_20100804T175103'); %dn234 no x2 yet
p.modelName='searchSearch_20100805T093642'; p=p.load() % 48x10 
modelID=26;



th=pi/12;
sep=.3;
pT=[.1 999 pi/2 0 1 0.001 1/2 1/2]
pF=[.1 999 pi/2 0 1 0.001 .5-sep*sin(th) .5+sep*cos(th);
    .1 999 pi/2 0 1 0.001 .5+sep*sin(th) .5-sep*cos(th)];
t=computeGabors(pT,0,200,200,'square','normalizeVertical',1);
f=computeGabors(pF,0,200,200,'square','normalizeVertical',1);



x=p.cache.groupModelParams{modelID};
gamma=x(4);
c50=x(5);
fallOff=[1/(1+exp(-x(6))) 0.16];

sigmas=linspace(0.2,1.5,50);
for i=1:length(sigmas)
    pDN=pT;
    pDN(1)=sigmas(i);
    dn=computeGabors(pDN,0,200,200,'square','normalizeVertical',1);

    tc(i)=sum(dn(:).*t(:));
    fc(i)=sum(dn(:).*f(:))/2;
end
%plot(sigmas,tc,'b',sigmas,fc,'r')
lambda=fc./tc;
[er1 ind1]=min(abs(lambda-fallOff(1)))
[er2 ind2]=min(abs(lambda-fallOff(2)))
subplot(3,2,4)
pDN=pT; pDN(1)=sigmas(ind1);
dn=computeGabors(pDN,0,200,200,'square','normalizeVertical',1);
imagesc(t+f) %dn


w=2*pT(1)*200;
r=rectangle('Position', [200*[pF(1,7) pF(1,8)]-w/2 w w],'Curvature', [1 1],'EdgeColor',[.8 .8 .8 ])
r=rectangle('Position', [200*[pF(2,7) pF(2,8)]-w/2 w w],'Curvature', [1 1],'EdgeColor',[.8 .8 .8 ])
r=rectangle('Position', [200*[.5 .5]-w/2 w w],'Curvature', [1 1],'EdgeColor',[.8 .8 .8 ])
w=2*sigmas(ind1)*200;
r=rectangle('Position', [100-w/2 100-w/2 w w],'Curvature', [1 1],'EdgeColor',[.8 0 0 ])
w=2*sigmas(ind2)*200;
r=rectangle('Position', [100-w/2 100-w/2 w w],'Curvature', [1 1],'EdgeColor',[.8 .8 0 ])

set(gca,'xtick',[],'ytick',[])
axis square

subplot(3,2,3)
plot(sigmas,lambda,'k'); hold on
plot([0 sigmas(ind1)],lambda([ind1 ind1]),'color',[.8 0 0])
plot(sigmas([ind1 ind1]),[0 lambda(ind1)],'color',[.8 0 0])
plot([0 sigmas(ind2)],lambda([ind2 ind2]),'color',[.8 .8 0])
plot(sigmas([ind2 ind2]),[0 lambda(ind2)],'color',[.8 .8 0])
%set(gca,'xtick',[0 sigmas(ind1) 1 2],'ytick',[0 lambda(ind1) 1])
set(gca,'xtick',[0  5 10 15]*pT(1),'ytick',[0 1],'xticklabel',[0 5 10 15],'xlim',[0 1.5])
text(.05,lambda(ind1)+.05,[sprintf('%1.2f',fallOff(1))])
text(.05,lambda(ind2)+.05,[sprintf('%1.2f',fallOff(2))])
xlabel('\sigma_{DN} / \sigma_{stim}')
ylabel('\lambda = (A_{fc}/ A_{tc})')
axis square
cleanUpFigure


tcs=linspace(0,2,100);
flankerColors=customColorMap([0 .3 1], [ .1 .1 .9;  .6 .2 .5;  .8 .2 .2],5);
fcs=[0 .25 .5 .75 1]
for i=1:2
    subplot(3,2,i)
    for j=1:5
        tcsEff=tcs.^gamma./(c50+(tcs + 2*fallOff(i)*fcs(j)).^(gamma));
        plot(tcs,tcsEff,'color',flankerColors(j,:)); hold on;
        xlabel('C_t');   ylabel('C_t''');
        axis square
        axis([0 2 0 1])
        set(gca,'xtick',[],'ytick',[])
        text(1,.2,['\lambda= ' sprintf('%1.2f',fallOff(i))])
    end
end

subplot(3,2,5)
x=p.cache.groupModelParams{modelID};
p.viewModel(true,'',p.cache.groupModelFeatures{modelID},x,1,0);
text(.65,.45,['\lambda= ' sprintf('%1.2f',fallOff(1))])

subplot(3,2,6)
x(6)=-log((1/fallOff(2))-1); %inv sigmoid
p.viewModel(true,'',p.cache.groupModelFeatures{modelID},x,1,0);
text(.65,.45,['\lambda= ' sprintf('%1.2f',fallOff(2))])
    
settings=[];
for i=1:6
    subplot(3,2,i)
    settings.alphaLabel=lower(char(64+i));
    cleanupFigure(gca,settings)
end
colormap(gray)
%set(gcf,'Position',[685    93   663   981])

%% viewParamChange
figure
modelID=56; % 8 55 56
%changeParams={'tm','fm','alpha','bias'}; titleParam={'\mu_T','\mu_F','\alpha','bias'}; step=[1 1 .2 .2];
changeParams={'gamma','c50','fallOff'}; titleParam={'\gamma','C_{50}','\lambda'}; step=[.5 .2 1];
x=p.cache.groupModelParams{modelID};

n=length(changeParams)
signLabel={'-','+'};
for i=1:2
    for j=1:n
        subplot(2,n,n*(i-1)+j)
        fInd=find(strcmp(changeParams{j},p.cache.groupModelFeatures{modelID}))
        x2=x;
        x2(fInd)=x(fInd)+step(j)*sign(i-1.5);
        p.viewModel(true,'',p.cache.groupModelFeatures{modelID},x2,false,1);
        title(sprintf('%s%1.1f %s',signLabel{i},step(j),titleParam{j}))
        xlabel(''); ylabel(''); set(gca,'xtick',[],'ytick',[])
    end
end
subplot(2,n,1)
xlabel('false alarms rate'); ylabel('hit rate'); set(gca,'xtick',[0 1],'ytick',[0 1])
subplot(2,3,3); title('-0.1 \lambda'); subplot(2,3,6); title('+0.2 \lambda'); %sigmoid adj
%% just out of curiosity
figure(4)
subplot(2,2,1)
k=2;             k=1;
c=names.conditions;
arrows={c{1},c{6},k; c{6},c{11},k; c{11},c{16},k;...
    c{2},c{7},k; c{7},c{12},k; c{12},c{17},k;...
    c{3},c{8},k; c{8},c{13},k; c{13},c{18},k;...
    c{4},c{9},k; c{9},c{14},k; c{14},c{19},k;...
    c{5},c{10},k; c{10},c{15},k; c{15},c{20},k};
doHitFAScatter(stats,CI,names,params,[],[],0,0,0,0,0,1,arrows);

%%
set(3,'PaperSize',[3 3])
clear all
savePath='C:\Documents and Settings\rlab\Desktop\ccFigures';
allFigID=[3]
saveFigs(savePath,{'-dtiffn','png'},allFigID,900,{'-opengl'});
