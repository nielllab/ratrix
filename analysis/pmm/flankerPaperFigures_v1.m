


%path='C:\Documents and Settings\rlab\Desktop\tempAnalysis'; % a temp directory okay to make files
%cd(path)

%%
%relevantRatrix='\\reinagel-lab.ad.ucsd.edu\rlab\Rodent-Data\pmeier\xfer\db081013.mat';
relevantRatrix='\\reinagel-lab.ad.ucsd.edu\rlab\Rodent-Data\pmeier\xfer\db081130.mat';
load(relevantRatrix)

%r=getRatrix


%% timeline
subject='234'
%f{1}.dateRange=[datenum('21-Jun-2008') datenum('19-Oct-2008')]
h(1)=figure;
subplot(2,1,1)
d=getSmalls(subject)
d=removeSomeSmalls(d,~ismember(d.step,[5 6 7 8 9]))
d=removeSomeSmalls(d,d.currentShapedValue >0.32)
dayBoundary=false;
doPlotPercentCorrect(d,[],200,0.75,[],[],dayBoundary,true,0,0,0,0)
set(gca,'YTick',[0.34,0.5 0.75 1])
set(gca,'YTickLabel',{'step:','50%','75%','100%'})
steps=unique(d.step);
nearestTrialNumberForGraduationMark=100; %100 or 1000 or 5000
for i=1:length(steps)
    firstTrialPerStep(i)=min(find(d.step==steps(i)))
    roundedTrialNumber(i)=round(firstTrialPerStep(i)/nearestTrialNumberForGraduationMark)*nearestTrialNumberForGraduationMark;
    dayPerStep(i)=floor(d.date(firstTrialPerStep(i))-d.date(1));
end
plot(get(gca,'XLim'),[.5 .5],'k--') % chance line
totalTrialNumber=floor(length(d.date)/nearestTrialNumberForGraduationMark)*nearestTrialNumberForGraduationMark;
xTick=[roundedTrialNumber([1 2]) totalTrialNumber]
set(gca,'XTick',xTick)
set(gca,'XTickLabel',xTick)
ylabel('% correct')
totalDays=floor(d.date(end)-d.date(1));
xlabel(sprintf('trial # (over %d days)',totalDays))
title('training performance')

%check this rat to see that he is the right kind of rat (no vertical early on) contrast

%% stims
%h(2)=figure;
subplot(2,1,2)
steps=[5 6 7 8 9 10];
%rtemp=ratrix(path,false)
%rtemp=setShapingPMM(rtemp,{'test'}, 'goToRightDetection', '2_3',[],false)
p=getProtocolAndStep(getSubjectFromID(r,'231'));

desiredX=600%500;
desiredY=600%800;
sx=1024;%1280;
sy=768;%1024;
padX=(sx-desiredX)/2; padY=(sy-desiredY)/2;
images=nan(desiredY,desiredX,1,length(steps));
for i=1:length(steps)
    sm=getStimManager(getTrainingStep(p,steps(i)));
    forceStimDetails.targetContrast=1;
    forceStimDetails.targetOrientation=pi/12;
    forceStimDetails.flankerOrientation=pi/12;
    forceStimDetails.flankerPosAngle=pi/12;
    [image details]= sampleStimFrame(sm,'nAFC',forceStimDetails,[3],sy,sx);
    %grab the thing in the centert
    center=image(1+padY:sy-padY,1+padX:sx-padX);
    images(:,:,1,i)=center;
end

montage(images,'DisplayRange',[0 255],'Size',[1 6]); % or [2 2] if
title('sample stimuli')
%%

sx=384;
sy=512;
[param]=getDefaultParameters(ifFeatureGoRightWithTwoFlank,'goToRightDetection','2_4','Oct.09,2007')
param.maxWidth    =sx;
param.maxHeight   =sy;
param.pixPerCycs  =16;
param.flankerContrast  =0.4;
param.flankerOffset=3;
param.stdGaussMask=1/16;
param.mean= 0.5;
param.phase= 0;
[step]=setFlankerStimRewardAndTrialManager(param, 'test')
sm=getStimManager(step);

desiredX=250;
desiredY=400;
padX=(sx-desiredX)/2; padY=(sy-desiredY)/2;
borderWidth=10;

or=pi/12;
torients=[-or or];
forients=[-or or];
tcontrasts=[0.8 0];
fpas=[-or or];
sizes=[2 2 2 2];
images=nan(desiredY,desiredX,3,16);%length(torients),length(forients),length(tcontrasts),length(fpas));
colors=[1 0 0; .6 1 1; .6 1 1; .3 .3 .3];
order=[1:8 fliplr(9:12) fliplr(13:16)];
for i=1:length(torients)
    forceStimDetails.targetOrientation=torients(i);
    for j=1:length(forients)
        forceStimDetails.flankerOrientation=forients(j);
        for k=1:length(tcontrasts)
            forceStimDetails.targetContrast=tcontrasts(k);
            for l=1:length(fpas)
                forceStimDetails.flankerPosAngle=fpas(l);

                %border color
                colorInd=2;
                if torients(i)==forients(j)
                    if torients(i)==fpas(l)
                        colorInd=1;% colin
                    else
                        colorInd=4;% para
                    end
                end

                [im0 details]= sampleStimFrame(sm,'nAFC',forceStimDetails,[3],sy,sx);
                %grab the thing in the center
                im1=uint8(255*repmat(reshape(colors(colorInd,:),[1 1 3]),[desiredY desiredX 1]));
                center=repmat(im0(1+padY+borderWidth:sy-padY-borderWidth,1+padX+borderWidth:sx-padX-borderWidth),[1 1 3]);
                im1(borderWidth+1:end-borderWidth,borderWidth+1:end-borderWidth,:)=center;

                %[i j k l]=ind2sub(sizes,ind);
                ind=sub2ind(sizes,i, j, k, l)
                ind=order(ind);
                images(:,:,:,ind)=im1;
                %                 imtool(im1)
                %                 pause
            end
        end
    end
