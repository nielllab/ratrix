%testAnova




clear all
load carbig

%%
useConds={'colin','para','changeFlank','changeTarget'};  % display these conditions
subjects={'228','227','230','233','234','139','138'}; %puts high-lighted rat (end) on the top
statTypes={'pctCorrect','CRs','FAs','hits','dpr','yes','crit'}; % faster, but no error bars on dprim stats
statTypes={'pctCorrect'};
%subjects={'234','227','138'}; % quick for testing

[stats CI names params]=getFlankerStats(subjects,'8flanks+',statTypes,'9.4',[0 733876],[])
%% basic anova (violates gaussian cuz binomial data)
D=makeDataMatrixPerTrialFromFlankerStats(names,params,useConds);

%basic condition effect with 2 way anova
[p t stats terms] = anovan(D.correct,{D.condition D.subject},'model',2,'sstype',3,'varnames',{'Condition';'Rat'})
close all
[c,m,h,nms] = multcompare(stats,'ctype','hsd');
title('hsd')

%% anova on grouped
blockLength=500;
D=makeDataMatrixPerAnalysisBlockFromFlankerStats(names,params,useConds, {'subject','subjectID','conditionID','correct','condition'},blockLength);  % could use real day boundaries instead?
[p t stats terms] = anovan(D.correct,{D.condition D.subject},'model',2,'sstype',3,'varnames',{'Condition';'Rat'});

[c,m,h,nms] = multcompare(stats,'ctype','hsd','dimension',[1]);

% check assumptions
close all
figure; hist(stats.resid)
title(sprintf('lillie= %d',lillietest(stats.resid)))
numS=length(unique(D.subjectID))
numC=length(unique(D.conditionID));
edges=linspace(-.2,.2,20);
for s=1:numS
    for c=1:numC
        subplot(numS,numC,(s-1)*numC+c);
        res=stats.resid(D.subjectID==s & D.conditionID==c);
        count=histc(res,edges);
        bar(edges,count/sum(count),'histc'); hold on
        axis([-.2 .2 0 .5]);
        set(gca,'xtick',[10],'ytick',[])
        
        [mu sig]=normfit(res);
        nd=normpdf(edges,mu,sig);
        plot(edges,nd/sum(nd),'r')
        ld(s,c)=lillietest(res);
        lr(s,c)=lillietest(normrnd(mu,sig,size(res)));
        title(sprintf('data/rnd: %d%d',ld(s,c),lr(s,c)))
    end
end
xlabel(['sum data/rnd:' num2str([sum(ld(:)) sum(lr(:))]) ])
%% compare to a glm
useConds={'colin','para','changeFlank','changeTarget'};
D=makeDataMatrixPerTrialFromFlankerStats(names,params,useConds,{'subject','correct','isoOri','isoAxis','subjectMean'});
%[p t stats terms] = anovan(D.correct,{D.isoOri D.isoAxis D.subject},'model',2,'sstype',3,'varnames',{'ori';'ax';'rat'})
[b,dev,stats2]=glmfit([D.isoOri D.isoAxis D.isoOri.*D.isoAxis ],D.correct,'binomial'); %fails to account for subjects
[b,dev,stats2]=glmfit([D.isoOri D.isoAxis D.isoOri.*D.isoAxis D.subjectMean],D.correct,'binomial'); %does this work?


%% attempt categorical glm
useConds={'colin','para','changeFlank','changeTarget'};
D=makeDataMatrixPerTrialFromFlankerStats(names,params,useConds,{'subjectLogicalMatrix','conditionLogicalMatrix','correct','subjectMean'});
[b,dev,stats2]=glmfit([D.conditionLogicalMatrix D.subjectLogicalMatrix ],D.correct,'binomial','constant','off');
b
[b,dev,stats2]=glmfit([D.conditionLogicalMatrix],D.correct,'binomial','constant','off','offset',D.subjectMean);
b

%% based on features in the stims
blockLength=500;
D=makeDataMatrixPerAnalysisBlockFromFlankerStats(names,params,useConds,[],blockLength);  % could use real day boundaries instead?
[p t stats terms] = anovan(D.correct,{D.isoOri D.isoAxis D.subject},'model',2,'sstype',3,'varnames',{'ori';'Ax';'Rat'})
%
close all
[c,m,h,nms] = multcompare(stats,'ctype','hsd','dimension',[1 2]);
title('ori x axis')


