function [strs p]=displayStatSig(names,params,test,alpha,featureNames,cSet,doFigure,stringType,comparisonName)


if ~exist('featureNames','var') || isempty(featureNames)
    featureNames={'condition','subject'};
end
if ~exist('cSet','var') || isempty(cSet)
    if strcmp(names.conditions{1},'RRR') && strcmp(names.conditions{9},'colin')
        cSet={[9 10],[9 11],[9 12],[10 11],[10 12],[11 12]};
    else
        cSet={[1 2]};
    end
end

if ~exist('alpha','var') || isempty(alpha)
    alpha=0.05;
end


if ~exist('doFigure','var') || isempty(doFigure)
    doFigure=false;
end
if ~exist('comparisonName','var') || isempty(comparisonName)
    comparisonName='';
end
if ~exist('stringType','var') || isempty(stringType)
    stringType='full';
end


for i=1:length(cSet)
    
    for j=1:length(test)
        str='';
        x=params.raw.numCorrect(:,cSet{i})./params.raw.numAttempt(:,cSet{i});
        switch test{j}
            case 'friedman'
                x=params.raw.numCorrect(:,cSet{i})./params.raw.numAttempt(:,cSet{i});
                [p(i,j)]=friedman(x,1,'off');
                h(i,j)= p(i,j)<alpha;
                
            case 'friedmanHSD1'
                if ~exist('friedmanHSDc','var')
                    allConds=names.conditions(unique([cSet{:}]));
                    x=params.raw.numCorrect(:,unique([cSet{:}]))./params.raw.numAttempt(:,unique([cSet{:}]));
                    [p(i,j) t stats]=friedman(x,1,'off');
                    figure; [friedmanHSDc] = multcompare(stats,'ctype','hsd','display','on','alpha',alpha);
                end
                
                useConds=names.conditions(cSet{i});
                which=find(sum(ismember(friedmanHSDc(:,[1 2]),find(ismember(allConds,useConds))),2)==2);
                if length(which)~=1
                    keyboard
                    error('chck assumptions in calculation of finding the condition... did you ask for something that does not exist?')
                end
                % check not overlap with zero
                h(i,j)=all(sign(friedmanHSDc(which,3))==sign(friedmanHSDc(which,[4 5])));
                p(i,j)=nan;
            case 'fDprimHSD1'
                if ~exist('fDprimHSD1c','var')
                    allConds=names.conditions(unique([cSet{:}]));
                    x=params.raw.numCorrect(:,unique([cSet{:}]))./params.raw.numAttempt(:,unique([cSet{:}]));
                    hit=params.raw.numHits(:,unique([cSet{:}]));
                    miss=params.raw.numMisses(:,unique([cSet{:}]));
                    fa=params.raw.numFAs(:,unique([cSet{:}]));
                    cr=params.raw.numCRs(:,unique([cSet{:}]));
                    numSig=hit+cr;
                    numNoSig=miss+fa;
                    
                    dpr = sqrt(2) * (erfinv((hit-miss)./(hit+miss)) + erfinv((cr - fa)./(cr+fa)));
                    [p(i,j) t stats]=friedman(dpr,1,'off');
                    figure; [fDprimHSD1c] = multcompare(stats,'ctype','hsd','display','on','alpha',alpha);
                end
                
                useConds=names.conditions(cSet{i});
                which=find(sum(ismember(fDprimHSD1c(:,[1 2]),find(ismember(allConds,useConds))),2)==2);
                if length(which)~=1
                    keyboard
                    error('chck assumptions in calculation of finding the condition... did you ask for something that does not exist?')
                end
                % check not overlap with zero
                h(i,j)=all(sign(fDprimHSD1c(which,3))==sign(fDprimHSD1c(which,[4 5])));
                p(i,j)=nan;
            case 'friedmanHSDb'   
                if ~exist('friedmanHSDbc','var')
                    allConds=names.conditions(unique([cSet{:}]));
                    D=makeDataMatrixPerAnalysisBlockFromFlankerStats(names,params,allConds,[featureNames 'correct' 'block' 'conditionID']);
                    %D=makeDataMatrixTimeFractionBlocksFromFlankerStats(names,params,allConds,[featureNames 'correct'],'thirds') % NOT USED DELETEABLE
                    [x numBlocks]=makeFriedmanMatrixFromD(D,'correct');
                    [p(i,j) t stats]=friedman(x,numBlocks,'off');
                    figure; [friedmanHSDbc] = multcompare(stats,'ctype','hsd','display','on','alpha',alpha);
                end
                useConds=names.conditions(cSet{i});
                which=find(sum(ismember(friedmanHSDbc(:,[1 2]),find(ismember(allConds,useConds))),2)==2);
                if length(which)~=1
                    keyboard
                    error('chck assumptions in calculation of finding the condition... did you ask for something that does not exist?')
                end
                % check not overlap with zero
                h(i,j)=all(sign(friedmanHSDbc(which,3))==sign(friedmanHSDbc(which,[4 5])));
                p(i,j)=nan;
            case 'anova'
                blockLength=200;
                useConds=names.conditions(cSet{i});
                D=makeDataMatrixPerAnalysisBlockFromFlankerStats(names,params,useConds,[featureNames 'correct'],blockLength);
                %basic condition effect with 2 way anova
                predictors={}; %{D.condition D.subject}
                for f=1:length(featureNames)
                    predictors=[predictors D.(featureNames{f})];
                end
                [pAnova] = anovan(D.correct,predictors,'model',2,'sstype',3,'varnames',featureNames,'display','off');
                p(i,j)=pAnova(1);  %assumes you want to know the first one which is usually condition!
                h(i,j)= p(i,j)<alpha;
            case 'anovaDpr'
                blockLength=200;
                useConds=names.conditions(cSet{i});
                D=makeDataMatrixPerAnalysisBlockFromFlankerStats(names,params,useConds,[featureNames 'dprime'],blockLength);
                %basic condition effect with 2 way anova
                predictors={}; %{D.condition D.subject}
                for f=1:length(featureNames)
                    predictors=[predictors D.(featureNames{f})];
                end
                [pAnova] = anovan(D.dprime,predictors,'model',2,'sstype',3,'varnames',featureNames,'display','off');
                p(i,j)=pAnova(1);  %assumes you want to know the first one which is usually condition!
                h(i,j)= p(i,j)<alpha;
            case 'aDprimHSD'
                if ~exist('aDprimHSDc','var')
                    allConds=names.conditions(unique([cSet{:}]));
                    blockLength=200;
                    D=makeDataMatrixPerAnalysisBlockFromFlankerStats(names,params,allConds,[featureNames 'dprime'],blockLength);
                    predictors={}; %{D.condition D.subject}
                    for f=1:length(featureNames)
                        predictors=[predictors D.(featureNames{f})];
                    end
                    [pAnova t stats terms] = anovan(D.dprime,predictors,'model',2,'sstype',3,'varnames',featureNames,'display','off');
                    p(i,j)=pAnova(1);  %assumes you want to know the first one which is usually condition!
                    useConds=names.conditions(cSet{i});
                    figure; [aDprimHSDc] = multcompare(stats,'ctype','hsd','alpha',alpha,'display','on');
                end
                useConds=names.conditions(cSet{i});
                which=find(sum(ismember(aDprimHSDc(:,[1 2]),find(ismember(allConds,useConds))),2)==2);
                if length(which)~=1
                    error('chck assumptions in calculation of finding the condition... did you ask for something that does not exist?')
                end
                % check not overlap with zero
                h(i,j)=all(sign(aDprimHSDc(which,3))==sign(aDprimHSDc(which,[4 5])));
                p(i,j)=nan;
            case 'anovaHSD'
                if ~exist('anovaHSDc','var')
                    allConds=names.conditions(unique([cSet{:}]));
                    blockLength=200;
                    D=makeDataMatrixPerAnalysisBlockFromFlankerStats(names,params,allConds,[featureNames 'correct' 'conditionID'],blockLength);
                    predictors={}; %{D.condition D.subject}
                    for f=1:length(featureNames)
                        predictors=[predictors D.(featureNames{f})];
                    end
                    [pAnova t anovaHSDstats terms] = anovan(D.correct,predictors,'model',1,'sstype',3,'varnames',featureNames,'display','off');
                    p(i,j)=pAnova(1);  %assumes you want to know the first one which is usually condition!
                    useConds=names.conditions(cSet{i});
                    figure; [anovaHSDc] = multcompare(anovaHSDstats,'ctype','hsd','alpha',alpha,'display','on');
                    
                    dispMinMaxSamples=true;
                    if dispMinMaxSamples
                        numSampsPerCondSubj=[];
                        lillie=[]; reference=[];
                        subs=unique(D.subject);
                        conds=unique(D.conditionID);
                        for s=1:length(subs)
                            for c=1:length(conds)
                                which=D.subject==subs(s) & D.conditionID==conds(c);
                                numSampsPerCondSubj(s,c)=sum(which);
                                if sum(which)>3
                                    lillie(s,c)=lillietest(D.correct(which));
                                    reference(s,c)=lillietest(randn(1,length(which)));
                                else
                                    lillie(s,c)=0; %can't find non-gauss, but didn't test, so could nan or ignore
                                    reference(s,c)=0;
                                end
                            end
                        end
                        %figure; hist(numSampsPerCondSubj)
                        numSampsPerCondSubj
                        disp(['range of num samples per condition per subject: ' num2str(minmax(numSampsPerCondSubj(:)'))])
                        disp(['lillie violations: [' num2str(sum(lillie(:))) ' of ' num2str(length(lillie(:)))  '   ' num2str(100*mean(lillie(:))) '% ]'])
                        disp(['match violations: [' num2str(sum(reference(:))) ' of ' num2str(length(reference(:)))  '   ' num2str(100*mean(reference(:))) '% ]'])
                    end
                    
                end
                useConds=names.conditions(cSet{i});
                which=find(sum(ismember(anovaHSDc(:,[1 2]),find(ismember(allConds,useConds))),2)==2);
                if length(which)~=1
                    error('chck assumptions in calculation of finding the condition... did you ask for something that does not exist?')
                end
                % check not overlap with zero
                h(i,j)=all(sign(anovaHSDc(which,3))==sign(anovaHSDc(which,[4 5])));
                p(i,j)=nan;
            case 'anovaHSDb'
                 if ~exist('anovaHSDbc','var')
                    allConds=names.conditions(unique([cSet{:}]));
                    D=makeDataMatrixPerAnalysisBlockFromFlankerStats(names,params,allConds,[featureNames 'correct']);
                    predictors={}; %{D.condition D.subject}
                    for f=1:length(featureNames)
                        predictors=[predictors D.(featureNames{f})];
                    end
                    [pAnova t stats terms] = anovan(D.correct,predictors,'model',2,'sstype',3,'varnames',featureNames,'display','off');
                    p(i,j)=pAnova(1);  %assumes you want to know the first one which is usually condition!
                    useConds=names.conditions(cSet{i});
                    figure; [anovaHSDbc] = multcompare(stats,'ctype','hsd','alpha',alpha,'display','on');
                end
                useConds=names.conditions(cSet{i});
                which=find(sum(ismember(anovaHSDbc(:,[1 2]),find(ismember(allConds,useConds))),2)==2);
                if length(which)~=1
                    error('chck assumptions in calculation of finding the condition... did you ask for something that does not exist?')
                end
                % check not overlap with zero
                h(i,j)=all(sign(anovaHSDbc(which,3))==sign(anovaHSDbc(which,[4 5])));
                p(i,j)=nan;
            case 'ttest'
                [h(i,j) p(i,j)]=ttest(x(:,1)-x(:,2),[],alpha);
            otherwise
                test
                error('bad test request')
        end
        switch stringType
            case 'full'
                str=[test{j}(1:2) test{j}(end-2:end) '  ' num2str(h(i,j)) '   '  names.conditions{cSet{i}(1)} ' vs ' names.conditions{cSet{i}(2)} '; p=' num2str(p(i,j),'%2.4g')];
            otherwise
                error(['bad type: ' stringType ])
        end
        disp(str)
        
        strs{i}=str;
    end
    if doFigure
        title(comparisonName)
    end
    disp('*')
end
end

function [x numBlocks]=makeFriedmanMatrixFromD(D,feature);

if ~exist('feature','var') || isempty(feature)
    feature='correct';
end

numBlocks=max(D.block);
numSubjects=length(unique(D.subject));
conditionIDs=unique(D.conditionID);
numConditions=length(conditionIDs);


x=nan(numBlocks*numSubjects,numConditions);
for c=1:numConditions
    temp=reshape(D.(feature)(D.conditionID==conditionIDs(c)),numBlocks,numSubjects)';
    x(:,c)=temp(:);
end
end