end

images=uint8(images);
figure
montage(images,'DisplayRange',[0 255],'Size',[2 8]); % or [2 2] if
title('sample stimuli')

%%
figure
subplot(1,2,1)
montage(images(:,:,:,[5 1]),'DisplayRange',[0 255],'Size',[1 2]);
title('colinear example')
xlabel('left = no                   right = yes')

subplot(1,2,2)
montage(images(:,:,:,[1 3 2 4 9 11 10 12 ]),'DisplayRange',[0 255],'Size',[2 4]);
title('stimulus grouping')
set(gca,'xTick',diff(get(gca,'Xlim'))*[1:4]/5)
set(gca,'xTickLabel',diff(get(gca,'Xlim'))*[1:4]/5)
xlabel('col              po1                po2              par')
%set(gca,'xTickLabel',{'col','po1','po2','par'})

%%
figure
w=9; h=2
subplot(h,w,1); imagesc(images(:,:,1,2,1,1,1),[0 255])

%% get stats

subjects={'138','139','229','230','233','234','237'}
[stats CI names params]=getFlankerStats(subjects,'8flanks',{'pctCorrect'},'9.4',[1 datenum('19-Oct-2008')]); %[1 datenum('19-Oct-2008')]; % everything berore oct 19; %everything

if 0 % view factor breakout
    x=unique(cell2mat(struct2cell(params.factors)),'rows')
    figure;imagesc(x)
end
%% get ims
orient=pi/12; % note these images are for the go right rats
d=getSmalls('233');
d=removeSomeSmalls(d,d.step~=9 | d.flankerContrast~=0.4);
sweptParameters={'flankerOrientation','targetOrientation','flankerPosAngle','targetContrast','flankerContrast'}; % last variable entry must be targetContrast
sweptValues={orient*[-1 1],orient*[-1 1],orient*[-1 1],[0 1],[0.4]};
[images]=getStimSweep(r,d,sweptParameters,sweptValues);
[j1 j2 j3 colors]=getFlankerConditionInds(d,[],'8flanks');

%% bar pctCorrect one subject
c=params.raw.numCorrect(find(strcmp('233',names.subjects)),:);
a=params.raw.numAttempt(find(strcmp('233',names.subjects)),:);
figure; doBarPlotWithStims(a,c,images(9:16),colors,[50 100])


%% all subjects bar pctCorrect
figure;
X=ceil((length(subjects))/2); Y=2;
for i=1:length(subjects)
    subplot(X,Y,i); doBarPlotWithStims(params.raw.numAttempt(i,:),params.raw.numCorrect(i,:),images,colors,[50 100]);
    title(subjects{i})
end
subplot(X,Y,i+1); doBarPlotWithStims(sum(params.raw.numAttempt),sum(params.raw.numCorrect),images,colors,[50 100]);
title('all'); ylabel('pctCorrect')

%% all subjects bar pctCorrect collapsed conditions
figure;
a=[sum(params.raw.numAttempt(:,[1 8]),2) sum(params.raw.numAttempt(:,[2 3 6 7]),2)  sum(params.raw.numAttempt(:,[4 5]),2) ];
c=[sum(params.raw.numCorrect(:,[1 8]),2) sum(params.raw.numCorrect(:,[2 3 6 7]),2)  sum(params.raw.numCorrect(:,[4 5]),2) ];
c3=colors([1 2 4],:);
i3={images{[1 2 4]}};
X=ceil((length(subjects))/2); Y=2;
for i=1:length(subjects)
    subplot(X,Y,i); doBarPlotWithStims(a(i,:),c(i,:),i3,c3,[55 75]);
    title(subjects{i})
end
subplot(X,Y,i+1); doBarPlotWithStims(sum(a),sum(c),i3,c3,[55 75]);
title('all'); ylabel('pctCorrect')

%% compare across conditions types

[junk1 junk2 names params]=getFlankerStats(subjects,'8flanks',[],'9.4')
viewFlankerComparison(names,params)

%%
% prelumped conditions, only alligned phases, so less data
[junk1 junk2 names params]=getFlankerStats(subjects,'colin+3',[],'9.4')
viewFlankerComparison(names,params)