%% see that cochranqtest is sensible
for i=1:1000
    x=rand(10000,4)>.66;
    %x(:,1)=rand(10000,1)>.63;
    r(i)=cochranqtest(x);
end
sum(r)

%% cochranqtest not compatible with mult compare

[h,p,stats] = cochranqtest(rand(5000,4)>.5);
[c,m,h,nms] = multcompare(stats,'ctype','hsd');

%% cochran / kruskalwallis test on each subject

%note we thow out a little data
condIDs=[9 10 11 12];
condIDs=[11 12];
for s=1:length(names.subjects)
    minBlocks=min(params.raw.numAttempt(s,condIDs));
    x=zeros(minBlocks,length(condIDs));
    for c=1:length(condIDs)
        nc=params.raw.numCorrect(s,condIDs(c));
        n=params.raw.numAttempt(s,condIDs(c));
        effectiveCorrect=round(minBlocks*nc/n);
        x(1:effectiveCorrect,c)=1;
        x(:,c)=x(randperm(minBlocks),c);
    end
    [hc(s) pc(s)] = cochranqtest(x);
    [pk(s) anovatab stats] = kruskalwallis(x,names.conditions(condIDs),'off');
    [c,m,h,nms] = multcompare(stats,'ctype','hsd');
end
[hc; pc; pk]

%% friedman on all data
x=params.raw.numCorrect(:,condIDs)./params.raw.numAttempt(:,condIDs);
[p t stats]=friedman(x);
[c,m,h,nms] = multcompare(stats,'ctype','hsd');

% the conditions are different (p<0.001)
% colin is smaller than para
% colin is smaller than changeFlank
% colin is not smaller than changeTarget

%% test on all data

cSet={[9 10], [9 11], [9 12],[10 11],[10 12],[11 12]};
n=size(params.raw.numCorrect,1);
alphaFWE=0.05; %1-(1-alpha)^n
alpha=1-((1-alphaFWE)^(1/n)); %assumes conservative extreme of independence.. which is not necc. true because data overlap 3 or 6 involve colin
alphaFWE2=1-(1-alpha)^n;  %confirm inversion
%alpha=0.001;
%alpha=0.05;
for i=1:length(cSet)
    x=params.raw.numCorrect(:,cSet{i})./params.raw.numAttempt(:,cSet{i});
    %[p t stats]=friedman(x);
    %[c,m,h,nms] = multcompare(stats,'ctype','hsd');
    [h(i) p(i)]=ttest(x(:,1)-x(:,2),[],alpha);
end
p<alpha

% not sure if this is appropriate or if i understand it fully:
% en.wikipedia.org/wiki/Holm-Bonferroni_method
% prank=sort(p);
% for i=1:length(cSet)
%     if prank(i)<alphaFWE/(n-i)
%         hrank(i)=1;
%         [prank(i) alphaFWE/(n-i)]
%     else
%         hrank(i:length(cSet))=0;
%         break
%     end
% end
%
%% friedman on blocks of data

blockLength=3800;
D=makeDataMatrixPerAnalysisBlockFromFlankerStats(names,params,useConds,[],blockLength,true);  % could use real day boundaries instead?
numCond=length(useConds);
numSubj=length(names.subjects);
numBlock=length(D.correct)/(numCond*numSubj);

%use these to confirm conditions and subjects end up in the right position
%in the matrix for reps of freidmans
y=reshape(D.subject,numBlock,numCond,numSubj);
y=reshape(double(D.condition(:,7)),numBlock,numCond,numSubj);
%actually use correct
y=reshape(D.correct,numBlock,numCond,numSubj);  % numBlocks numCond numSubj

x=reshape(permute(y,[2 3 1]),numCond,[])';
[p t stats]=friedman(x,numBlock);
[c,m,h,nms] = multcompare(stats,'ctype','hsd');




%% friedman all

useConds={'colin','para','changeFlank','changeTarget'};  % display these conditions
subjects={'228','227','230','233','234','139','138'}; %puts high-lighted rat (end) on the top
%subjects={'228','227','230','233','234','138'}; %leave out the outlier tumor rat
statTypes={'pctCorrect'};
[stats CI names params]=getFlankerStats(subjects,'8flanks+',statTypes,'9.4',[0 733876],[])