%%
subjects={'228', '227','138','139','230','233','234'}; %left and right, removed 229 274 231 232 too little data for 9.4., 237 maybe enough data, almost 5kTrials, outlier
[junk1 junk2 names params]=getFlankerStats(subjects,'8flanks',[],'9.4')
%viewFlankerComparison(names,params,[],[],{'138'})

%%
figure
hold on
plot([.5 1],[.5 1],'k')
for i=1:length(subjects)
    %target changes
    xInd=find(ismember(names.conditions,{'RRR'}));
    yInd=find(ismember(names.conditions,{'LRR'}));
    plot(stats(i,xInd,1),stats(i,yInd,1),'^k');

    xInd=find(ismember(names.conditions,{'LLL'}));
    yInd=find(ismember(names.conditions,{'RLL'}));
    plot(stats(i,xInd,1),stats(i,yInd,1),'ok');
    subjects{i}
end
xlabel('pctCorrect colinear')
ylabel('pctCorrect popout2')
axis([.5 1 .5 1])


%%

%%
figure
hold on
plot([.5 1],[.5 1],'k')
for i=1:length(subjects)
    %flanker changes
    xInd=find(ismember(names.conditions,{'RRR'}));
    yInd=find(ismember(names.conditions,{'RLR'}));
    plot(stats(i,xInd,1),stats(i,yInd,1),'^k');
    text(stats(i,xInd,1),stats(i,yInd,1),subjects{i});

    xInd=find(ismember(names.conditions,{'LLL'}));
    yInd=find(ismember(names.conditions,{'LRL'}));
    plot(stats(i,xInd,1),stats(i,yInd,1),'ok');
    text(stats(i,xInd,1),stats(i,yInd,1),subjects{i});
    subjects{i}
end
xlabel('pctCorrect colinear')
ylabel('pctCorrect popout1')
axis([.5 1 .5 1])

%%
figure
hold on
plot([.5 1],[.5 1],'k')
for i=1:length(subjects)
    %fpa changes
    xInd=find(ismember(names.conditions,{'RRR'}));
    yInd=find(ismember(names.conditions,{'RRL'}));
    plot(stats(i,xInd,1),stats(i,yInd,1),'^k');

    xInd=find(ismember(names.conditions,{'LLL'}));
    yInd=find(ismember(names.conditions,{'LLR'}));
    plot(stats(i,xInd,1),stats(i,yInd,1),'ok');
    subjects{i}
end
xlabel('pctCorrect colinear')
ylabel('pctCorrect parallel')
axis([.5 1 .5 1])

%%
figure
hold on
plot([.5 1],[.5 1],'k')
for i=1:length(subjects)
    %fpa changes
    xInd=find(ismember(names.conditions,{'RRR'}));
    yInd=find(ismember(names.conditions,{'LLR','LRR','RLR'}));
    plot(stats(i,xInd,1),mean(stats(i,yInd,1)),'^k'); %beware variable condition #!

    xInd=find(ismember(names.conditions,{'LLL'}));
    yInd=find(ismember(names.conditions,{'RRL','RLL','LRL'}));
    plot(stats(i,xInd,1),mean(stats(i,yInd,1)),'ok'); %beware variable condition #!
    subjects{i}
end
xlabel('pctCorrect colinear')
ylabel('pctCorrect other')
axis([.5 1 .5 1])


%% per orientation difference
%compare to fig 7 "sagi flankers filling in" (2006?)
% conclusion: change in hit rat is not large, nor FA
%(i thought it might be, b/c of 102's data)
% some of this might be related to the fact that fix has more changes in
% hit rate than fix (fig 2 sagi, though v/s distance no orientation)
% which is related to the idea that the subject sets a new criteria for a block
% of trials, rather than a shared criteria for all trials.
% 102 is not blocked, but hasd one global position AND
%102 has only vertical targets during his good data (for better analysis
%power).. but could explain as searching for that orientation (and not simply contrast at the known location)


subjects={'138','139','229','230','233','234','237'}; % right %229 has few samps on 9.4
[stats CI names params]=getFlankerStats(subjects,'8flanks',{'pctCorrect','dpr','hits','CRs','yes'},'9.4')

fpas={'L','R','both'}
for i=1:length(subjects)
    for j=1:length(fpas)
        sInd=find(strcmp(subjects(i),names.subjects));
        relOrient=unique(abs(params.factors.targetOrientation(sInd,:)-params.factors.flankerOrientation(sInd,:)))*180/pi;

        fpa=fpas{j};
        switch fpa
            case 'both'
                h(1)=mean(stats(sInd,find(ismember(names.conditions,{'RRR','LLL'})),find(strcmp('hits',names.stats))));
                h(2)=mean(stats(sInd,find(ismember(names.conditions,{'RLR','LRL'})),find(strcmp('hits',names.stats)))); %change flanker
                fa(1)=1-mean(stats(sInd,find(ismember(names.conditions,{'RRR','LLL'})),find(strcmp('CRs',names.stats))));
                fa(2)=1-mean(stats(sInd,find(ismember(names.conditions,{'RLR','LRL'})),find(strcmp('CRs',names.stats))));
                c(1)=mean(stats(sInd,find(ismember(names.conditions,{'RRR','LLL'})),find(strcmp('pctCorrect',names.stats))));
                c(2)=mean(stats(sInd,find(ismember(names.conditions,{'RRR','LLL'})),find(strcmp('pctCorrect',names.stats))));
            case 'R'
                h(1)=stats(sInd,find(ismember(names.conditions,{'RRR'})),find(strcmp('hits',names.stats)));
                h(2)=stats(sInd,find(ismember(names.conditions,{'RLR'})),find(strcmp('hits',names.stats))); %change flanker
                fa(1)=1-stats(sInd,find(ismember(names.conditions,{'RRR'})),find(strcmp('CRs',names.stats)));
                fa(2)=1-stats(sInd,find(ismember(names.conditions,{'RLR'})),find(strcmp('CRs',names.stats)));
                c(1)=stats(sInd,find(ismember(names.conditions,{'RRR'})),find(strcmp('pctCorrect',names.stats)));
                c(2)=stats(sInd,find(ismember(names.conditions,{'RLR'})),find(strcmp('pctCorrect',names.stats))); %change flanker
            case 'L'
                h(1)=stats(sInd,find(ismember(names.conditions,{'LLL'})),find(strcmp('hits',names.stats)));
                h(2)=stats(sInd,find(ismember(names.conditions,{'LRL'})),find(strcmp('hits',names.stats))); %change flanker
                fa(1)=1-stats(sInd,find(ismember(names.conditions,{'LLL'})),find(strcmp('CRs',names.stats)));
                fa(2)=1-stats(sInd,find(ismember(names.conditions,{'LRL'})),find(strcmp('CRs',names.stats)));
                c(1)=stats(sInd,find(ismember(names.conditions,{'LLL'})),find(strcmp('pctCorrect',names.stats)));
                c(2)=stats(sInd,find(ismember(names.conditions,{'LRL'})),find(strcmp('pctCorrect',names.stats))); %change flanker
        end

        %figure
        title(subjects(i))
        subplot(3,3,i)
        plot(relOrient,h,'k')
        hold on
        plot(relOrient,fa,'g')
        plot(relOrient,c,'b')
        axis([-10 90 0 1])
    end
end

subplot(3,3,i+1);
plot([0 0],h,'k')
hold on
plot([0 0],c,'b')
plot([0 0],fa,'g')
title('just legend')
legend({'hit','correct','FA'})

%%

subjects={'138','139','230','233','234','237'}; % right %removed 229 has few samps on 9.4
subjects={ '228', '227','138','139','230','233','234'};%,'237'}; %left and right, removed 229 274 231 232 too little data for 9.4.,
dateRange=[];%[datenum('21-Jun-2008') now]
[stats CI names params]=getFlankerStats(subjects,'8flanks',{'pctCorrect','hits','CRs','yes'},'9.4',dateRange)
viewFlankerComparison(names,params)