condIDs=[9 10 11 12];
x=params.raw.numCorrect(:,condIDs)./params.raw.numAttempt(:,condIDs);
[p t stats]=friedman(x); [c,m,h,nms] = multcompare(stats,'ctype','hsd');
str=['all conds p=' num2str(p)];
title(str); disp(str)


%% munging alpha to find p value with multcompare
close all
'alpha'
condIDs=[9 10 11 12];
x=params.raw.numCorrect(:,condIDs)./params.raw.numAttempt(:,condIDs);
[p t stats]=friedman(x); [c,m,h,nms] = multcompare(stats,'ctype','hsd','alpha',0.006);


%% what is the most stringent alpha that would still conclude these are different?

% %all 7 rats
% condIDs=[9 10];  a~0.006
% condIDs=[9 11];  a~0.47
% condIDs=[9 12];  a~0.0005
% condIDs=[10 11]; a~0.25
% condIDs=[10 12]; a~0.062
% condIDs=[11 12]; a~0.93
%
%
% %LEAVING OUT 139 (THE OUTLIER TUMOR RAT)
% condIDs=[9 10];  a~0.0095
% condIDs=[9 11];  a~0.53
% condIDs=[9 12];  a~0.00199
% condIDs=[10 11]; a~0.27
% condIDs=[10 12]; a~0.11
% condIDs=[11 12]; a~0.98



%% friedman without multcomparing


cSet={[9 10], [9 11], [9 12],[10 11],[10 12],[11 12]};
for i=1:length(cSet)
    x=params.raw.numCorrect(:,cSet{i})./params.raw.numAttempt(:,cSet{i});
    [p t stats]=friedman(x); [c,m,h,nms] = multcompare(stats,'ctype','hsd');
    str=[names.conditions{condIDs(1)} ' vs ' names.conditions{condIDs(2)} '; p=' num2str(p)];
    title(str); disp(str)
end

%TOO MUCH signif without multiple comparisons.
%colin vs changeFlank; p=0.008151
%colin vs changeTarget; p=0.008151
%colin vs para; p=0.008151
%changeFlank vs changeTarget; p=0.008151
%changeFlank vs para; p=0.25684
%changeTarget vs para; p=0.008151

%% anova without mult comparing

cSet={[9 10], [9 11], [9 12],[10 11],[10 12],[11 12]};
blockLength=100;
for i=1:length(cSet)
    useConds=names.conditions(cSet{i});
    D=makeDataMatrixPerAnalysisBlockFromFlankerStats(names,params,useConds, {'subject','correct','condition'},blockLength);
    [p t stats terms] = anovan(D.correct,{D.condition D.subject},'model',2,'sstype',3,'varnames',{'Condition';'Rat'});
    [c,m,h,nms] = multcompare(stats,'ctype','hsd','dimension',[1]);
    str=[useConds{1} ' vs ' useConds{2} '; p=' num2str(p(1))];
    title(str); disp(str)
end


%% a more general stat checker function
strs=displayStatSig(names,params,{'anovaHSD','ttest','friedman'});


%%
reps=10000;
N=[5 7 10 15 20 50];
figure;
blocks=3;
for n=1:length(N)
    pt=zeros(1,reps);
    pf=zeros(1,reps);
    for i=1:reps
        x=randn(N(n)*blocks,2);
        [h pt(i)]=ttest(x(:,1)-x(:,2));
        pf(i)=friedman(x,blocks,'off');
    end
    subplot(2,3,n)
    loglog(pt,pf,'.')
    xlabel('ttest (p)')
    ylabel('friedmans (p)')
    hold on;
    alpha=0.05;
    plot(xlim,alpha([1 1]),'k')
    plot(alpha([1 1]),ylim,'k')
    title(['n=' num2str(N(n)) '; fHits: ' num2str(sum(pf<alpha)/reps) ])
    disp(['hit rate for friedmans' num2str(sum(pf<alpha)/reps)])
    disp(['hit rate for ttest' num2str(sum(pt<alpha)/reps)])
    drawnow
end