%%
cMatrix={[1 8],[2 7]}; %across flankers
[stats CI names params]=getFlankerStats(subjects,'8flanks',{'pctCorrect','hits','CRs','yes'},'9.4',dateRange)
viewFlankerComparison(names,params, cMatrix)
%if only changing the target (comparison #2) why is there significant
%difference in correctRejects (which has no target) -- fixed now


[stats CI names params]=getFlankerStats(subjects,'8flanks',{'pctCorrect'},'9.4',dateRange)
viewFlankerComparison(names,params, cMatrix)
cleanupfigure(gcf)


[stats CI names params]=getFlankerStats(subjects,'8flanks',{'hits', 'CRs'},'9.4',dateRange)
viewFlankerComparison(names,params, cMatrix)
cleanupfigure(gcf)

%% check phase
subjects={'136','137'};%136 & 137 effect of phase on goToSide
% d=getSmalls('137')
% datestr(d.date(min(find(abs(d.targetContrast-0.6)<10^-9))),22)
% datestr(d.date(max(find(abs(d.targetContrast-0.6)<10^-9))),22)
% dateRange=[datenum('Aug.06,2008') datenum('Nov.06,2008')];%when 137 was on 0.6 target contrast
% dateRange=[datenum('Aug.01,2008') datenum('Nov.30,2008')];%when 137 was on 0.6 target contrast
dateRange=[datenum('Aug.07,2008') datenum('Nov.05,2008')];% acceptable for 136/ 137
% d=getSmalls('136',dateRange); unique(d.targetContrast)
% d=getSmalls('137',dateRange); unique(d.targetContrast)
[stats CIs names params]=getFlankerStats(subjects, 'allPhases',{'dpr','pctCorrect','yes','hits','CRs'},'X.4',dateRange);

%%
%population first
f=figure;
a=(params.raw.numAttempt(:,:));
c=(params.raw.numCorrect(:,:));
doBarPlotWithStims(sum(a),sum(c),[],params.colors,[]); %all subjects
title('all'); ylabel('pctCorrect')

figure; doBarPlotWithStims(a(1,:),c(1,:),[],params.colors,[50 70]); %one subject
figure; doBarPlotWithStims(a(2,:),c(2,:),[],params.colors,[50 70] ); %other subject
figure; surf(reshape(c(1,:)./a(1,:),4,4))

%% consider relative phases on go to side rats
[stats CIs names params]=getFlankerStats(subjects, '3phases',{'pctCorrect'},'X.4',dateRange); %no stats have effect: 'dpr','yes','hits','CRs'
cMatrix={[1],[2]}; %same vs. reverse phase
viewFlankerComparison(names,params, cMatrix)

a=(params.raw.numAttempt(:,:));
c=(params.raw.numCorrect(:,:));
figure;doBarPlotWithStims(sum(a),sum(c),[],params.colors,[]); %all subjects
figure; doBarPlotWithStims(a(1,:),c(1,:),[],params.colors,[50 70]); %one subject
figure; doBarPlotWithStims(a(2,:),c(2,:),[],params.colors,[50 70] ); %other subject

%% consider relative phases other rats
subjects={'228', '227','138','139','230','233','234'}; %left and right, removed 229 274 231 232 too little data for 9.4., 237 maybe enough data, almost 5kTrials, outlier
[stats CIs names params]=getFlankerStats(subjects, 'colin-other',{'pctCorrect'},'X.4');
cMatrix={[1],[2]}; %same vs. reverse phase
viewFlankerComparison(names,params, cMatrix)

a=(params.raw.numAttempt(:,:));
c=(params.raw.numCorrect(:,:));
figure;doBarPlotWithStims(sum(a),sum(c),[],params.colors,[]); %all subjects
%--> no effect (TINY insigificant effect)
figure;doBarPlotWithStims(a(4,:),c(4,:),[],params.colors,[]); %139
%--> the only 'effect' is CRs on 139, but that must be noise b/c rel phase
%cant influence when no target present

%% Look at MCMC Stats
subjects={'228', '227','138','139','230','233','234'}; %left and right, removed 229 274 231 232 too little data for 9.4., 237 maybe enough data, almost 5kTrials, outlier
[stats CIs names params]=getFlankerStats(subjects, '8flanks+',{'dpr','dprimeMCMC', 'pctCorrect','yes','hits','CRs','criterionMCMC', 'biasMCMC'});
%[stats junk2 names params]=getFlankerStats({'228','227'}, '8flanks+',{'dpr','yes'});
%change flank
cMatrix={[1],[2]; %left global
    [8],[7];   %right global
    [9],[10]}; %merged
viewFlankerComparison(names,params,cMatrix,{'dprimeMCMC', 'pctCorrect'});

%change target
cMatrix={[1],[3]; %left global
    [8],[6];   %right global
    [9],[11]}; %merged
viewFlankerComparison(names,params,cMatrix);

%colin-para
cMatrix={[1],[4]; %left global
    [8],[5];   %right global
    [9],[12]}; %merged
viewFlankerComparison(names,params,cMatrix);

%colin-other
cMatrix={[9],[13]};
viewFlankerComparison(names,params,cMatrix);

%colin-other
cMatrix={[9],[12]};
viewFlankerComparison(names,params,cMatrix,{'pctCorrect'});

%% explanation stages

%bar graph: dead as a nail easy
p=100*stats(strcmp('234',names.subjects),find(ismember(names.conditions,{'colin','changeFlank','para'})),find(strcmp('pctCorrect',names.stats)));
ci= 100*CIs(strcmp('234',names.subjects),find(ismember(names.conditions,{'colin','changeFlank','para'})),find(strcmp('pctCorrect',names.stats)),[1:2])
ci=reshape(ci(:),3,2);
f=figure;
doBarPlotWithStims(p,ci,[],[1 0 0; 0 1 1; .6 .6 .6],[50 75],'stats&CI',false)
cleanUpFigure(f)
%ci=[stat; stat]+[-1; 1]*std(p)

%%
%population first
f=figure;
a=(params.raw.numAttempt(:,[9 10 11 12]));
c=(params.raw.numCorrect(:,[9 10 11 12]));
c3=[1 0 0; 0 1 1; 0 1 1; 0 0 0];
doBarPlotWithStims(sum(a),sum(c),[],c3,[55 65]);
title('all'); ylabel('pctCorrect')


%population first
f=figure;
a=(params.raw.numAttempt(:,[9 10 12]));
c=(params.raw.numCorrect(:,[9 10 12]));
c3=[1 0 0; 0 1 1;  0 0 0];
doBarPlotWithStims(sum(a),sum(c),[],c3,[50 75]);
title('all'); ylabel('pctCorrect')
cleanUpFigure(f)


%performance effect holds for both measures
cMatrix={[9],[10]}; %merged
[delta CI deltas CIs]=viewFlankerComparison(names,params,cMatrix,{'pctCorrect','dprimeMCMC'});
cleanUpFigure(gcf)


%bias effect holds for both measures
cMatrix={[9],[10]}; %merged
viewFlankerComparison(names,params,cMatrix,{'yes','criterionMCMC'});
%--> popout induces more yes responses

%bias is present for
cMatrix={[9],[10];
    [9],[11];
    [9],[12];
    [9],[13]}; %merged
[delta CI deltas CIs]=viewFlankerComparison(names,params,cMatrix,{'yes'});
%--> popout induces more yes responses


%% enhancedCompile

fieldNames={'trialNumber',{''};...
    'date',{''};...
    'response',{''};...
    'correct',{''};...
    'step',{''};...
    'correctionTrial',{'stimDetails','correctionTrial'};...  odd one b/c its still in stim details now
    'maxCorrectForceSwitch',{'stimDetails','maxCorrectForceSwitch'};... odd one b/c its still in stim details now
    'responseTime',{''};...
    'actualRewardDuration',{'actualRewardDuration'};...
    'manualVersion',{'protocolVersion','manualVersion'};...
    'autoVersion',{'protocolVersion','autoVersion'};...
    'didStochasticResponse',{'didStochasticResponse'};...
    'containedForcedRewards',{'containedForcedRewards'};...
    'didHumanResponse',{'didHumanResponse'};...
    ...enhanced
    'numRequestLicks',{''};...
    'firstILI',{''};...
    ...%pmm  fields...
    'correctResponseIsLeft',{'stimDetails','correctResponseIsLeft'};...
    'targetContrast',{'stimDetails','targetContrast'};...
    'targetOrientation',{'stimDetails','targetOrientation'};...
    'flankerContrast',{'stimDetails','flankerContrast'};...
    'flankerOrientation',{''};...
    'deviation',{'stimDetails','deviation'};...
    'targetPhase',{'stimDetails','targetPhase'};...
    'flankerPhase',{'stimDetails','flankerPhase'};...
    'currentShapedValue',{'stimDetails','currentShapedValue'};...
    'pixPerCycs',{'stimDetails','pixPerCycs'};...
    'redLUT',{'stimDetails','redLUT'};...
    'stdGaussMask',{'stimDetails','stdGaussMask'};...
    'flankerPosAngle',{'stimDetails','flankerPosAngle'};...
    };
compileTrialRecords([],fieldNames,false,,getSubDirForRack(1),getCompiledDirForRack(-1))


%% see reaction time differences
subjects={'139','227','228','231','232','229','230','233','234','237','278'} %more; corrupt. '138',  maybe different shaping for 9.4; '274'
%subjects={'138','139','229','230','233','234','237'} %main; 
subjects={'228', '227','230','233','234','139','138'};%sorted for amount of data

figure
for j=1:length(subjects)
    d=filterFlankerData(getSmalls(subjects{j},[],-1),'9.4');
    subplot(3,3,j); title(subjects(j))
    [mnResp stdResp ciResp]=getResponseStats(d,getGoods(d),{'misses','CRs','hits','FAs'},[0.01 10],true);
    %[mnResp stdResp medResp ciResp]=getResponseStats(d,getGoods(d),{'yes','no'},[0.01 10],true);
    if ifYesIsLeftRat(subjects{j}); text(30,.04,'Y=L'); else; text(30,.04,'Y=R'); end
end

% most rats say yes faster than no
%% we can reveal this speedy yes with the time to the first 10% or responses or some metric of the pdf of responses

subjects={'228', '227','230','233','234','139','138'};%sorted for amount of data
categories={'yes','no'};% {'misses','CRs','hits','FAs'}
figure
for j=1:length(subjects)
    d=filterFlankerData(getSmalls(subjects{j},[],-1),'9.4');
    subplot(3,3,j); title(subjects(j))
    %[mnResp stdResp ciResp]=getResponseStats(d,getGoods(d),{'misses','CRs','hits','FAs'},[0.01 10],true);
    [mnResp(j,1:2) stdResp fastestResp(j,1:2) ciResp c raw]=getResponseStats(d,getGoods(d),categories,[0.01 10],true);
    if ifYesIsLeftRat(subjects{j}); text(30,.04,'Y=L'); else; text(30,.04,'Y=R'); end
    fastDur=[1];
    fastYes(j)=sum(raw.yes<fastDur)./length(raw.yes);
    fastNo(j)=sum(raw.no<fastDur)./length(raw.no);

end
yesIndex=(fastYes-fastNo)./((fastYes+fastNo)/2);
figure;subplot(2,1,1);plot(fastYes); hold on; plot(fastNo,'r'); xlabel('rat'); title(sprintf('fraction of responses faster than %d sec',fastDur)); ylabel('frac'); legend(categories)
subplot(2,1,2);plot(yesIndex);  xlabel('rat'); title('yes is faster metric (true if > 0)'); ylabel('yesFrac-noFrac/((yesFrac-noFrac)/2)');

figure;plot(medResp); xlabel('rat'); title('fastest 10% of responses'); ylabel('seconds'); legend(categories)
%%
subjects={'139','229','230','233','234','237'} %main; '138'
subjects={'228', '227','230','233','234','139','138'};%sorted for amount of data
conditions={'colin','changeFlank','changeTarget','para'}
categories={'misses','CRs','hits','FAs'}

figure
for j=1:length(subjects)
    d=filterFlankerData(getSmalls(subjects{j},[],-1),'9.4');
    [condInd names jnk colors]=getFlankerConditionInds(d,getGoods(d),'8flanks+');
    for i=1:length(conditions)
        cInd=find(strcmp(conditions{i},names));
        [mnResp stdResp medResp ciResp jn raw]=getResponseStats(d,condInd(cInd,:),categories,[0.01 10],false);
        for k=1:length(categories)
            subplot(length(categories),length(subjects),(k-1)*length(subjects)+j)  
            hold on;
            text(0,0,num2str((k-1)*length(subjects)+j))
            plot(histc(raw.(categories{k}),[0:.2:5])./length(raw.(categories{k})),'color',colors(cInd,:))
        end
    end
end

%-->within  category, there is no stimulus difference

%% nothing interesting in the fast responses across conditions

subjects={'228', '227','230','233','234','139',};%sorted for amount of data.  corrupt:'138'
[stats CI names params] =getFlankerStats(subjects,'colin+3',{'RT'},'9.4',[1 now]);
 [delta CI deltas CIs]=viewFlankerComparison(names,params)
 
%% compare the effect, only looking at fast responses or not

subjects={'228', '227','230','233','234','139',};%sorted for amount of data.  corrupt:'138'
[stats CI names params] =getFlankerStats(subjects,'colin+3',[],'9.4',[1 now]);
 [delta CI deltas CIs]=viewFlankerComparison(names,params)

filter{1}.type='9.4';
filter{2}.type='responseSpeed';
filter{2}.parameters.range=[1 2]; %seconds
[stats CI names params] =getFlankerStats(subjects,'colin+3',[],filter,[1 now]);
 [delta CI deltas CIs]=viewFlankerComparison(names,params)
 
 % interesting!  the effect is not present for very slow trials, or very fast ones
 % two ideas:  filter performance and effect size based on  a time filter,
 
%%

filter{1}.type='9.4';
filter{2}.type='responseSpeed';
    
dur=.5; %sec
timeRanges=[.5:.1:3]; 
timeRanges(2,:)=timeRanges+dur;
deltas=[]; CI=[]; stats=[]; effect=[];
for i=1:length(timeRanges)
    filter{2}.parameters.range=timeRanges(:,i); %seconds
    [stats(:,:,i) pCI(:,:,:,i) names params]=getFlankerStats(subjects,'colin+3',{'pctCorrect'},filter,[1 now]);
    [effect(i) CI(:,:,:,i) deltas(:,:,:,i) CIs(:,:,:,:,i)]=viewFlankerComparison(names,params,{[1],[2]});
end
mnPerf=reshape( mean(stats(:,[1 2],:)) ,[2 length(timeRanges)] );

maxT=max(timeRanges(:));
mnTime=mean(timeRanges);
figure
subplot(2,1,1); plot(mnTime,mnPerf(1,:),'color',[1 0 0]); hold on; plot(mnTime,mnPerf(2,:),'color',[0 1 1]);
axis([0 maxT .5 .75]); ylabel('% correct'); xlabel('responseTime');legend({'colin','pop1'})
plot([timeRanges(:,1)],[.55 .55],'k')
subplot(2,1,2); plot(mnTime,effect,'r'); hold on; plot([0 maxT],[0 0],'k'); axis([0 maxT -10 10]);  ylabel('% effect');
for i=1:length(timeRanges)
    subplot(2,1,2);
    plot([mnTime(i) mnTime(i)],[CI(1,1,1,i) CI(1,1,2,i)],'r') % CI
    plot(repmat(mnTime(i),[1 length(subjects)]),reshape(deltas(1,1,:,i),[1 length(subjects)]),'k.') % CI
end

% conclusion:  [.5 2] is a good filter

%%  check the same thing with percentiles for rats
subjects={'228', '227','230','233','234','139',};%sorted for amount of data.  corrupt:'138'
filter{1}.type='9.4';
filter{2}.type='responseSpeedPercentile';
    
dur=.3; %  actually percentile width
timeRanges=[0:.05:1-dur]; % these are not times anymore...
timeRanges(2,:)=timeRanges+dur;
deltas=[]; CI=[]; stats=[]; effect=[];
for i=1:length(timeRanges)
    filter{2}.parameters.range=timeRanges(:,i); %percentile
    [stats(:,:,i) pCI(:,:,:,i) names params]=getFlankerStats(subjects,'colin+3',{'pctCorrect'},filter,[1 now]);
    [effect(i) CI(:,:,:,i) deltas(:,:,:,i) CIs(:,:,:,:,i)]=viewFlankerComparison(names,params,{[1],[3]});
end
mnPerf=reshape( mean(stats(:,[1 3],:)) ,[2 length(timeRanges)] );

maxT=max(timeRanges(:));
mnTime=mean(timeRanges);
figure
subplot(2,1,1); plot(mnTime,mnPerf(1,:),'color',[1 0 0]); hold on; plot(mnTime,mnPerf(2,:),'color',[0 1 1]);
ylabel('% correct'); xlabel('responseTime Percentile'); legend({'colin','pop1'})
hold on; plot([timeRanges(:,1)],[.55 .55],'k')
subplot(2,1,2); plot(mnTime,effect); hold on; plot([0 maxT],[0 0],'k'); axis([0 maxT -10 10]);  ylabel('% effect');
for i=1:length(timeRanges)
    subplot(2,1,2);
    plot([mnTime(i) mnTime(i)],[CI(1,1,1,i) CI(1,1,2,i)],'b') % CI
    plot(repmat(mnTime(i),[1 length(subjects)]),reshape(deltas(1,1,:,i),[1 length(subjects)]),'k.') % CI
end

% conclusion:  [0 .5] is a good filter for percentile
%%

filter{1}.type='9.4';
filter{2}.type='responseSpeed';
filter{2}.parameters.range=[.5 2.0]; %seconds
[stats CI names params] =getFlankerStats(subjects,'8flanks+',{'pctCorrect','hits','CRs'},filter,[1 now]);
 [delta CI deltas CIs]=viewFlankerComparison(names,params)
 
 
filter{1}.type='9.4';
filter{2}.type='responseSpeedPercentile';
filter{2}.parameters.range=[0 .5]; %percentile
[stats CI names params] =getFlankerStats(subjects,'8flanks+',{'pctCorrect','hits','CRs'},filter,[1 now]);
 [delta CI deltas CIs]=viewFlankerComparison(names,params)
 
 % conclusion: percentile seems to be a better filter for preserving the
 % effect
 
% next: don;t know why this errors, something wrong about CI size maybe?
doHitFAScatter(stats,CI,names,params)
 
%% SIDE BY SIDE COMPARE INFLUENCE OF FILTER

diffEdges=[-6:6];
cMatrix={[9],[10]};

figure
subplot(1,3,1)
filter{1}.type='9.4';
filter{2}.type='responseSpeedPercentile';
filter{2}.parameters.range=[0 1]; %percentile
[stats CI names params] =getFlankerStats(subjects,'8flanks+',{'pctCorrect'},filter,[1 now]);
 [delta CI deltas CIs]=viewFlankerComparison(names,params,cMatrix,[],[],diffEdges,[],false)
title('all trials')


 subplot(1,3,2)
 hold off
filter{1}.type='9.4';
filter{2}.type='responseSpeedPercentile';
filter{2}.parameters.range=[0 .75]; %percentile
[stats CI names params] =getFlankerStats(subjects,'8flanks+',{'pctCorrect'},filter,[1 now]);
 [delta CI deltas CIs]=viewFlankerComparison(names,params,cMatrix,[],[],diffEdges,[],false)
 title('remove %25 slowest')
 
subplot(1,3,3)
filter{1}.type='9.4';
filter{2}.type='responseSpeedPercentile';
filter{2}.parameters.range=[0 .5]; %percentile
[stats CI names params] =getFlankerStats(subjects,'8flanks+',{'pctCorrect'},filter,[1 now]);
 [delta CI deltas CIs]=viewFlankerComparison(names,params,cMatrix,[],[],diffEdges,[],false)
 title('remove %50 slowest')
 

%% check it for the position sweeping rats!
% not enough data for a resolvable effect jan13,2009
subjects={'232','233','138','228','139'};%     
diffEdges=[-6:6];
cMatrix={[3],[4]};

filter{1}.type='13';
filter{2}.type='responseSpeedPercentile';
filter{2}.parameters.range=[0 .5];%whats justified?
[stats CI names params] =getFlankerStats(subjects,'colin+1&devs',{'pctCorrect','hits','CRs'},filter,[1 now]);
 [delta CI deltas CIs]=viewFlankerComparison(names,params,cMatrix)
 
%%  check percentiles over time for position variable rats (only analyze the same distance=3 lambda)
% if anything the opposite effect...?
% that is slow responding colinear is WORSE with more time, (unlike before when it got better with more time...)

subjects={'232','233','138','228','139'};
filter{1}.type='13';
filter{2}.type='responseSpeedPercentile';
    
dur=.3; %  actually percentile width
timeRanges=[0:.05:1-dur]; % these are not times anymore...
timeRanges(2,:)=timeRanges+dur;
deltas=[]; CI=[]; stats=[]; effect=[];
for i=1:length(timeRanges)
    filter{2}.parameters.range=timeRanges(:,i); %percentile
    [stats(:,:,i) pCI(:,:,:,i) names params]=getFlankerStats(subjects,'colin+1&devs',{'pctCorrect'},filter,[1 now]);
    [effect(i) CI(:,:,:,i) deltas(:,:,:,i) CIs(:,:,:,:,i)]=viewFlankerComparison(names,params,{[3],[4]});
end
mnPerf=reshape( mean(stats(:,[3 4],:)) ,[2 length(timeRanges)] );

maxT=max(timeRanges(:));
mnTime=mean(timeRanges);
figure
subplot(2,1,1); plot(mnTime,mnPerf(1,:),'color',[1 0 0]); hold on; plot(mnTime,mnPerf(2,:),'color',[0 1 1]);
ylabel('% correct'); xlabel('responseTime Percentile'); legend({'colin','pop1'})
hold on; plot([timeRanges(:,1)],[.55 .55],'k')
subplot(2,1,2); plot(mnTime,effect); hold on; plot([0 maxT],[0 0],'k'); axis([0 maxT -10 10]);  ylabel('% effect');
for i=1:length(timeRanges)
    subplot(2,1,2);
    plot([mnTime(i) mnTime(i)],[CI(1,1,1,i) CI(1,1,2,i)],'b') % CI
    plot(repmat(mnTime(i),[1 length(subjects)]),reshape(deltas(1,1,:,i),[1 length(subjects)]),'k.') % CI
end
