classdef detectionModel
    properties
        %contrasts used
        tc=[0 0.25 0.5 0.75 1];
        fc=[0 0.25 0.5 0.75 1];
        
        %generative model params
        numIttn=2000; %100 %300 %2000;
        numNodes=100;
        nodesPerSpaceUnit=8;  % could be mm; can mean units target width when stdT=1
        stdT=1;
        stdF=1;
        d=4;       %distance from target to flank center
        stdEye=1;
        stdAttn=Inf; %global for all contrast conditions, can be overwritten using doStdAttnFit
        doStdAttnFit=false;
        attnBound=[0.25 10]; % the boundaries of the fit, if used
        relativeMissCost=1; %how much worse it is to Miss a trial vs, have a false alarm
        baseline=0.05; % additive offset of effective contrastEnvelope (some response for zero contrast; like internal noise)
        nodeDistribution='absGauss'; %gauss
        combinationRule='max' %mean, sum, max, LL, sampleGEV
        optimalCritMethod='fitGev'; %raw, fitGev,
        
        %model fitting params
        parameterSource = 'parametericSDT'; %'simulationFitResults';
        modelFeatures={'alpha','tm','fm'}; % by listing dn values (i.e. 'c50'), it becomes dn, gev, etc...
        modelValues=[1 1 0.8];
        critLearningRate='fit';  %'zero','one','fit' ;fit uses erf 0-->1;  the model feature alpha will be overpowered if 'zero' or 'one'
        
        mcmcModel='noneWorkingNow.txt'; %'GEV-linearTFcontrast.txt'
        
        %infrastructure
        savePath='C:\Documents and Settings\rlab\Desktop\detectionModels'
        modelName='simple-231'; %
        %other old models: fastManualHunt,LL, fixedEye, fitAttnfixedEye
        
        %for histograms of the signal & boundary for fminsearch
        edges=[];
        
        %initialize params
        current=[];
        viewPlot =[];
        cache=[];
        
        %maybe dependant
        crit=[];
    end
    properties (Dependent = true)
        numTc
        numFc
        loc
        contrastHeight % the height of a full target contrast (before attn reduces)
        contrastAttentionHeight %the highest envelope you could get for full contrast at the center of attn
        offsetMatrix % the contrastAndAttention envelope offset by position
        numOffsets
        %turned to function:
        %   contrastEnvelope
        %   attentionEnvelope
    end
    methods
        function p=detectionModel()
            %default contructor uses no params
            p=p.init;
            p=p.setViewPlots('allOn'); %'dynamicTesting'
            %p.manualHuntTrail(); %do first thing automatically
            %p.testBed();%
            %p.intuitionTest()
            
            p=p.testDiffusionModel();
                        
 
            %p.runAndSaveModelBatchSTD({'unequal var yoked plus bias','unequal var ind plus bias'});
            %p.modelCompareForPoster({'simple','fixed crit','slow adapting','unequal var yoked','variance scales','unequal var ind'},'231');
            %p.modelCompareForPoster({'simple plus bias','fixed crit plus bias','slow adapting plus bias','unequal var yoked plus bias','variance scales plus bias','unequal var ind plus bias'},'231');
            %p.modelCompareForPoster({'fixed crit','slow adapting','variance scales','unequal var yoked','unequal var ind'},'231');
            
            %p=p.searchSearch();
            %p.modelName='searchSearch_20100608T174740'; %72 models
            %p=p.load;
            %p.modelCompareForPoster(p.cache.namesOfModels)
        end
        function p=testDiffusionModel(p)
            minX=-1;
            maxX=1;
            minT=.5;
            maxT=2;
            nT=100; 
            nX=101;
            time=linspace(minT,maxT,nT);
            xVals=linspace(minX,maxX,nX);
            
            starts=[.7 -0.2];
            
            switch 'flat'
                case 'flat'
                    yesBound=ones(1,nT);
                    noBound=-ones(1,nT);
                case 'linear'
                    boundPerSecond=.5;
                    yesBound=1-(time-minT)*boundPerSecond;
                    boundPerSecond=0;
                    noBound=-1+(time-minT)*boundPerSecond;
                case 'fit'
                    for i=1:nT
                        %relate desnity of rate crossing from diffution
                        %model to real rate data...  might be cart before horse
                        boundarySlope(i,1)=xxx; 
                    end
                    yesBound=1-cumsum(boundarySlope(:,1));
                    noBound=-1+cumsum(boundarySlope(:,2));
            end
            
            
            numStarts=length(starts);
            filtSz=ceil(nX); hwDown=ceil(filtSz/2); hwUp=filtSz-hwDown;
            temperature=ceil(nT/15); % diffusion speed is temperature is with of this kernal                      
            %drift would be like a mean bias to the gauss, do this better
            %using a gaussian function with mean
            kernal=fspecial('gauss',[1 filtSz ],temperature);
            downDrift=0;
            kernal=[zeros(1,downDrift) kernal]
            
            %init
            x=zeros(nX,nT,numStarts);
            conditionalDensity=x;
            %noBoundDensity=zeros(nX+filtSz-1,nT,numStarts);
            yesRate=zeros(nT,numStarts);
            noRate=zeros(nT,numStarts);
            for s=1:numStarts
                
                if starts(s)>0
                    startInd=nT-min(find(xVals>starts(s)))+1;
                else
                    startInd=nT-max(find(xVals<starts(s)))+1;
                end
                x(startInd,1,s)=0.5; % 50% of probability mass (cuz half trials have a target)
                pAlive(1,s)=0.5;
                for i=2:nT
                    x(:,i,s)=conv(x(:,i-1,s),kernal,'same');
                    full=conv(x(:,i-1,s),kernal,'full');
                    
                    %ERROR CHECK NOT NEEDED EVERY TIME, BUT GOOD FOR DEBUGGING
                    %                     f=full(hwUp+1:end-hwDown+1);
                    %                     n=reshape(x(:,i,s),[],1);
                    %                     if ~all(size(f)==size(n)) || ~all(f==n)
                    %                         [size(full,1) nX size(f,1) size(n,1)]
                    %                         [filtSz hwDown+hwUp hwDown hwUp]
                    %                         f-n
                    %                         figure; plot([f n])
                    %                         error('bad')
                    %                     end
                    
                    upAdj=nX-min(find(xVals>=yesBound(i)));
                    downAdj=max(find(xVals<=noBound(i)))-1;
                    topInd=hwUp+upAdj;
                    bottomInd=hwDown+downAdj;
                    x(1:upAdj,i,s)=0;
                    x(end-downAdj:end,i,s)=0;
                    yesRate(i,s)=sum(full(1:topInd));
                    noRate(i,s)=sum(full(end-bottomInd:end));
                    
                    conditionalDensity(:,i,s)=x(:,i,s)/max(x(:,i,s));
                    %noBoundDensity(:,i,s)=full/max(full);
                    pAlive(i,s)=sum(full(topInd+1:end-bottomInd+1));
                    
                end
            end
            
            figure;
            nP=4;
            subplot(nP,1,2); 
            im=conditionalDensity(:,:,[2 1]);  % 1st 2 [S+ S-]
            im(:,:,3)=0; % make like an image
            imagesc(im.^4,'XData',time,'YData',xVals); hold on
            plot([0 nT+1],(nX([1 1])+1)/2,'k-')
            [cm c]=contour(time,xVals,x(:,:,1),2.^-[9 13],'LineColor',[0 .8 0]);
            plot(cm(1,40:100),cm(2,40:100),'m')
            plot(time,-yesBound,'w')
            plot(time,-noBound,'w')
            %[cm c]=contour(time,xVals,x(:,:,2),2.^-[9 13],'LineColor',[.8 0 0]); % too cluttered to do both
            set(gca,'xtick',[minT maxT],'ytick',[minX maxX]) 
            
            highP=max([yesRate(:); noRate(:)]);
            highPu=highP*1.1-mod(highP*1.1,.001);
            subplot(nP,1,1);
            plot(time,yesRate(:,1),'g',time,yesRate(:,2),'r');
            set(gca,'xtick',[],'ytick',[0 highPu],'ytickLabel',[0 highPu],'ylim',[0 highPu],'xlim',[minT maxT])
            ylabel('p(y)'); legend({'hit','fa'})
            subplot(nP,1,3);
            plot(time,-noRate(:,1),'m',time,-noRate(:,2),'c');
            set(gca,'xtick',[],'ytick',[-highPu 0],'ytickLabel',[-highPu 0],'ylim',[-highPu 0],'xlim',[minT maxT])
            ylabel('p(n)'); legend({'miss','cr'},'Location','SouthEast')
            set(gca,'xtick',[minT maxT],'xlim',[minT maxT]); xlabel('time (sec)'); 
            
            subplot(nP,1,4); 
            hit=sum(yesRate(:,1))*2;
            fa =sum(yesRate(:,2))*2;
            plot(fa,hit,'.r'); hold on
            quartTime=(maxT-minT)*1/4;
            ss=linspace(minT,minT+3*quartTime,10);
            ee=ss+quartTime;
            for w=1:length(ss)
                which=time>=ss(w) & time<ee(w);
                rate=     sum([sum(yesRate(which,:)) sum(noRate(which,:))]);  % without conditioning per catergory
                sigRate=  sum([sum(yesRate(which,1)) sum(noRate(which,1))]); 
                noSigRate=sum([sum(yesRate(which,2)) sum(noRate(which,2))]); 
                hits(w)=sum(yesRate(which,1))/sigRate; 
                fas (w)=sum(yesRate(which,2))/noSigRate;
                pctCor(w)=sum([sum(yesRate(which,1)) sum(noRate(which,2))])/rate;
            end
            plot(fas,hits,'.','color',[.8 .8 .8]); hold on
            plot([0 1],[0 1],'k-')
            axis square
            set(gca,'xtick',[],'ytick',[])
            xlabel('FAs'); ylabel('hits')
            legend({'avg','quartile'},'Location','SouthEastOutside')

            
            %subplot(nP,1,4); plot(time,pAlive); ylabel('remaining')
            %set(gca,'xtick',[minT maxT],'xlim',[minT maxT])
            %xlabel('time (sec)'); legend({'T+','T-'})
            
            cleanUpFigure
            set(gcf,'Position',[10 300 350 600])
            j=1;

            figure
            plot(mean([ss; ee])-minT,pctCor,'ko'); hold on
            axis([0 maxT-minT 0 1])
            plot(xlim,[.5 .5],'k')
            set(gca,'xtick',xlim,'xticklabel',{'fast','slow'},'ytick',[0 .5 1])
            cleanUpFigure
        end
        function p=searchSearch(p,x,subjects)
            if ~exist('x','var') || isempty(x)
                %                 x.subjects={'231','234'};
                %                 x.alpha={'0','1','fit'};
                %                 x.bias={'no','cost','costGuess','costYes|guess'}
                %                 x.var={'no','yoked','ind','scales'}
                %                 x.gamma={'no','yoked','ind'}
                %                 x.plus={'dn','gev'}
                
                %                  x.subjects={'231','234'};
                %                 x.alpha={'0','1','fit'};
                %                 x.bias={'no','cost'};
                %                 x.var={'no','yoked','ind'};
                %                 x.gamma={'no','yoked','ind'};
                %                 x.plus={'no','dn'};
                
                x.subjects={'231','234'};
                x.alpha={'fit'};
                x.bias={'no','cost'};
                x.var={'no','ind','scales'};
                x.gamma={'no','yoked','ind'};
                x.plus={'no','dn'};
                
                
                %                 x.subjects={'231','234'};
                %                 x.alpha={'0','1','fit'};
                %                 x.bias={'cost'};
                %                 x.var={'no','scales'};
                %                 x.gamma={'no'};
                %                 x.plus={'no'};
            end
            
            if exist('subjects','var') && ~isempty(subjects)
                x.subjects=subjects;
            end
            
            baseFeatures={'alpha','tm','fm'}; % all have this
            nm=p.getSearchSearchModelNames(x);
            p.cache.namesOfModels=nm;
            count=0;
            for sub=1:length(x.subjects)
                p=loadDataFromServer(p,x.subjects(sub));
                for a=1:length(x.alpha)
                    for b=1:length(x.bias)
                        for v=1:length(x.var)
                            for g=1:length(x.gamma)
                                for pl=1:length(x.plus)
                                    count=count+1;
                                    if 1 %count>43 % pickup where last left off, TRUE starts fresh
                                        features=baseFeatures;
                                        x0=[0.5 1 1];
                                        disp(sprintf('%d/%d doing %s',count,length(nm),nm{count}))
                                        
                                        switch x.alpha{a}
                                            case '0'
                                                p.critLearningRate='zero';
                                            case '1'
                                                p.critLearningRate='one';
                                            case 'fit'
                                                p.critLearningRate='fit';
                                        end
                                        
                                        switch x.bias{b}
                                            case 'no'
                                            case 'cost'
                                                features{end+1}='bias';
                                                x0(end+1)=0;
                                            case 'costGuess'
                                                features{end+1}='bias';
                                                features{end+1}='guess1';
                                                x0(end+1)=0;
                                                x0(end+1)=0; % fraction? exp?
                                            case 'costYes|guess'
                                                features{end+1}='bias';
                                                features{end+1}='guess1';
                                                features{end+1}='yes|guess1';
                                                x0(end+1)=0;
                                                x0(end+1)=0; % fraction? exp?
                                                x0(end+1)=0; % fraction? exp?
                                        end
                                        
                                        switch x.var{v}
                                            case 'no'
                                            case 'yoked'
                                                features{end+1}='sigma';
                                                x0(end+1)=1;
                                            case 'scales'
                                                features{end+1}='sigmaPerMean';
                                                x0(end+1)=1;
                                            case 'ind'
                                                features{end+1}='ts';
                                                features{end+1}='fs';
                                                x0(end+1:end+2)=[1 1];
                                        end
                                        
                                        switch x.gamma{g}
                                            case 'no'
                                            case 'yoked'
                                                features{end+1}='gamma';
                                                x0(end+1)=1;
                                            case 'ind'
                                                features{end+1}='gammaT';
                                                features{end+1}='gammaF';
                                                x0(end+1:end+2)=[1 1];
                                        end
                                        
                                        switch x.plus{pl}
                                            case 'dn'
                                                features{end+1}='c50';
                                                features{end+1}='fallOff';
                                                x0(end+1:end+2)=[1 1];
                                            case 'gev'
                                                features{end+1}='kappa';
                                                x0(end+1)=[0.3];
                                                error('not yet')
                                            case 'gevS'
                                                features{end+1}='kappa';
                                                features{end+1}='tk';
                                                features{end+1}='tf';
                                                x0(end+1:end+3)=[0.3 1 1];
                                                error('not yet')
                                        end
                                        
                                        if gcf>10
                                            close all
                                        end
                                        
                                        %run this model and save it
                                        p.modelFeatures=features;
                                        p=fitSubjectDataWithSDT(p,x0);
                                        p.modelName=nm{count};
                                        p.save
                                        
                                        %view it
                                        figure;
                                        AIC(count)=p.viewModel;
                                        title(nm{count})
                                        settings=[];
                                        settings.LineWidth=3;
                                        settings.AxisLineWidth=3;
                                        settings.fontSize=20;
                                        cleanUpFigure(gcf,settings)
                                        fprintf('%2.2f',AIC(count))
                                        
                                        %continually save group search info
                                        p.cache.AIC=AIC;
                                        p.cache.groupModelParams{count}=p.cache.modelParams;
                                        p.modelName=sprintf('tempOngoingSearch_%s',datestr(now,30));
                                        p.save
                                    else
                                        p.modelName='tempOngoingSearch_20100608T163949';
                                        p=p.load;
                                    end
                                end
                            end
                        end
                    end
                end
            end
            p.modelName=sprintf('searchSearch_%s',datestr(now,30));
            p.save
        end
            
        function names=getSearchSearchModelNames(p,x)
            names={};
            for sub=1:length(x.subjects)
                for a=1:length(x.alpha)
                    for b=1:length(x.bias)
                        for v=1:length(x.var)
                            for g=1:length(x.gamma)
                                for p=1:length(x.plus)
                                    nm=x.subjects{sub};
                                    nm=[nm '-a_' x.alpha{a}(1)];
                                    if ~strcmp(x.bias{b},'no')
                                        nm=[nm '-b_' x.bias{b}];
                                    end
                                    if ~strcmp(x.var{v},'no')
                                        nm=[nm '-v_' x.var{v}];
                                    end
                                    if ~strcmp(x.gamma{g},'no')
                                        nm=[nm '-g_' x.gamma{g}];
                                    end
                                    if ~strcmp(x.plus{p},'no')
                                        nm=[nm '-' x.plus{p}];
                                    end
                                    names{end+1}=nm;
                                    %disp(nm)
                                end
                            end
                        end
                    end
                end
            end
        end
        function runAndSaveModelBatchSTD(p,namesOfModels)
            if ~isfield(p.cache,'subjectData')
                p=loadDataFromServer(p,{'231'});
            end
            if ~exist('namesOfModels','var') || isempty(namesOfModels)
                namesOfModels={'simple','fixed crit','slow adapting','unequal var yoked','single power law','power law contrast','divisive norm','dn bias','divisive norm3','gevg'}
                %namesOfModels={'dn','dn-2gamma','dn-unequalVar'};
                %namesOfModels={'dn-unequalVar'};
                namesOfModels={'unequal var yoked','single power law','power law contrast','dn','dn bias','divisive norm3','gevg'}
            end
            
            p.parameterSource = 'parametericSDT';
            
            for i=1:length(namesOfModels)
                p.modelName=[namesOfModels{i} '-' p.cache.subjectData.names.subjects{1}];
                fprintf('doing %s (%d of %d)\n',namesOfModels{i},1,length(namesOfModels))
                switch namesOfModels{i}
                    case 'simple'
                        %eqVarGaussian
                        p.critLearningRate='one';
                        p.modelFeatures={'alpha','tm','fm'};
                        x0=[1 1.4 2.4];
                    case 'simple plus bias'
                        %eqVarGaussian
                        p.critLearningRate='one';
                        p.modelFeatures={'alpha','tm','fm','bias'};
                        x0=[1 1.4 2.4 0];
                    case 'fixed crit'
                        p.critLearningRate='zero';
                        p.modelFeatures={'alpha','tm','fm'};
                        x0=[0 1.4 2.4];
                    case 'fixed crit plus bias'
                        p.critLearningRate='zero';
                        p.modelFeatures={'alpha','tm','fm','bias'};
                        x0=[0 1.4 2.4 0];
                    case 'slow adapting'
                        p.critLearningRate='fit';
                        p.modelFeatures={'alpha','tm','fm'};
                        x0=[.73 1.13 1.73];
                        x0=[.77 1.41 2.42];
                    case 'slow adapting plus bias'
                        p.critLearningRate='fit';
                        p.modelFeatures={'alpha','tm','fm','bias'};
                        x0=[.73 1.13 1.73];
                        x0=[.1 1.41 .2 0];
                    case 'variance scales'
                        p.critLearningRate='fit';
                        p.modelFeatures={'alpha','tm','fm','sigmaPerMean'};
                        x0=[1 2 700 -7]; % fails to converge. fm explodes, e^sigmaPerMean plummets
                    case 'variance scales plus bias'
                        p.critLearningRate='fit';
                        p.modelFeatures={'alpha','tm','fm','sigmaPerMean','bias'};
                        
                        x0=[.86 2.5 5.4 -1 -0.06]; % 231
                        x0=[1 2 700 -7 0]; % fails to converge. fm explodes, e^sigmaPerMean plummets
                    case 'unequal var yoked'
                        p.critLearningRate='fit';
                        p.modelFeatures={'alpha','tm','fm','sigma'};
                        x0=[.5 1.4 2.4 2];
                    case 'unequal var yoked plus bias'
                        p.critLearningRate='fit';
                        p.modelFeatures={'alpha','tm','fm','sigma','bias'};
                        x0=[.5 1.4 2.4 2 0];
                    case 'unequal var ind'
                        p.critLearningRate='fit';
                        p.modelFeatures={'alpha','tm','fm','ts','fs'};
                        x0=[.5 1.4 2.4 2 2];
                    case 'unequal var ind plus bias'
                        p.critLearningRate='fit';
                        p.modelFeatures={'alpha','tm','fm','ts','fs','bias'};
                        x0=[.5 1.4 2.4 2 2 0];
                    case 'single power law'
                        p.critLearningRate='fit';
                        p.modelFeatures={'alpha','tm','fm','ts','fs','gamma'};
                        x0= [.81 1.96 5.67 -0.35 3.17 0.99];  % good for learning..include gamma
                    case 'power law contrast'
                        p.critLearningRate='fit';
                        p.modelFeatures={'alpha','tm','fm','ts','fs','gammaT','gammaF'};
                        x0= [.81 1.96 5.67 -0.35 3.17 0.99 2.36];  % good for learning..include gamma x2
                    case 'dn'
                        p.critLearningRate='fit';
                        p.modelFeatures={'alpha','tm','fm','bias','c50','gamma'};
                        x0= [.6 1 1 nan nan 1.6 ];
                    case 'dn-fallOff'
                        p.critLearningRate='fit';
                        p.modelFeatures={'alpha','tm','fm','bias','c50','fallOff'};
                        x0= [.6 1 1 nan nan 1.6 1];
                    case 'dn-2gamma'
                        p.critLearningRate='fit';
                        p.modelFeatures={'alpha','tm','fm','bias','c50','fallOff','gammaT','gammaF'};
                        %x0= [.6 2 3 1 0.3 1.64 -0.8 1.64 ]; %MM with linear gamma=1, no variance
                        x0= [.6 1 1 nan nan 1.6 1];
                    case 'dn-unequalVar'
                        p.signalCombination='divisiveNormalization';
                        p.modelFeatures={'alpha','tm','fm','bias','c50','fallOff','gammaT','gammaF','ts','fs'};
                        x0= [.6 1 1 1 .5 2 .3 2 .5 .5];
                    case 'gevk'
                        p.critLearningRate='fit';
                        p.modelFeatures={'alpha','tm','fm','ts','fs','kappa'};
                        x0=[.5 1.4 2.4 1 1 0.3]; %  k0
                    case 'gev'
                        p.critLearningRate='fit';
                        p.modelFeatures={'alpha','tm','fm','ts','fs','kappa','tk','fk'};
                        x0=[.5 1.4 2.4 1 1 -.3 0 0]; %  +a linear coeff for kappa
                    case 'gevg'
                        p.critLearningRate='fit';
                        p.modelFeatures={'alpha','tm','fm','ts','fs','kappa','tk','fk','gammaT','gammaF'};
                        x0=[.85 3.7 7.8 1 5 0.8 0.03 0.00 1.4 2.4]; %  +gammas
                    otherwise
                        namesOfModels{i}
                        error('bad')
                end
                p=fitSubjectDataWithSDT(p,x0);
                figure;
                p.save
                
                AIC(i)=p.viewModel;
                title(namesOfModels{i})
                
                p.cache.groupModelParams{i}=p.cache.modelParams;
                figure;
                p.edges=linspace(-2,10,100)
                
                %                 figure
                %                 p.plotModelFeatures(.75,[0 0.75],{'sig&Noise'})
                %                 subplot(2,1,1); set(gca,'ytick',[],'xTick',[]); axis([-2 10 0 .5])
                %                 ylabel('probability')
                %                 subplot(2,1,2); set(gca,'ytick',[],'xTick',[]); axis([-2 10 0 .5])
                %
                settings=[];
                settings.LineWidth=3;
                settings.AxisLineWidth=3;
                settings.fontSize=20;
                cleanUpFigure(gcf,settings)
                
                %also get distribtuion of two contrast
                
            end
            
            p.cache.AIC=AIC;
            p.cache.namesOfModels=namesOfModels
            p.modelName='modelGroup';
            p.save;
            
            
        end
        function modelCompareForPoster(p,namesOfModels,subject)
            if ~exist('namesOfModels','var') || isempty(namesOfModels)
                namesOfModels={'simple','fixed crit','slow adapting','unequal var','single power law','power law contrast','dn','dn-2gamma','dn-unequalVar','gevg'}
            end
            
            if ~exist('subject','var') || isempty(subject)
                subject='234'
            end
            
            if length(namesOfModels)<=10 % only plot each one if 10 models or less
                for i=1:length(namesOfModels)
                    if strcmp(namesOfModels{i}(1:2),'23')
                        %model starts with subjects name... load it (subj var will be ignored)
                        p.modelName=namesOfModels{i};
                    else
                        %model does not start with subjects name... [append the name of the subject and then load it]
                        p.modelName=[namesOfModels{i} '-' subject];
                    end
                    fprintf('doing %s (%d of %d)\n',namesOfModels{i},1,length(namesOfModels))
                    p=p.load()
                    figure;
                    AIC(i)=p.viewModel(true,namesOfModels{i});
                end
            else %get the AIC from the last one in the list
                    if strcmp(namesOfModels{end}(1:2),'23') % this should be a better function
                        %model starts with subjects name... load it (subj var will be ignored)
                        p.modelName=namesOfModels{end};
                    else
                        %model does not start with subjects name... [append the name of the subject and then load it]
                        p.modelName=[namesOfModels{end} '-' subject];
                    end
                    p=p.load()
                    AIC=p.cache.AIC;
            end
            
            figure; hold on
            coloring='default';
            switch coloring
                case 'cosyne2010poster'
                    for i=1:6
                        bar(i,AIC(i),'faceColor',[.8 .8 .8]);
                    end
                    for i=7:8
                        bar(i,AIC(i),'faceColor',[1 .8 .6]);
                    end
                    for i=9:length(AIC)
                        bar(i,AIC(i),'faceColor',[.8 .8 1]);
                    end
                    maxY=1000;
                otherwise % default grey
                    for i=1:length(AIC)
                        bar(i,AIC(i),'faceColor',[.8 .8 .8]);
                        text(i,0,namesOfModels{i},'Rotation',90)
                    end
                    yl=ylim;
                    maxY=yl(2);
                    maxY=1200;
            end
            
            data=p.getDataFromSubjectCache;
            nckLL=sum(p.logNchoosekPerCondition(data));
            dataLL=p.logLiklihood(data,data.hit,data.fa,data.miss,data.cr)+nckLL;
            plot([0 length(AIC)+1],-dataLL([1 1]),'k-')
            ylabel('-log (liklihood)+2n')
            set(gca,'yTick',[0 round(-dataLL) maxY],'ylim',[0 maxY],'xlim',[0 length(AIC)+1])
            %set(gca,'xTickLabel',p.cache.namesOfModels) % leave for poster?
            set(gca,'xTick',[])
            settings.AxisLineWidth=3;
            settings.fontSize=20;
            cleanUpFigure(gcf,settings)
            
        end
        function manualHuntTrail(p)
            % %SETUP
            %             p=loadDataFromServer(p,{'234'});
            %             p=p.setViewPlots('none');
            %             p.signalCombination = 'simulationFitResults';
            %             p.sdtDistributionType='gev';
            %             optimalCritMethod='fitGev';
            %             p.critLearningRate='fit';
            %             p.save
            p=p.load
            %keyboard
            %%
            %GUESS
            x=[.75 0.51 5.6 3.1]; % LL -767
            x=[.75 0.51 5.6 3.1]; % LL -841 / 2100 / -854 / 2600
            x=[.79 0.41 5.68 2.06]; % LL -591 / 944
            x=[.79 0.35 5.68 2.06]; % LL -437
            
            p.baseline=x(2);
            p.nodesPerSpaceUnit=x(3);  % could be mm; can mean units target width when stdT=1
            p.stdEye=x(4);
            
            p=p.runSimulation();
            p.current.tc=p.tc;
            p.current.fc=p.fc;
            p=p.fitCriteria();
            tic
            %[alpha er]=p.fitLearningRateToSubjectDataGivenSimulationResults()
            p.cache.modelParams=x;
            %p.cache.modelParams(1)=alpha;
            figure; p.viewModel();
            
            %figure; p.plotModelFeatures([],[],{'sig&Noise'}); cleanUpFigure
            
            %%
            p.cache.modelParams(1)=.80;
            figure; p.viewModel();
            
            %% run one and see ROC
            
            
            %p=p.runSimulation();
            
            %p.save
            
            
            
            [alpha er]=fitLearningRateToSubjectDataGivenSimulationResults(p)
            p.cache.modelParams=alpha;
            
            %p.save
            %AIC=p.viewModel(true)
            
            keyboard
            p.current.tc=p.tc;
            p.current.fc=p.fc;
            [p crit er]=fitCriteria(p);
            figure; p.plotModelFeatures([],[],{'sig&Noise'}); cleanUpFigure
            
            figure; plotROC(p,[],[],'modelSamples',true)
        end
        function testBed(p)
            
            %p.intuitionTest
            %% load previous model same name
            %p=p.load;  %load previous results for this model name
            %
            %% run one quick
            %p=p.runSimulation([p.current.tc 0],p.current.fc);
            %figure; p.plotModelFeatures(p.current.tc,p.current.fc,{'sig&Noise'}); cleanUpFigure
            %figure; p.plotModelFeatures([],[],{'sig&Noise'}); cleanUpFigure
            %% try a big fit
            %             p=loadDataFromServer(p,{'234'});
            %             p=p.setViewPlots('none');
            %             p.signalCombination = 'simulationFitResults';
            %             p.sdtDistributionType='gev';
            %             optimalCritMethod='fitGev';
            %             p.critLearningRate='fit';
            %             p.save
            %             p=p.load
            %
            %             p=p.fitSubjectDataWithSimulation;
            %             xx=p.load; %load the last results which were *saved* in the search! backup load in case
            %             keyboard
            
            %% go ahead and look at the best one
            p.modelName='firstBigFit-nc1'
            p=p.load
            p.plotParameterConvergence()
            keyboard
            %%
            
            figure; plot(p.cache.errorHistory); hold on;
            best=find(p.cache.errorHistory==min(p.cache.errorHistory));
            plot(best,p.cache.errorHistory(best),'ro')
            drawnow
            best=1:18;
            for i=1:length(best)
                title(sprintf('%2.2f  ',p.cache.modelHistory(best(i),:)));  %remember the alpha still needs to be refit to view the model
                
                % set the current model to the best fit
                p.cache.modelParams=p.cache.modelHistory(best(i),:);
                x=p.cache.modelParams;
                p.baseline=x(2);
                p.nodesPerSpaceUnit=x(3);
                p.stdEye=x(4);
                
                
                %run sim with more samples
                p.numIttn=300;
                p=p.init;
                p.current.tc=p.tc;
                p.current.fc=p.fc;
                p=p.runSimulation();
                p.current.tc=p.tc;
                p.current.fc=p.fc;
                p=p.fitCriteria();
                
                
                tic
                [alpha er]=p.fitLearningRateToSubjectDataGivenSimulationResults()
                p.cache.modelParams(1)=alpha;
                figure; p.viewModel();
            end
            %%
            tic
            [alpha er]=p.fitLearningRateToSubjectDataGivenSimulationResults()
            p.cache.modelParams(1)=alpha;
            figure; p.viewModel();
            
            p.edges=linspace(0,0.5,100);
            %figure; p.plotModelFeatures([],[],{'sig&Noise'}); cleanUpFigure
            
            keyboard
            
            %% run one and see ROC
            
            p=p.load
            %p=p.runSimulation();
            %p=loadDataFromServer(p,{'234'});
            %p.save
            
            p=p.setViewPlots('none');
            p.signalCombination = 'simulationFitResults';
            p.sdtDistributionType='gev';
            optimalCritMethod='fitGev';
            p.critLearningRate='fit';
            
            [alpha er]=fitLearningRateToSubjectDataGivenSimulationResults(p)
            p.cache.modelParams=alpha;
            
            %p.save
            %AIC=p.viewModel(true)
            
            keyboard
            p.current.tc=p.tc;
            p.current.fc=p.fc;
            [p crit er]=fitCriteria(p);
            figure; p.plotModelFeatures([],[],{'sig&Noise'}); cleanUpFigure
            
            figure; plotROC(p,[],[],'modelSamples',true)
            
            keyboard
            %% fit some new crit
            %             p=p.runSimulation();
            %
            %             %p.edges=linspace(-550,-300,100)
            %             %p.cache.dv=-p.cache.dv;
            %             p.current.tc=p.tc;
            %             p.current.fc=p.fc;
            %             [p crit er]=fitCriteria(p);
            %             p.save
            %%
            %figure; p.plotROC([],[],'GEV'); cleanUpFigure
            %figure; p.plotModelFeatures([],[],{'sig&Noise'}); cleanUpFigure
            %keyboard
            
            %% try bayesian (stopped cuz i don't know how to fit optimal crit in winbugs script)
            %p=p.loadDataFromServer;
            %p=p.doMCMC;
            
            %% do a fit of SDT
            %p=p.loadDataFromServer;
            %p=p.fitSubjectDataWithSDT
            %p.save;
            
            %p=p.load;
            %p.viewModel
            
            %% do both rats at jointly
            %p=p.load;
            %p=p.fitSubjectDataWithSDT
            
            %% check out the DN model (unfit)
            %p=p.loadDataFromServer({'231','234'});
            %p.save;
            p=p.load;
            p.critLearningRate='fit';  %'zero','one','fit' ;fit uses erf 0-->1
            p.signalCombination = 'divisiveNormalization';
            p.signalCombination = 'linearIndependant';
            p.cache.gauss.modelParams=[1 2 2 1 1];
            p.cache.gauss.modelParams= [.81 1.96 5.67 -0.35 3.17 0.99 2.36];  % good for learning..include gamma
            figure
            bias=[.7]; %[.5 .6 .7 .8 .9 .95 .99 1 1.01 1.05 1.1 2 0.3]
            for i=1:length(bias)
                p.relativeMissCost=0.7; %bias(i);
                p.viewModel(true)
            end
            
            keyboard
            %%
            %figure; p.plotModelFeatures([],[],{'responseWithContrastEnvelope'}); cleanUpFigure
            %figure; p.plotModelFeatures([],[],{'responseWithCombinedEnvelope'}); % all
            %figure; p.plotModelFeatures(1,0.5,{'responseWithCombinedEnvelope','attn','contrast'}); cleanUpFigure
            %figure; p.plotModelFeatures(1,0.5,{'responseWithCombinedEnvelope'}); cleanupFigure % one
            %figure; p.plotModelFeatures(1,0.5,{'responseWithContrastEnvelope','attn'}); cleanUpFigure
            figure; p.plotROC([],[]); cleanUpFigure
            
            %figure; p.plotModelFeatures([],[],{'Q-Q'}) % quantile-quantile plot
            %figure; p.plotModelFeatures();
            %figure; p.plotModelFeatures([],[],{'responseWithCombinedEnvelope','attn','contrast'},[5 1 2]); cleanUpFigure
            figure; p.plotModelFeatures([],[],{'evFit'}); cleanUpFigure
            figure; p.plotModelFeatures([],[],{'sig&Noise'}); cleanUpFigure
            
            figure; p.plotModelFeatures([0.5],[0.75],{'responseWithCombinedEnvelope','attn','contrast'},[5 1 2]); cleanUpFigure
            
            %%
            p=p.fitAllStdAttn;
            stdAttn=p.fitStdAttn()
        end
        function plotParameterConvergence(p)
            n=size(p.cache.modelHistory,1);
            np=size(p.cache.modelHistory,2);
            plot(repmat([1:4]+0.3,n,1)',p.cache.modelHistory','r.'); hold on
            plot(repmat([1:4],n,1)',p.cache.x0','k.'); hold on
            for i=1:n
                for j=1:np
                    plot([j j+0.3],[p.cache.x0(i,j) p.cache.modelHistory(i,j)],'k-')
                end
            end
            
        end
        function p=fitSubjectDataWithSDT(p,x0)
            [data params]=p.getDataFromSubjectCache;
            
            if any(unique([0 params.tcs])~=p.tc) || any(unique(params.fcs)~=p.fc)
                unique([0 params.tcs])
                unique(params.fcs)
                p.tc
                p.fc
                error('may have issues with relating model to the subject data becuase different contrast values')
            end
            
            if ~exist('x0','var') || isempty(x0)
                x0= [.7 2 4 -0.2 1.6 ];  % example parameters, may not fit with current
                %lb=[-100  -100 -100 -100 -100];
                %ub=[100  100  100  100  100];
                %[x er]=fminbnd(@(x)gaussMLErrorFun(p,x,data,params),lb,ub); %sometimes way left of the whole distibution
                x0=nan(1,length(p.modelFeatures)); %allow default for all of them
            end
            
            [x er]=fminsearch(@(x)gaussLinearSimpleMLErrorFun(p,x,data,params),x0); %get trapped with
            p=p.setGaussDistParamsFromModelFit(x);
            
            
            if flag~=1
                p.current
                warning('bad fit..why?')
                keyboard
            end
            
            %p.plotROC([],[],'subject');
            %p.plotROC([],[],'gauss');
            %p.save; bad idea b/c params get stuck
        end
        function LL=logLiklihood(p,data,hit,fa,miss,cr)
            
            %challenge:  small values of rate^trial turn into zero, which
            %dominates the sum of log(p) with -inf
            %old code less stable
            %             LL=sum(log(hit.^data.numHits))+ sum(log(miss.^data.numMisses))...
            %                 +sum(log(fa.^data.numFAs)) + sum(log(cr.^data.numCRs));
            
            %avoid edges in the raw probalilties (not a problem for gauss, but yes for gev)
            small=0.0001;
            hit(hit<small)=small;
            miss(miss<small)=small;
            fa(fa<small)=small;
            cr(cr<small)=small;
            
            hit(hit>1-small)=1-small;
            miss(miss>1-small)=1-small;
            fa(fa>1-small)=1-small;
            cr(cr>1-small)=1-small;
            
            %stabler way of doing this
            LL=sum(log(hit).*data.numHits...
                +log(miss).*data.numMisses...
                +log(fa).*data.numFAs...
                +log(cr).*data.numCRs);
        end
        function x=logNchoosekPerCondition(p,data)
            for i=1:length(data.numHits)
                turnOffWarning=true;
                nckS(i)=log(nchoosek(data.numSig(i),data.numHits(i),turnOffWarning));
                nckN(i)=log(nchoosek(data.numNoSig(i),data.numFAs(i),turnOffWarning));
            end
            x=nckS+nckN;
        end
        
        function [p, muS,muN,sigmaS,sigmaN,shapeS,shapeN]=getSDTparams(p,x,tcs,fcs)
            % this generalizes and replaces: getLinearMuSigma, getNonLinearMuSigma
            % but not: getSimulationFitMuSigma
            %
            %an IDEA: [p, params]=getSDTparams(p,x,tcs,fcs); pushParamsIntoWorkSpace(params)
            
            features=p.modelFeatures;
            
            if length(x)~=length(features)
                features
                x
                [length(features) length(x)]
                error('number of initial params must match the number of features')
            end
            
            %default
            tm=1; % basic sdt
            fm=1;
            ts=0; % no influence on sigma
            fs=0;
            gammaT=1; % no gamma -- linear
            gammaF=1;
            
            addGevShape=p.isGEV();
            if addGevShape
                kappa=-0.3;
                tk=0;
                fk=0;
            end
            
            doDivisiveNorm=any(ismember(features,{'c50','fallOff','noSigNoiseStd'}));
            if doDivisiveNorm
                c50=1;
                fallOff=10; %1 ~ exp^large= no fallOff, normalize to full screen, not locally
                noSigNoiseStd=1; % crazy variance changing: ones(1,length(tce))./(c50+(tcs + 2*fallOff*fcs).^((gammaT+gammaF)/2));  % maybe this should be learned in the dn mode, bc all signal (muN) changes are with respect to it.. curvature under 1...
            end
            
            dependantFeatures=[]; dx=[];
            for i=1:length(features)
                if ~isnan(x(i)) % nans will allow inputs to be default to the above
                    switch features{i}
                        case {'tm','fm','ts','fs','gammaT','gammaF','kappa','tk','fk','c50'}
                            cmd=sprintf('%s=x(i);',features{i});
                            try
                                eval(cmd);
                            catch ex
                                cmd
                                getReport(ex)
                                error('cmd failed')
                            end
                        case {'alpha'}
                            % alpha is an acceptable model feature, but it's not actually used in this function
                        case {'gamma'}
                            gammaT=x(i);
                            gammaF=x(i);
                            if any(ismember(features,{'gammaT','gammaF'}))
                                error('can''t define general and t/f specific value for the same parameter!')
                            end
                        case {'sigma'}
                            ts=x(i);
                            fs=x(i);
                            if any(ismember(features,{'ts','fs'}))
                                error('can''t define general and t/f specific value for the same parameter!')
                            end
                        case {'bias'}
                            p.relativeMissCost=exp(x(i));
                            %log(miss/hit)=b
                        case {'sigmaPerMean'}
                            dependantFeatures{end+1}=features{i};
                            dx(end+1)=exp(x(i)); % negative would be nonsense
                        case {'fallOff'}
                            fallOff=1/(1+exp(-x(i))); %sigmoid bounds between 0 and 1
                            %(this could be a gaussian falloff, but a single value is equvalent to search through, when we only have 1 radius implimented)
                        otherwise
                            features{i}
                            error('unsupported feature')
                    end
                end
            end
            
            for i=1:length(dependantFeatures)
                switch dependantFeatures{i}
                    case {'sigmaPerMean'}
                        sigmaPerMean=dx(i);
                        ts=tm*sigmaPerMean;
                        fs=fm*sigmaPerMean;
                        if any(ismember(features,{'ts','fs','sigma'}))
                            error('can''t define a ratio and a search value over the same parameter!')
                        end
                end
            end
            
            if doDivisiveNorm
                t=tcs;%for debug
                f=fcs;
                tcs=tcs.^gammaT./(c50+(fcs + 2*fallOff*tcs).^(gammaT));
                fcs=fcs.^gammaF./(c50+(fcs + fallOff*tcs).^(gammaF)); % ignoring the effect of the other flanker
                %close all; figure; plot(tcs,'g'); hold on; plot(fcs,'r')
                if any(imag(tcs)~=0) || any(imag(fcs)~=0)
                    t
                    tcs
                    fallOff
                    warning('contrast can''t be complex')
                    keyboard
                end
                
                
                %THIS IS AN INTERESTING OPTION I NEVER TESTED:
                %fcb=fcs+baseline;
                %fce=fcb.^gammaF./(c50+(fcs + fallOff*tcs).^((gammaT+gammaF)/2));
                %is  enables ZERO CONTRAST FLANKERS to still have a noise floor signal (mu>0) that targets can modify
                % could also consider a small reduction in the sigma...
                % but thats complicated and should link about variane
                % going with mean and effects to combat it
                %noSigNoiseStd=1; % crazy variance changing: ones(1,length(tce))./(c50+(tcs + 2*fallOff*fcs).^((gammaT+gammaF)/2));  % maybe this should be learned in the dn mode, bc all signal (muN) changes are with respect to it.. curvature under 1...
            else
                tcs=tcs.^gammaT;
                fcs=fcs.^gammaF;
            end
            
            %MEANS
            muS=tcs*tm+fcs*fm;
            muN=fcs*fm;
            
            %SIGMAS
            if doDivisiveNorm
                sigmaS=max(noSigNoiseStd+tcs*ts+fcs*fs,0.001);
                sigmaN=max(noSigNoiseStd+fcs*fs,0.001);
            else
                sigmaS=max(1+tcs*ts+fcs*fs,0.001);
                sigmaN=max(1+fcs*fs,0.001);
            end
            
            %SHAPE
            if addGevShape
                shapeS=kappa+tcs*tk+fcs*fk;
                shapeN=kappa+fcs*fk;
                %shape is bounded between -1 and 1
                %should be... bounded, but isnt.
            else
                shapeS=[];
                shapeN=[];
            end
            
        end
        
        
        function [p, muS,muN,sigmaS,sigmaN,shapeS,shapeN]=getSimulationFitMuSigma(p,x,tcs,fcs);
            
            %preallocate
            muS=nan(1,length(tcs));
            muN=nan(1,length(tcs));
            sigmaS=nan(1,length(tcs));
            sigmaN=nan(1,length(tcs));
            shapeS=nan(1,length(tcs));  % also default for guass which doe not use shape
            shapeN=nan(1,length(tcs));
            [fInd tInd tIndNoSig]=getContrastIndsFromCurrentOrArg(p);
            for f=1:p.numFc
                for t=1:p.numTc
                    which=tcs==p.tc(tInd(t)) & fcs==p.fc(fInd(f));
                    switch p.sdtDistributionType %this was set by p.optimalCritMethod in a simulation fit, %'fitGev' / %'fitGauss'
                        case 'gev'
                            muS(which)=p.cache.xs(fInd(f),tInd(t),3);
                            muN(which)=p.cache.xn(fInd(f),tInd(t),3);
                            sigmaS(which)=p.cache.xs(fInd(f),tInd(t),2);
                            sigmaN(which)=p.cache.xn(fInd(f),tInd(t),2);
                            shapeS(which)=p.cache.xs(fInd(f),tInd(t),1);
                            shapeN(which)=p.cache.xn(fInd(f),tInd(t),1);
                        case 'gaussian'
                            error('not yet')
                        otherwise
                            p.optimalCritMethod
                            error('bad')
                    end
                end
            end
        end
        function [hit fa miss cr adjustedCrit critUsed params]=getRatesAndCriteria(p,x,tcs,fcs,params,anchorCriteria)
            
            %the model parameter relationships
            switch p.parameterSource
                case 'parametericSDT'
                    [p,muS,muN,sigmaS,sigmaN,shapeS,shapeN]=getSDTparams(p,x,tcs,fcs);
                    %                 case 'linearIndependant'
                    %                     [p,muS,muN,sigmaS,sigmaN,shapeS,shapeN]=getSDTparams(p,x,tcs,fcs);
                    %                 case 'divisiveNormalization'
                    %                     [p,muS,muN,sigmaS,sigmaN,shapeS,shapeN]=getSDTparams(p,x,tcs,fcs);
                case 'simulationFitResults'
                    [p,muS,muN,sigmaS,sigmaN,shapeS,shapeN]=getSimulationFitMuSigma(p,x,tcs,fcs);
                case 'simulationFitResultsSplined'
                    %maybe
                    error('not yet')
            end
            
            adjustedCrit=nan(1,length(muS));
            for i=1:length(muS);   %the optimal (unbiased) criteria per condition
                if p.hasBiasFeature() %length(x)>11
                    try
                        %in current code this must be both rats, with bias term for each
                        sID=params.subjectID(i)~=params.subjectID(1)+1; % evaluates to 1 and 2 for 1st and 2nd rat (not good for n rats)
                        biasID=find(strcmp(p.modelFeatures,'bias'));
                        p.relativeMissCost=exp(x(biasID+sID-1));
                        %log(miss/hit)=b
                    catch ex
                        getReport(ex)
                        keyboard
                    end
                end
                
                if p.isGEV
                    adjustedCrit(i)=p.fitCriterionFromEvdParams([shapeN(i) sigmaN(i) muN(i)],[shapeS(i) sigmaS(i) muS(i)]);
                else
                    adjustedCrit(i)=p.fitCriterionFromGaussParams([muN(i) sigmaN(i)],[muS(i) sigmaS(i)]);
                end
            end
            
            if ~exist('anchorCriteria','var') || isempty(anchorCriteria)
                anchorCriteria=mean(adjustedCrit);
            else
                anchorCriteria=anchorCriteria;
            end
            
            %             p.relativeMissCost=1;
            %             critUnbiased=nan(1,length(muS));
            %             for i=1:length(muS);
            %                 %the optimal (unbiased) criteria
            %                critUnbiased(i)=p.fitCriterionFromGaussParams([muN(i) sigmaN(i)],[muS(i) sigmaS(i)]);
            %             end
            
            fractionLearned=p.getCritLearningRate(x(1));
            critUsed=adjustedCrit*fractionLearned+anchorCriteria*(1-fractionLearned);
            
            if p.isGEV
                miss=gevcdf(critUsed,shapeS,sigmaS,muS); hit=1-miss;
                cr=gevcdf(critUsed,shapeN,sigmaN,muN); fa=1-cr;
            else
                miss=normcdf(critUsed,muS,sigmaS); hit=1-miss;
                cr=normcdf(critUsed,muN,sigmaN); fa=1-cr;
            end
            
            [hit fa miss cr] = p.adjustForGuessingAndBias(x,params,hit,fa,miss,cr);
            
            params.anchorCriteria=anchorCriteria;
            params.muS=muS;
            params.muN=muN;
            params.sigmaS=sigmaS;
            params.sigmaN=sigmaN;
            params.shapeS=shapeS;
            params.shapeN=shapeN;
        end
        function er=gevLinearSimpleMLErrorFun(p,x,data,params)
            %the model parameter relationships, the criteria rule, giving relevant intermediate params
            [hit fa miss cr adjustedCrit critUsed params]=p.getRatesAndCriteria(x,params.tcs,params.fcs,params);
            
            %the liklihood
            params.modelLL=p.logLiklihood(data,hit,fa,miss,cr);
            er=-2*params.modelLL; % + a constant for the data
            
            doPlot=rand<0.05;
            doPlot=0;
            if doPlot
                p.viewOnGoingFit(hit,miss,fa,cr,data,x,params,[1 2],true)
                
                
                figure(3);
                for i=1:length(params.muS);
                    subplot(params.numTc,params.numFc,i); hold off
                    loc=linspace(-10,10,100);
                    plot(loc,gevpdf(loc,params.shapeS(i),params.sigmaS(i),params.muS(i)),'g'); hold on
                    plot(loc,gevpdf(loc,params.shapeN(i),params.sigmaN(i),params.muN(i)),'r')
                    
                    plot(params.anchorCriteria([1 1]),ylim,'m')
                    plot(critUsed([i i]),ylim,'k')
                    set(gca,'xtick',[],'ytick',[],'ylim',[0 .4])
                    plot(adjustedCrit([i i]),ylim,'r--')
                    xlabel(sprintf('tc:%2.2f fc:%2.2f',params.tcs(i),params.fcs(i)) )
                    
                end
                set(gcf,'position',[800 100 750 750])
                drawnow
            end
            disp(toc) % just to know things are running, and how long per pass
        end
        function er=gaussLinearSimpleMLErrorFun(p,x,data,params)
            
            
            %the model parameter relationships, the criteria rule, giving relevant intermediate params
            [hit fa miss cr adjustedCrit critUsed params]=p.getRatesAndCriteria(x,params.tcs,params.fcs,params);
            
            %the liklihood
            params.modelLL=p.logLiklihood(data,hit,fa,miss,cr);
            er=-2*params.modelLL; % + a constant for the data
            
            doPlot=rand<0.05;
            doPlot=0;
            if doPlot
                p.viewOnGoingFit(hit,miss,fa,cr,data,x,params,[1 2],true);
                
                figure(3);
                for i=1:params.numTc*params.numFc;
                    subplot(params.numTc,params.numFc,i); hold off
                    loc=linspace(-5,5,100);
                    % loc=linspace(-10,10,100);
                    plot(loc,normpdf(loc,params.muS(i),params.sigmaS(i)),'g'); hold on
                    plot(loc,normpdf(loc,params.muN(i),params.sigmaN(i)),'r')
                    
                    plot(params.anchorCriteria([1 1]),ylim,'m')
                    plot(critUsed([i i]),ylim,'k')
                    set(gca,'xtick',[],'ytick',[],'ylim',[0 .4])
                    plot(adjustedCrit([i i]),ylim,'r--')
                    xlabel(sprintf('tc:%2.2f fc:%2.2f',params.tcs(i),params.fcs(i)) )
                    
                end
                set(gcf,'position',[800 100 750 750]);
                drawnow
            end
%             if rand<0.05
%                 fprintf('%2.2f',er)
%             else
%                 fprintf('.')
%             end
        end
        function AIC=viewOnGoingFit(p,hit,miss,fa,cr,data,x,params,handles,includeSubjectData)
            
            if 0 % not used now
                figure(handles(2)); hold off
                plot(log(hit.^data.numHits.*miss.^data.numMisses),'g-'); hold on
                plot(log(fa.^data.numFAs.*cr.^data.numCRs),'r-');
                set(gcf,'position',[50 900 500 200])
            end
            
            figure(handles(1)); hold off
            plot([0 1],[0 1],'k'); hold on
            if includeSubjectData
                plot(data.fa,data.hit,'.k');
                plot(data.fa(1:5:16),data.hit(1:5:16),'.b');
                
                
                plot(fa,hit,'ok');
                plot(fa(end-params.numTc:end),hit(end-params.numTc:end),'or');
                plot(fa(1:5:16),hit(1:5:16),'ob');
            end
            
            % plot one criterion curve
            cInd=length(params.muS)-p.numTc+1; %full contrast no flank ind
            
            if p.isGEV
                n=30;
                %critSweep=linspace(-3,2,n);
                critSweep=linspace(.1,.7,n);
                [tempParams numSubs]=p.adjustSubjectsIndex(params,n);
                h=1-gevcdf(repmat(critSweep,1,numSubs),params.shapeS(cInd),params.sigmaS(cInd),params.muS(cInd));
                f=1-gevcdf(repmat(critSweep,1,numSubs),params.shapeN(cInd),params.sigmaN(cInd),params.muN(cInd));
            else
                %'gaussian'
                n=20;
                critSweep=linspace(-1,3,n);
                [tempParams numSubs]=p.adjustSubjectsIndex(params,n);
                h=1-normcdf(repmat(critSweep,1,numSubs),params.muS(cInd),params.sigmaS(cInd));
                f=1-normcdf(repmat(critSweep,1,numSubs),params.muN(cInd),params.sigmaN(cInd));
            end
            
            [h f] = p.adjustForGuessingAndBias(x,tempParams,h,f);
            plot(f,h,'color',[0.8 0.8 0.8])
            
            for i=2:params.numTc+1  %fc curves, tc==1 --> blue
                n=40; % sample points along arc
                [modParams numSubs]=p.adjustSubjectsIndex(params,n);
                
                %fcs=linspace(-0.5,3,n); % watch it fall to zero for "negative flanker contrast"
                fcs=repmat(linspace(0,5,n),1,numSubs); % watch it fall to zero for "negative flanker contrast"
                
                tcs=p.tc(i)*ones(1,n*numSubs);  % subject-model same contrast assumption was previously checked
                %[muS muN sigmaS sigmaN]=getSDTparams(p,x,tcs,fcs);
                [h f]=p.getRatesAndCriteria(x,tcs,fcs,modParams,params.anchorCriteria);
                if i==params.numTc+1
                    plot(f,h,'r')
                else
                    plot(f,h,'k')
                end
            end
            
            for i=1:params.numFc % tc curves, fc==0 --> red
                n=40; % sample points along arc
                [modParams numSubs]=p.adjustSubjectsIndex(params,n);
                tcs=repmat(logspace(0.001,10,n),1,numSubs);
                tcs=repmat(logspace(-3,1,n),1,numSubs);
                fcs=p.fc(i)*ones(1,n*numSubs);  % subject-model same contrast assumption was previously checked
                %[muS muN sigmaS sigmaN]=getSDTparams(p,x,tcs,fcs);
                [h f]=p.getRatesAndCriteria(x,tcs,fcs,modParams,params.anchorCriteria);
                if i==1
                    plot(f,h,'b')
                else
                    plot(f,h,'k')
                end
            end
            
            xlabel('False Alarm Rate')
            ylabel('Hit Rate')
            axis square
            set(gca,'xTick',[0 1],'xTickLabel',[0  1],'yTick',[0  1],'yTickLabel',[0  1])
            
            AIC=writeParameterValues(p,x,data,params);
            set(gcf,'position',[50 100 750 750])
            drawnow
        end
        function [params numSubs]=adjustSubjectsIndex(p,params,n);
            numSubs=length(unique(params.subjectID));
            switch numSubs
                case 1
                    %nothing to do
                    first=params.subjectID(1);
                    params.subjectID=[repmat(first,1,n)]; % overwrite for the new size
                case 2
                    %get the values
                    first=params.subjectID(1);
                    second=params.subjectID(end);
                    params.subjectID=[repmat(first,1,n) repmat(second,1,n)]; % overwrite for the new size
                otherwise
                    error('code written for 2 subjects')
            end
            
            
        end
        function AIC=writeParameterValues(p,x,data,params)
            
            nckLL=sum(p.logNchoosekPerCondition(data));
            numParams=length(x);
            if ~strcmp(p.critLearningRate,'fit')
                % if alpha (learning rate) was not fit, don't count it
                numParams=numParams-1;
            end
            AIC=2*numParams-(params.modelLL+nckLL);
            
            features=p.modelFeatures;
            for i=1:length(features)
                values(i)=x(i); % default just trace the value... some features over write this with a transform
                switch features{i}
                    case 'alpha'
                        values(i)=p.getCritLearningRate(x(1));
                        names{i}='\alpha';
                    case 'tm'
                        names{i}='\mu_t';
                    case 'fm'
                        names{i}='\mu_f';
                    case 'ts'
                        names{i}='\sigma_t';
                    case 'fs'
                        names{i}='\sigma_f';
                    case 'sigma'
                        names{i}='\sigma';
                    case 'sigmaPerMean'
                        names{i}='log \sigma:\mu';
                        %values(i)=x(i);
                    case 'bias'
                        names{i}='b';
                        values(i)=x(i);
                    case 'c50'
                        names{i}='C_{50}';
                    case 'gamma'
                        names{i}='\gamma';
                    case 'gammaT'
                        names{i}='\gamma_t';
                    case 'gammaF'
                        names{i}='\gamma_f';
                    case 'fallOff'
                        names{i}='\lambda';
                        values(i)=1/(1+exp(-x(i)));
                    case 'kappa'
                        names{i}='\kappa_0';
                    case 'tk'
                        names{i}='\kappa_t';
                    case 'fk'
                        names{i}='\kappa_f';
                    case {'guess1','guess2','yes|guess1','yes|guess2'}
                        error('not yet')
                        %elseif length(x)==13
                        %    names{end+1}='g_1'; %8
                        %    names{end+1}='g_2'; %9
                        %    names{end+1}='y|g_1';%10
                        %    names{end+1}='y|g_2';%11
                        %    names{end+1}='b_1';%12
                        %    names{end+1}='b_2';%13
                        %    values(8:11)=[1 1 1 1]./(1+exp(x(8:11)));
                        %    values(12:13)=x(12:13);
                        %end
                        %HISTORICALLY HAS ONLY RUN WITH DN
                    case 'baseline'
                        names{i}='baseline';
                    case 'D'
                        names{i}='D';
                    case 'gazeStd'
                        names{i}='\sigma_{gaze}';
                    otherwise
                        features{i}
                        error('bad feature')
                end
            end
            
            str='';
            for i=1:length(names)
                str=[str sprintf('%s:  %2.2f\n',names{i},values(i))];
            end
            
            %add liklihood display
            str=[str sprintf('\n')];
            str=[str sprintf('%s:  %2.2f\n','LL_{model}',params.modelLL+nckLL)];
            str=[str sprintf('%s:  %2.2f\n','LL_{data}', params.dataLL+nckLL) ];
            str=[str sprintf('%s:  %2.2f\n','AIC', AIC)];
            
            gutter=0.05;
            text(1-gutter,gutter,str,'VerticalAlignment','bottom','HorizontalAlignment','right')
            
        end
        function AIC=viewModel(p,includeSubjectData,titleName)
            if ~exist('includeSubjectData','var') || isempty(includeSubjectData)
                includeSubjectData=true;
            end
            if ~exist('titleName','var') || isempty(titleName)
                titleName='';
            end
            
            %             if ~exist('x','var') || isempty(x)
            %                 x=p.cache.gauss.modelParams;  % hmm default will error if gev was used...
            %             end
            
            x=p.cache.modelParams;
            [data params]=p.getDataFromSubjectCache;
            [hit fa miss cr adjustedCrit critUsed params]=getRatesAndCriteria(p,x,params.tcs,params.fcs,params);
            params.modelLL=p.logLiklihood(data,hit,fa,miss,cr); % raw unadjusted before nchoosek
            
            AIC=p.viewOnGoingFit(hit,miss,fa,cr,data,x,params,gcf,true);
            if includeSubjectData
                includeArrows=false;
                p.plotROC([],[],'subject',includeArrows);
            end
            
            set(gca,'ytick',[0 1],'yTickLabel',{'0','1'});
            settings=[];
            settings.LineWidth=3;
            settings.AxisLineWidth=3;
            settings.textObjectFontSize=12;
            settings.fontSize=20;
            settings.MarkerSize=12;
            title(titleName)
            cleanUpFigure(gcf,settings)
            
        end
        function p=setDistParamsFromModelFit(p,x);
            switch p.sdtDistributionType
                case {'eqVarGaussian', 'gauss'}
                    p=setGaussDistParamsFromModelFit(p,x)
                case 'gev'
                    %warning('here')
                    %keyboard
                    % see below
                    [data params]=p.getDataFromSubjectCache
                    [hit fa miss cr adjustedCrit critUsed params]=p.getRatesAndCriteria(x,params.tcs,params.fcs,params);
                    
                    % avoid dirty solution below
                    p.cache.gev.modelParams=x;
                    p.cache.gev.crit=nan(p.numFc,p.numTc); %need to size it and jump over zero contrast targets
                    p.cache.gev.xs=nan(p.numFc,p.numTc,2); %need to size it and jump over zero contrast targets
                    p.cache.gev.xn=nan(p.numFc,p.numTc,2); %need to size it and jump over zero contrast targets
                    p.cache.gev.crit(:,2:end)=reshape(adjustedCrit,params.numFc,params.numTc);
                    p.cache.gev.xs(:,2:end,3)=reshape(params.muS,params.numFc,params.numTc);
                    p.cache.gev.xs(:,2:end,2)=reshape(params.sigmaS,params.numFc,params.numTc);
                    p.cache.gev.xs(:,2:end,1)=reshape(params.shapeS,params.numFc,params.numTc);
                    p.cache.gev.xn(:,2:end,3)=reshape(params.muN,params.numFc,params.numTc);
                    p.cache.gev.xn(:,2:end,2)=reshape(params.sigmaN,params.numFc,params.numTc);
                    p.cache.gev.xn(:,2:end,1)=reshape(params.shapeN,params.numFc,params.numTc);
                    
                    %set the "no" signal one to be overlapping with the weakest
                    %signal (not correct but its least intrusive to the plot)
                    p.cache.gev.xn(:,1,:)=p.cache.gev.xn(:,2,:);
                    p.cache.gev.xs(:,1,:)=p.cache.gev.xs(:,2,:);
                    p.cache.gev.crit(:,1)=p.cache.gev.crit(:,2);
                    
                    p.cache.modelParams=x;
                    
                    
                otherwise
                    error('not yet')
            end
        end
        function p=setGaussDistParamsFromModelFit(p,x)
            
            
            temp=p.relativeMissCost;
            p.relativeMissCost=exp(x(1));
            tm=x(2);
            fm=x(3);
            if x>3
                ts=x(4);
                fs=x(5);
            else
                ts=0;
                fs=0;
            end
            params.tcs=p.cache.subjectData.params.factors.targetContrast;
            params.fcs=p.cache.subjectData.params.factors.flankerContrast;
            params.numTc=length(unique(params.tcs));
            params.numFc=length(unique(params.fcs));
            
            muS=params.tcs*tm+params.fcs*fm;
            muN=params.fcs*fm;
            sigmaS=max(1+params.tcs*ts+params.fcs*fs,0.001);
            sigmaN=max(1+params.fcs*fs,0.001);
            
            for i=1:length(muS);
                %the optimal biased-adjusted criteria
                adjustedCrit(i)=p.fitCriterionFromGaussParams([muN(i) sigmaN(i)],[muS(i) sigmaS(i)]);
            end
            p.relativeMissCost=temp; %return prev value
            
            p.cache.gauss.modelParams=x;
            p.cache.gauss.crit=nan(p.numFc,p.numTc); %need to size it and jump over zero contrast targets
            p.cache.gauss.xs=nan(p.numFc,p.numTc,2); %need to size it and jump over zero contrast targets
            p.cache.gauss.xn=nan(p.numFc,p.numTc,2); %need to size it and jump over zero contrast targets
            p.cache.gauss.crit(:,2:end)=reshape(adjustedCrit,params.numFc,params.numTc);
            p.cache.gauss.xs(:,2:end,1)=reshape(muS,params.numFc,params.numTc);
            p.cache.gauss.xs(:,2:end,2)=reshape(sigmaS,params.numFc,params.numTc);
            p.cache.gauss.xn(:,2:end,1)=reshape(muN,params.numFc,params.numTc);
            p.cache.gauss.xn(:,2:end,2)=reshape(sigmaN,params.numFc,params.numTc);
            
            %set the "no" signal one to be overlapping with the weakest
            %signal (not correct but its least intrusive to the plot)
            p.cache.gauss.xn(:,1,:)=p.cache.gauss.xn(:,2,:);
            p.cache.gauss.xs(:,1,:)=p.cache.gauss.xs(:,2,:);
            p.cache.gauss.crit(:,1)=p.cache.gauss.crit(:,2);
            
            p.cache.modelParams=x;
        end
        function p=doMCMC(p)
            %mcmcFile=fullfile(getRatrixPath, 'analysis', 'matbugs', 'BayesSDT','BayesSDT_v2.txt');
            
            n=length(p.cache.raw.numHits);
            burnin=500;
            nsamples=burnin+p.numIttn;
            
            %cd(p.savePath) may cause problems
            
            %temp faster
            nsamples=100; burnin=50;
            
            ww=2;
            switch ww
                case 1%test
                    %                     prevDir=pwd;
                    %                     cd(fullfile(getRatrixPath, 'analysis', 'matbugs', 'BayesSDT'));
                    %                      mcmcFile=fullfile(pwd,'test.txt');
                    %                     init0.d = zeros(n,1);
                    %                     init0.c = zeros(n,1);
                    %                     datastruct = struct('H',p.cache.raw.numHits ,'F',p.cache.raw.numFAs,'M',p.cache.raw.numMisses,'C',p.cache.raw.numCRs,...
                    %                         'TC',p.cache.subjectData.params.factors.targetContrast,'FC',p.cache.subjectData.params.factors.targetContrast,...
                    %                         'NDATASETS',n);
                    %                     [samples, stats, structarray] = matbugs(datastruct, ...
                    %                         mcmcFile, ...
                    %                         'init', init0, ...
                    %                         'nChains', 1, ...
                    %                         'view', 0, 'nburnin', 0, 'nsamples', nsamples, ...
                    %                         'thin', 1, 'DICstatus', 0, 'refreshrate',10, ...
                    %                         'monitorParams', {'d','c','h','f','kf','kt','crit','mu'}, ...
                    %                         'Bugdir', 'C:/Program Files/WinBUGS14')
                    %                     cd(prevDir); %return to where you were
                    
                case 2
                    error('where i left off')
                    prevDir=pwd;
                    cd(fullfile(getRatrixPath, 'analysis', 'matbugs', 'BayesSDT'));
                    %mcmcFile=fullfile(pwd,'BayesSDT_v2.txt');
                    mcmcFile=fullfile(pwd,'test.txt');
                    init0.d = zeros(n,1);
                    init0.c = zeros(n,1);
                    datastruct = struct('H',p.cache.raw.numHits ,'F',p.cache.raw.numFAs,'M',p.cache.raw.numMisses,'C',p.cache.raw.numCRs,...
                        'TC',p.cache.subjectData.params.factors.targetContrast,'FC',p.cache.subjectData.params.factors.targetContrast,...
                        'NDATASETS',n);
                    [samples, stats, structarray] = matbugs(datastruct, ...
                        mcmcFile, ...
                        'init', init0, ...
                        'nChains', 1, ...
                        'view', 0, 'nburnin', 0, 'nsamples', nsamples, ...
                        'thin', 1, 'DICstatus', 0, 'refreshrate',10, ...
                        'monitorParams', {'d','c','h','f','kt','kf','gev'}, ...
                        'Bugdir', 'C:/Program Files/WinBUGS14')
                    cd(prevDir); %return to where you were
                case 2.5 % a backup that works
                    
                    prevDir=pwd;
                    cd(fullfile(getRatrixPath, 'analysis', 'matbugs', 'BayesSDT'));
                    %mcmcFile=fullfile(pwd,'BayesSDT_v2.txt');
                    mcmcFile=fullfile(pwd,'test1.txt');
                    init0.d = zeros(n,1);
                    init0.c = zeros(n,1);
                    datastruct = struct('H',p.cache.raw.numHits ,'F',p.cache.raw.numFAs,'M',p.cache.raw.numMisses,'C',p.cache.raw.numCRs,...
                        'TC',p.cache.subjectData.params.factors.targetContrast,'FC',p.cache.subjectData.params.factors.targetContrast,...
                        'NDATASETS',n);
                    [samples, stats, structarray] = matbugs(datastruct, ...
                        mcmcFile, ...
                        'init', init0, ...
                        'nChains', 1, ...
                        'view', 0, 'nburnin', 0, 'nsamples', nsamples, ...
                        'thin', 1, 'DICstatus', 0, 'refreshrate',10, ...
                        'monitorParams', {'d','c','h','f','k','b'}, ...
                        'Bugdir', 'C:/Program Files/WinBUGS14')
                    cd(prevDir); %return to where you were
                case 3
                    mcmcFile=fullfile(pwd,p.mcmcModel); %
                    datastruct = struct('H',p.cache.raw.numHits ,'F',p.cache.raw.numFAs,'M',p.cache.raw.numMisses,'C',p.cache.raw.numCRs,...
                        ...'TC',p.cache.subjectData.params.factors.targetContrast*4,'FC',p.cache.subjectData.params.factors.targetContrast*4,...
                        'NDATASETS',n);
                    
                    [mcmc.samples, mcmc.stats, mcmc.structarray] = matbugs(datastruct, ...
                        mcmcFile, ...
                        'init', init0, ...
                        'nChains', 1, ...
                        'view', 0, 'nburnin', burnin, 'nsamples', nsamples, ...
                        'thin', 1, 'DICstatus', 0, 'refreshrate',10, ...
                        'monitorParams', {'kt','kf','ut','uf','st','sf','crit'}, ...
                        'Bugdir', 'C:/Program Files/WinBUGS14');
            end
            
            error('GOT TO MCMC END FINE')
            p.cache.mcmc=mcmc;
        end
        function intuitionTest(p)
            
            p.modelName='modelGroup'
            p=p.load
            
            [data params]=p.getDataFromSubjectCache
            x=[1 2 0 .05 1 1.4 0.9];
            [hit fa miss cr adjustedCrit critUsed params]=p.getRatesAndCriteria(x,params.tcs,params.fcs,params);
            params.modelLL=p.logLiklihood(data,hit,fa,miss,cr);
            p.viewOnGoingFit(hit,miss,fa,cr,data,x,params,[1 2],true)
            
            figure(3);
            for i=1:params.numTc*params.numFc;
                subplot(params.numTc,params.numFc,i); hold off
                loc=linspace(-5,5,100);
                plot(loc,normpdf(loc,params.muS(i),params.sigmaS(i)),'g'); hold on
                plot(loc,normpdf(loc,params.muN(i),params.sigmaN(i)),'r')
                
                plot(params.anchorCriteria([1 1]),ylim,'m')
                plot(critUsed([i i]),ylim,'k')
                set(gca,'xtick',[],'ytick',[],'ylim',[0 1])
                plot(adjustedCrit([i i]),ylim,'r--')
                xlabel(sprintf('tc:%2.2f fc:%2.2f',params.tcs(i),params.fcs(i)) )
            end
            
            
            p.cache.modelParams=x;
            p.viewModel(false)
            
            %%
            figure
            plot([0 1],[0 1],'k-');
            axis square
            set(gca,'xtick',[0 1],'ytick',[0 1])
            cleanUpFigure
        end
        function p=setGevParams(p,mode)
            
            [junk junk tIndNoSig]=p.getContrastIndsFromCurrentOrArg();
            switch mode
                case 'test'
                    for f=1:p.numFc
                        for t=1:p.numTc
                            %                             p.cache.xs(f,t,1)= 0.01; % k- shape
                            %                             p.cache.xs(f,t,2)= 0.01+0.01*p.tc(t)+ 0.05*p.fc(f);% sigma- scale
                            %                             p.cache.xs(f,t,3)= 0.05*p.tc(t)+ 0.05*p.fc(f);% mu- location
                            
                            %                             p.cache.xs(f,t,1)= 0.2; % k- shape
                            %                             p.cache.xs(f,t,2)= 2+2*p.tc(t)+3*p.fc(f);% sigma- scale
                            %                             p.cache.xs(f,t,3)= 0+4*p.tc(t)+ 3*p.fc(f);% mu- location
                            
                            p.cache.xs(f,t,1)= 0.1+0.4*p.fc(f); % k- shape
                            p.cache.xs(f,t,2)= 0.5+1*0*p.tc(t)+2*p.fc(f);% sigma- scale
                            p.cache.xs(f,t,3)= 0+2*p.tc(t)+ 0.3*p.fc(f);% mu- location
                        end
                    end
                otherwise
                    mode
                    error('bad mode')
            end
            %noise params and crit
            for f=1:p.numFc
                for t=1:p.numTc
                    %noise is like the no sig ind
                    p.cache.xn(f,t,:)=p.cache.xs(f,tIndNoSig,:);
                    
                    %crit is fit
                    p.crit(f,t)=p.fitCriterionFromEvdParams(p.cache.xn(f,t,:),p.cache.xs(f,t,:));
                end
            end
            %p.crit(:,:)= mean(p.crit(:));
        end
        function h=plotModelFeatures(p,tc,fc,features,weight,gutter)
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
                    subplot(h,w,(f-1)*length(tInds)+t); hold on;
                    
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
                                        yScale=height(i)/p.contrastAttentionHeight;
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
                                        plot(crit([1 1]),ylim,'k')
                                        
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
                                        plot(crit([1 1]),ylim,'k')
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
                                    xlabel('visual position')
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
                        text(xl(1)-diff(xl)*0.2,mean(ylim),sprintf('C_{f}=%2.2f',p.fc(fInds(f))),'horizontalAlignment','right')
                    end
                    if h>2 && f==1
                        yl=ylim;
                        text(mean(xlim),yl(2)+diff(yl)*0.2,sprintf('C_{t}=%2.2f',p.tc(tInds(t))),'horizontalAlignment','center')
                    end
                    
                end % for f
            end  %for t
        end % fun
        function plotROC(p,tc,fc,dataSource,arrowsOn,subjectInds)
            if ~exist('tc','var') || isempty(tc)
                tc= p.tc;
            end
            if ~exist('fc','var') || isempty(fc)
                fc= p.fc;
            end
            if ~exist('dataSource','var') || isempty(dataSource)
                dataSource='modelSamples';
            end
            if ~exist('arrowsOn','var') || isempty(arrowsOn)
                arrowsOn=true;
            end
            if ~exist('subjects','var') || isempty(subjects)
                if isfield(p.cache,'subjectData')
                    subjectInds=1:length(p.cache.subjectData);
                else
                    subjectInds=1;
                end
            end
            
            addCritLines=false;
            
            %setup
            [fInd tInd tIndNoSig]=p.getContrastIndsFromCurrentOrArg(tc,fc);
            tInd=setdiff(tInd,tIndNoSig);
            
            %map to standard format (uses non-local plotter)
            names.stats={'hits','CRs'};
            names.subjects={'model'};
            names.conditions={};
            stats=nan(1,length(fInd)*length(tInd),2);
            CI=nan(1,length(fInd)*length(tInd),2,2);
            subjects=[]; % all (model only)
            conditions=[]; % all
            arrows=[]; % none yet
            params.colors=repmat(jet(5),4,1);
            
            hold on;
            for s=subjectInds
                for t=1:length(tInd)
                    for f=1:length(fInd)
                        subCondInd=(s-1)*(length(fInd)*length(tInd))+(t-1)*length(fInd)+f;
                        
                        switch dataSource
                            case 'modelSamples'
                                numHit=sum(p.cache.dv(fInd(f),tInd(t),:)>p.crit(fInd(f),tInd(t)));
                                numFA=sum(p.cache.dv(fInd(f),tIndNoSig,:)>p.crit(fInd(f),tInd(t)));
                                [hit hitCI]=binofit(numHit,p.numIttn);
                                [fa faCI]=binofit(numFA,p.numIttn);
                                %plot(fa,hit,'ok')
                            case 'GEV'
                                xs=p.cache.xs(fInd(f),tInd(t),:); % p.cache.gev.xs?
                                xn=p.cache.xs(fInd(f),tIndNoSig,:);
                                crit=p.crit(fInd(f),tInd(t));
                                numHit=round((1-gevcdf(crit,xs(1),xs(2),xs(3)))*p.numIttn);
                                numFA =round((1-gevcdf(crit,xn(1),xn(2),xn(3)))*p.numIttn);
                                [hit hitCI]=binofit(numHit,p.numIttn);
                                [fa faCI]=binofit(numFA,p.numIttn);
                                params.colors=repmat(cool(5),4,1);
                            case 'subject'
                                
                                numHit=p.cache.raw.numHits(subCondInd);
                                numFA=p.cache.raw.numFAs(subCondInd);
                                numSigs=p.cache.raw.numMisses(subCondInd)+numHit;
                                numNoSigs=p.cache.raw.numCRs(subCondInd)+numFA;
                                [hit hitCI]=binofit(numHit,numSigs);
                                [fa faCI]=binofit(numFA,numNoSigs);
                                cc=[.8 .8 .8];
                                if t==length(tInd)
                                    cc=[.8 0 0];
                                end
                                if f==1
                                    
                                    cc=[0 0 .8];
                                end
                                
                                %  MIDDLE CROSS IDEA
                                % if t==2
                                %     cc=[0 0 .8];
                                % end
                                % if f==3
                                %     cc=[.8 0 0];
                                %end
                                
                                params.colors(subCondInd,:)=cc;
                            case 'gauss'
                                xs=p.cache.gauss.xs(fInd(f),tInd(t),:);
                                xn=p.cache.gauss.xn(fInd(f),tIndNoSig,:);
                                crit=p.cache.gauss.crit(fInd(f),tInd(t));
                                numSigs=p.cache.raw.numMisses(subCondInd)+p.cache.raw.numHits(subCondInd);
                                numNoSigs=p.cache.raw.numCRs(subCondInd)+p.cache.raw.numFAs(subCondInd);
                                numHit=round((1-normcdf(crit,xs(1),xs(2)))*numSigs);
                                numFA =round((1-normcdf(crit,xn(1),xn(2)))*numNoSigs);
                                [hit hitCI]=binofit(numHit,numSigs);
                                [fa faCI]=binofit(numFA,numNoSigs);
                                params.colors=repmat(cool(5),4,1);
                            otherwise
                                dataSource
                                error('bad source')
                        end
                        
                        
                        
                        names.conditions{end+1}=sprintf('s%d-model-%2.2g-%2.2g',s,p.tc(tInd(t)),p.fc(fInd(f)));
                        stats(1,subCondInd,1)=hit;
                        stats(1,subCondInd,2)=1-fa;
                        CI(1,subCondInd,1,:)=hitCI;
                        CI(1,subCondInd,2,:)=1-faCI;
                        
                        if addCritLines
                            error('not yet')
                            for j=1:length(critSampling)
                                hits(f,t,j)=sum(response(:,t)>critSampling(j))/samps;
                                FAs(f,t,j)=sum(response(:,1)>critSampling(j))/samps;
                                
                            end
                            plot(FAs(t,:),hits(t,:),'color',colors(i,:))
                        end
                        
                    end
                end
                
                %             plot([0 1],[0 1],'k')
                %             axis square
                %             ylabel('hit rate')
                %             xlabel('fa rate')
                
                
                % connect constant flankers with arrows
            end
            conditions=[]; % all
            c=names.conditions;
            k=2;             k=1;
            if arrowsOn
                if length(subjectInds)>1
                    error('only for one subject')
                end
                %only sensible for single subject
                arrows={c{1},c{6},k; c{6},c{11},k; c{11},c{16},k;...
                    c{2},c{7},k; c{7},c{12},k; c{12},c{17},k;...
                    c{3},c{8},k; c{8},c{13},k; c{13},c{18},k;...
                    c{4},c{9},k; c{9},c{14},k; c{14},c{19},k;...
                    c{5},c{10},k; c{10},c{15},k; c{15},c{20},k};
            else
                arrows=[];
            end
            doHitFAScatter(stats,CI,names,params,subjects,conditions,0,0,0,0,0,1,arrows);  % note bias - say yes more when close
            
        end
        function p=init(p)
            %init the current to something reasonable
            p.current.trial=0;
            p.current.tc=p.tc(end);
            p.current.fc=p.fc(end);
            p.current.targetThere=true;
            p.current.stdAttn=p.stdAttn;
            %p.current.crit=3; % not used yet
            
            %pre-allocate
            p.crit=nan(p.numFc,p.numTc);
            p.stdAttn=p.stdAttn*ones(p.numFc,p.numTc);
            p.cache.dv=nan(p.numFc,p.numTc,p.numIttn);
            p.cache.xs=nan(p.numFc,p.numTc,3);  %3 params for gev
            p.cache.xn=nan(p.numFc,p.numTc,3);
            
            %set rule specific features
            switch p.combinationRule
                case 'max'
                    p.edges=linspace(0,.5,100);
                    %p.edges=linspace(0,3,100); % want to let edges
                    %constrain crit less in fminbnd, but then 1 goes really
                    %high and drags the learning away
                case 'mean'
                    p.edges=linspace(0,.2,100);
                case 'LL'
                    p.edges=linspace(200,600,100);
                case 'sampleGEV'
                    p=p.setGevParams('test');
                    p.edges=linspace(0,10,100);
                otherwise
                    p.edges=linspace(0,1,100);
            end
        end
        function p=load(p)
            load(fullfile(p.savePath,p.modelName));
            %p=p.init;  % in case setup has changed .. .this wipes out the
            %fit crit and the cached samples!
        end
        function save(p)
            save(fullfile(p.savePath,p.modelName),'p');
        end
        function p=setViewPlots(p,mode)
            plots={'critEvdFit','performancePerCondition'};
            %start with all false; selectively turn on
            for i=1:length(plots)
                p.viewPlot.(plots{i})=false;
            end
            switch mode
                case 'allOn'
                    for i=1:length(plots)
                        p.viewPlot.(plots{i})=true;
                    end
                case 'dynamicTesting'
                    p.viewPlot.performancePerCondition=true;
                case 'none'
                    %do nothing
                otherwise
                    error('bad mode')
            end
        end
        function ce=getContrastEnvelope(p)%,targetThere) %3 gaussian lumps
            %             if ~exist('targetThere','var') || isempty(targetThere)
            %                 targetThere=p.current.targetThere
            %             end
            % not sure why this does not work, but i don't need it
            targetThere=1;
            loc=p.loc; % smidgen faster to do it once ont 3 times
            ce=p.current.tc*targetThere*p.gauss(loc,0,p.stdT)+...
                p.current.fc*p.gauss(loc,-p.d,p.stdF)+...
                p.current.fc*p.gauss(loc,p.d,p.stdF);
            ce=ce+p.baseline;
        end
        function h=get.contrastHeight(p)
            h=p.gauss(0,0,p.stdT)+p.baseline;
        end
        function h=get.contrastAttentionHeight(p)
            %the highest you could get for full contrast at the center of attn
            if ~isinf(p.current.stdAttn)
                h=p.contrastHeight*p.gauss(0,0,p.current.stdAttn);
            else
                h=p.contrastHeight^2/3;
            end
        end
        function lr=getCritLearningRate(p,x)
            switch p.critLearningRate
                case 'zero'
                    lr=0;
                case 'one'
                    lr=1;
                case 'fit'
                    %lr=(erf(x(1))+1)/2; % 0 to 1, smooth
                    lr=x(1); %any
            end
            
            %OLDER WEIGHTING METHODS (replaced by fraction learned)
            %has the nice property of always scaling to be a fraction
            %qualityOfFitToThisDistribution=x(1);
            %w=[qualityOfFitToThisDistribution 1]; % the relative weight of this optimal, vs the global anchorCriteria
            %critUsed=(adjustedCrit*w(1)+anchorCriteria*w(2))/sum(w); %
            %weighted average
        end
        function ae=getAttentionEnvelope(p,forceEyePos)
            if ~exist('forceEyePos','var') || isempty(forceEyePos)
                mn=randn*p.stdEye; % random eye position
            else
                mn=forceEyePos; %*p.stdEye;
            end
            if ~isinf(p.current.stdAttn)
                ae=p.gauss(p.loc,mn,p.current.stdAttn);
            else
                ae=ones(1,p.numNodes)*p.contrastHeight/3;
            end
        end
        function k=get.offsetMatrix(p)
            offsets=p.loc;
            k=nan(p.numOffsets,length(p.loc));
            for i=1:length(offsets)
                k(i,:)=p.getAttentionEnvelope(offsets(i)).*p.getContrastEnvelope;
                %this is one way of shifting the response, but it might not
                %be the best...think about the relative position of attn &
                %contrast as well as the absolute.
            end
        end
        function n=get.numOffsets(p)
            n=p.numNodes;  % currentlycheck all positions per node (simple 1:1 mapping)
            %if changed address offsetMatix
        end
        function r=nodeResponse(p,forceEyePos)
            if ~exist('forceEyePos','var')
                forceEyePos=[];
            end
            e=p.getAttentionEnvelope(forceEyePos).*p.getContrastEnvelope;
            switch p.nodeDistribution
                case 'gauss'
                    r=e.*randn(1,p.numNodes);
                case 'absGauss'
                    r=e.*abs(randn(1,p.numNodes));
                case 'absGGD'
                    error('not yet')
            end
        end
        function [R locEst]=decisionVariable(p)
            locEst=nan; %unless its estimated
            switch p.combinationRule
                case 'max'
                    R=max(p.nodeResponse);
                case 'sum'
                    R=sum(p.nodeResponse);
                case 'mean'
                    R=mean(p.nodeResponse);
                case 'LL'
                    k=p.current.offsetMatrix; %(precached for speed during runSimuluation) the waveform of signal and attn shifted across space for the spatial uncertainty
                    LLmat=(-1/2)*(repmat(p.nodeResponse,p.numOffsets,1)./k).^2-log(k);  % log of the probability that a scaled gaussian generated the responses
                    LLpos=sum(LLmat,2); % for all offset positions
                    R=max(LLpos);      %  R==the log likelihood of the best position
                    locEst=p.loc(find(LLpos==R));% the most likely center if the signal is the current contrast
                case 'sampleGEV'
                    %rather than run a simulation, to fit params to it
                    %this just samples from a particular parameter set
                    tInd=find(p.current.tc==p.tc);
                    fInd=find(p.current.fc==p.fc);
                    xs=p.cache.xs(fInd,tInd,:);
                    R=gevrnd(xs(1),xs(2),xs(3));
            end
        end
        function g=gauss(p,x,mn,std)
            k=(sqrt(2*pi*std.^2)).^(-1);
            g=k.*exp( -((x-mn).^2)./(2*std^2) );
        end
        function loc=get.loc(p)
            hw=(p.numNodes/p.nodesPerSpaceUnit)/2;
            loc=linspace(-hw,hw,p.numNodes);
        end
        function numFc= get.numFc(p)
            numFc=length(p.fc);
        end
        function numTc =get.numTc(p)
            numTc=length(p.tc);
        end
        function p=runSimulation(p,tc,fc)
            %p=runSimulation(p,[tc],[fc])
            if ~exist('tc','var') || isempty(tc)
                tcRequested=p.tc;
            else
                tcRequested=tc;
            end
            if ~exist('fc','var') || isempty(fc)
                fcRequested=p.fc;
            else
                fcRequested=fc;
            end
            
            fprintf('\n%d samples per condition, %d conditions being run (of %d total)',p.numIttn,length(fcRequested)*length(tcRequested),p.numFc*p.numTc)
            count=0; %just for tracing progress output to user
            for f=1:p.numFc
                for t=1:p.numTc
                    if ismember(p.fc(f),fcRequested) && ismember(p.tc(t),tcRequested)
                        p.current.fc=p.fc(f);
                        p.current.tc=p.tc(t);
                        if strcmp(p.combinationRule,'LL')
                            p.current.offsetMatrix=p.offsetMatrix; % this is pre-cached purely for compute speed
                        end
                        
                        count=count+1; fprintf('%d.',count);
                        R=nan(1,p.numIttn);
                        locEst=nan(1,p.numIttn);
                        for i=1:p.numIttn
                            [R(i) locEst(i)]=decisionVariable(p);
                        end
                        p.cache.dv(f,t,:)=R;
                        p.cache.locEst(f,t,:)=locEst;
                    end
                end
            end
        end
        function [fInd tInd tIndNoSig]=getContrastIndsFromCurrentOrArg(p,tc,fc)
            if ~exist('tc','var') || isempty(tc)
                tc= p.current.tc;
            end
            if ~exist('fc','var') || isempty(fc)
                fc= p.current.fc;
            end
            fInd=find(fc==p.fc);
            tInd=find(tc==p.tc);
            tIndNoSig=find(0==p.tc);
            if any([isempty(fInd) isempty(tInd) isempty(tIndNoSig)])
                fInd
                tInd
                tIndNoSig
                error('missing an ind')
            end
        end
        function [p crit er]=fitCriteria(p)
            [fInd tInd tIndNoSig]=p.getContrastIndsFromCurrentOrArg();
            
            for f=1:length(fInd)
                for t=1:length(tInd)
                    switch p.optimalCritMethod
                        case 'gauss.xn'
                            error('not yet.. still in fitGaussianSDT')
                            p.cache.gauss.crit(fInd(f),tInd(t))=crit;
                        case {'fitGev'}
                            noise=permute(p.cache.dv(fInd(f),tIndNoSig,:),[3 2 1]);
                            signal=permute(p.cache.dv(fInd(f),tInd(t),:),[3 2 1]);
                            [xn cin]=gevfit(noise);  % gevfit(p.current.noise)
                            [xs cis]=gevfit(signal);       % gevfit(p.current.signal)
                            %store some values in cache for each condition
                            p.cache.xn(fInd(f),tInd(t),1:3)=xn;
                            p.cache.xs(fInd(f),tInd(t),1:3)=xs;
                            
                            if p.viewPlot.critEvdFit
                                close all
                                figure;
                                subplot(3,1,1); n=histc(noise,p.edges); yn=gevpdf(p.edges,xn(1),xn(2),xn(3));
                                bar(p.edges,n/p.numIttn,'histc'); hold on
                                plot(p.edges,yn/sum(yn(:)),'r'); title('noise'); set(gca,'xlim',minmax(p.edges))
                                subplot(3,1,2); n=histc(signal,p.edges); ys=gevpdf(p.edges,xs(1),xs(2),xs(3));
                                bar(p.edges,n/p.numIttn,'histc'); hold on
                                plot(p.edges,ys/sum(ys(:)),'g'); title('signal'); set(gca,'xlim',minmax(p.edges))
                                subplot(3,1,3); hold on;
                                plot(p.edges,yn,'r');
                                plot(p.edges,ys,'g');
                                
                                plot(xn([3 3]),ylim,'r')
                                plot(xs([3 3]),ylim,'g')
                                %cleanUpFigure
                                drawnow
                                
                                %p.plotModelFeatures(p.tc(tInd(t)),p.fc(fInd(f)),'sig&Noise')
                            end
                            
                            [crit er]=p.fitCriterionFromEvdParams(xn,xs);
                            
                            if p.viewPlot.critEvdFit
                                plot(crit([1 1]),ylim,'k')
                            end
                            
                            p.cache.erLastCritSearch(fInd(f),tInd(t))=er;
                            %p.current.crit=crit;  %store in current for active seaching process (do i need this?)
                            p.cache.gev.crit(fInd(f),tInd(t))=crit;
                        case 'fitGevWithAlphaLearning'
                            error('this mode is not supported... find a way to call getRatesAndCriteria')
                        case 'raw'
                            error('not yet ... copy from other code')
                        otherwise
                            p.optimalCritMethod
                            error('bad')
                    end
                    p.crit(fInd(f),tInd(t))=crit;
                end
            end
            
            
            %THIS DOES TO ADJUST FOR ALPHA IS NOT NEEDED... ITS GOT PUSHED
            %TO THE COMMMON LOCATION OF GET CRITERIA AND RATES, SHARED WITH
            %OTHER MODELS
            %             switch p.optimalCritMethod
            %                 case {'fitGevWithAlphaLearning'} %fitGaussWithAlphaLearning
            %                     crits=p.cache.gev.crit(:,2:end); % don't include the noise with self "crit"
            %                     anchorCriteria=mean(crits(:));
            %                     fractionLearned=getCritLearningRate(p,p.current.learningAlpha); %hard code here for right now [0 1 or fit=0.5]
            %                     p.crit(:,2:end)=crits*fractionLearned+anchorCriteria*(1-fractionLearned);
            %
            %                     for f=1:length(fInd)
            %                         for t=1:length(tInd)
            %
            %                             %this is not needed, but nice to keep in sync
            %                             %(could axe if slow)
            %                             xn=p.cache.xn(fInd(f),tInd(t),1:3);
            %                             xs=p.cache.xs(fInd(f),tInd(t),1:3);
            %                             p.cache.erLastCritSearch(fInd(f),tInd(t))=evdErrorFun(p,p.crit(fInd(f),tInd(t)),xn,xs,p.relativeMissCost);
            %
            %                             %p.current.crit=crit;  %store in current for active seaching process (do i need this?)
            %                             %p.cache.gev.crit(fInd(f),tInd(t))=critUsed;
            %
            %                         end
            %                     end
            %                 otherwise
            %                     %dont modify with alpha
            %             end
            
        end
        function [crit er]=fitCriterionFromEvdParams(p,xn,xs)
            c0=0;
            %[crit er]=fminsearch(@(c)
            %evdErrorFun(p,c,xn,xs,p.relativeMissCost),c0); sometimes way left of the whole distibution
            %[crit er]=fminbnd(@(c)evdErrorFun(p,c,xn,xs,p.relativeMissCost),min(p.edges),max(p.edges));
            
            %find the best crit between the modes, assuming signal is higher
            [crit er flag]=fminbnd(@(c) evdErrorFun(p,c,xn,xs,p.relativeMissCost),xn(3),xs(3));
            if flag~=1
                prevCrit=crit
                pervFlag=flag
                warning('prev fit bad, going to try whole range of edges')
                [crit er flag]=fminbnd(@(c)evdErrorFun(p,c,xn,xs,p.relativeMissCost),min(p.edges),max(p.edges));
            end
            if flag~=1
                p.current
                warning('bad fit..why?')
                keyboard
            end
        end
        function [crit er]=fitCriterionFromGaussParams(p,xn,xs)
            %find the best crit between the means, assuming signal is higher
            
            LB=min(xn(1)-4*xn(2),xs(1)-4*xs(2));
            UB=max(xn(1)+4*xn(2),xs(1)+4*xs(2));
            [crit er flag]=fminbnd(@(c) gaussSTDErrorFun(p,c,xn,xs,p.relativeMissCost),LB,UB);
            %             if flag~=1
            %                 prevCrit=crit
            %                 pervFlag=flag
            %                 warning('prev fit bad, going to try whole range of edges')
            %                 [crit er flag]=fminbnd(@(c)evdErrorFun(p,c,xn,xs,p.relativeMissCost),min(p.edges),max(p.edges));
            %could switch the bounary around in case noise is somehow lower
            %(possible with variance being fit)
            %                 [crit er flag]=fminbnd(@(c)evdErrorFun(p,c,xn,xs,p.relativeMissCost),xs(1)-eps,xn(1)+eps);
            %             end
            if flag~=1
                p.current
                warning('bad fit..why?')
                keyboard
            end
        end
        function er=evdErrorFun(p,crit,xn,xs,relativeMissCost)
            er=(1-gevcdf(crit,xn(1),xn(2),xn(3)))+gevcdf(crit,xs(1),xs(2),xs(3))*relativeMissCost;
            er=er/2;
        end
        function er=gaussSTDErrorFun(p,crit,xn,xs,relativeMissCost)
            try
                er=(1-normcdf(crit,xn(1),xn(2)))+normcdf(crit,xs(1),xs(2))*relativeMissCost;
                er=er/2;
            catch
                warning('here')
                keyboard
            end
        end
        function p=fitSubjectDataWithSimulation(p)
            [data params]=p.getDataFromSubjectCache;
            if any(unique([0 params.tcs])~=p.tc) || any(unique(params.fcs)~=p.fc)
                unique([0 params.tcs])
                unique(params.fcs)
                p.tc
                p.fc
                error('may have issues with relating model to the subject data becuase different contrast values')
            end
            
            
            % x(1) is alpha: leaned fraction of crit
            % length(x) must stay below 8 params, or else we run into some of the
            % multi rat fitting param, hard coded (param 8-13)
            
            
            %hyper-paramters for drawing the initial seed x0 semi randomly
            x0mean=[.5 .35 6 2];
            x0var=[.2 .2 2 1];
            lb=[0 0 2 .8];
            
            numRuns=50;
            p.cache.x0=[];
            p.cache.modelHistory=[];
            p.cache.errorHistory=[];
            for n=1:numRuns
                optim=optimset('MaxIter',50);
                x0=x0mean+randn(1,4).*[x0var];
                x0(x0<lb)=lb(x0<lb);
                p.cache.x0(end+1,:)=x0; % save the start location
                [x er]=fminsearch(@(x)simulationMLErrorFun(p,x,data,params),x0,optim);
                p.cache.modelParams=x;
                p.cache.modelHistory(end+1,:)=x;
                p.cache.errorHistory(end+1)=er;
                p.save
            end
        end
        function er=simulationMLErrorFun(p,x,data,params)
            
            alpha=x(1);  % this is not USED but FIT AGAIN inside this function
            if length(x)>=2
                p.baseline=x(2);
            end
            if length(x)>=3
                p.nodesPerSpaceUnit=x(3);  % could be mm; can mean units target width when stdT=1
            end
            if length(x)>=4
                p.stdEye=x(4);
            end
            %p.relativeMissCost=1;
            %rfStd (a conv on the contrast)
            %stdAttn=Inf; %global for all contrast conditions, can be
            %overwritten using doStdAttnFit
            
            tic
            p=p.runSimulation();
            toc
            p.current.tc=p.tc; % do all available for crit fits later on
            p.current.fc=p.fc;
            p=fitCriteria(p); % also fits the xn and xs, se we can just use the params
            toc
            [hit fa miss cr adjustedCrit critUsed params]=p.getRatesAndCriteria(x,params.tcs,params.fcs,params);
            params.modelLL=p.logLiklihood(data,hit,fa,miss,cr);
            %er=-2*params.modelLL;
            
            [alpha er]=p.fitLearningRateToSubjectDataGivenSimulationResults(data,params);
            %%save the best as you go...
            %p.cache.modelParams=[alpha  x(2:end)];
            %p.save
            
            
            doPlot=rand<0.05;
            doPlot=0;
            if doPlot
                includeSubjectData=true;
                p.viewOnGoingFit(hit,miss,fa,cr,data,x,params,[1 2],includeSubjectData);
                
                figure(3);
                for i=1:params.numTc*params.numFc;
                    subplot(params.numTc,params.numFc,i); hold off
                    loc=linspace(.2,.5,100);
                    %plot(loc,normpdf(loc,params.muS(i),params.sigmaS(i)),'g'); hold on
                    %plot(loc,normpdf(loc,params.muN(i),params.sigmaN(i)),'
                    %r')
                    plot(loc,gevpdf(loc,params.shapeS(i),params.sigmaS(i),params.muS(i)),'g'); hold on
                    plot(loc,gevpdf(loc,params.shapeN(i),params.sigmaN(i),params.muN(i)),'r')
                    
                    set(gca,'xtick',[],'ytick',[],'ylim',[0  12],'xlim',[.2  .5])
                    plot(params.anchorCriteria([1 1]),ylim,'m')
                    plot(critUsed([i i]),ylim,'k')
                    plot(adjustedCrit([i i]),ylim,'r--')
                    xlabel(sprintf('tc:%2.2f fc:%2.2f',params.tcs(i),params.fcs(i)) )
                    
                end
                set(gcf,'position',[800 100 750 750])
                drawnow
            end
            toc
        end
        function [alpha er]=fitLearningRateToSubjectDataGivenSimulationResults(p,data,params)
            if ~exist('data','var') || isempty(data)
                [data params]=p.getDataFromSubjectCache;
            end
            
            if ~strcmp(p.critLearningRate,'fit')
                error('must be in fit mode to work... other wise wasting your time cuz its locked to 0 or 1')
            end
            switch p.optimalCritMethod
                case 'noGaussYet'
                    p.sdtDistributionType='gaussian';
                case 'fitGev'
                    p.sdtDistributionType='gev';
                otherwise
                    p.optimalCritMethod
            end
            
            
            %THIS IS DONE ONCE OUTSIDE
            %tic
            %sprintf('getting parameter fits from model (xn, xs: all conditions)')
            %p.current.tc=p.tc; % do all available
            %p.current.fc=p.fc;
            %p=fitCriteria(p); % also fits the xn and xs, se we can just use the params
            %fprintf('took %2.2f sec',toc)
            
            p.parameterSource='simulationFitResults'; % we won't actually combine the signals, we chose use the parametric fits of the exact same contrasts as we ran in the sim
            
            alpha0=0.5; %start at 0.5
            [alpha er]=fminsearch(@(alpha)learningRateMLErrorFun(p,alpha,data,params),alpha0);
        end
        function er=learningRateMLErrorFun(p,alpha,data,params)
            %p.current.learningAlpha=alpha; not needed anymore
            x=alpha; %this is the only param we are fitting and the only one we really need
            [hit fa miss cr adjustedCrit critUsed params]=p.getRatesAndCriteria(x,params.tcs,params.fcs,params);
            
            %the liklihood
            params.modelLL=p.logLiklihood(data,hit,fa,miss,cr);
            er=-2*params.modelLL;
            
            toc
            doPlot=rand<0.05;
            doPlot=0;
            if doPlot
                includeSubjectData=true;
                p.viewOnGoingFit(hit,miss,fa,cr,data,x,params,[4],includeSubjectData);
                
                %                 figure(3);
                %                 for i=1:params.numTc*params.numFc;
                %                     subplot(params.numTc,params.numFc,i); hold off
                %                     loc=linspace(.2,.5,100);
                %                     %plot(loc,normpdf(loc,params.muS(i),params.sigmaS(i)),'g'); hold on
                %                     %plot(loc,normpdf(loc,params.muN(i),params.sigmaN(i)),'
                %                     %r')
                %                     plot(loc,gevpdf(loc,params.shapeS(i),params.sigmaS(i),params.muS(i)),'g'); hold on
                %                     plot(loc,gevpdf(loc,params.shapeN(i),params.sigmaN(i),params.muN(i)),'r')
                %
                %                     set(gca,'xtick',[],'ytick',[],'ylim',[0  12],'xlim',[.2  .5])
                %                     plot(params.anchorCriteria([1 1]),ylim,'m')
                %                     plot(critUsed([i i]),ylim,'k')
                %                     plot(adjustedCrit([i i]),ylim,'r--')
                %                     xlabel(sprintf('tc:%2.2f fc:%2.2f',params.tcs(i),params.fcs(i)) )
                %
                %                 end
                %                 set(gcf,'position',[800 100 750 750])
                drawnow
                
            end
        end
        function p=fitAllStdAttn(p)
            
            count=0; %just for tracing progress output to user
            for f=1:p.numFc
                for t=1:p.numTc
                    p.current.fc=p.fc(f);
                    p.current.tc=p.tc(t);
                    count=count+1;  fprintf('\nfitting stdAttn for %d of %d conditions',count, p.numFc*p.numTc)
                    [p.stdAttn(f,t) er]=fitStdAttn(p);
                    p.cache.erLastStdAttnSearch(f,t)=er;
                    [p crit er]=fitCriteria(p)
                end
            end
            
            p.save();
            
            if p.viewPlot.performancePerCondition %(post stdAttnFit)
                keyboard
                figure
                performance=1-p.cache.erLastCritSearch;
                imagesc(log(1-performance)); colormap(gray)
                xlabel('target contrast')
                ylabel('flanker contrast')
                set(gca,'xTick',1:p.numTc,'xTickLabel',p.tc)  % is this upside down? does it need fliplr on xtick?
                set(gca,'yTick',1:p.numFc,'yTickLabel',p.fc)  % is this upside down? does it need fliplr on xtick?
                cleanUpFigure
            end
        end
        function [stdAttn er]=fitStdAttn(p)
            %[stdAttn er]=fminsearch(@(x) stdAttnErrorFun(p,x),p.current.stdAttn);
            [stdAttn er flag]=fminbnd(@(x) stdAttnErrorFun(p,x),p.attnBound(1),p.attnBound(2));
            if flag~=1
                warning('bad fit..why?')
                keyboard
            end
        end
        function er=stdAttnErrorFun(p,thisStdAttn)
            p.current.stdAttn=thisStdAttn;
            p=p.runSimulation([p.current.tc 0],p.current.fc); %run this on only the current tc & fc, plus corresponding noise distribution
            [p critJunk er]=p.fitCriteria(); % this only uses the current...
            
        end
        function out=isGEV(p)
            out=any(ismember(p.modelFeatures,{'tk','fk','kappa'}));
        end
        function out=hasBiasFeature(p)
            out=any(ismember(p.modelFeatures,{'bias'}));
        end
        
        function out=hasGuessing(p)
            out=any(ismember(p.modelFeatures,{'guess1','guess2','yes|guess1','yes|guess2'}));
        end
        function doBatch(p)
            params={'stdEye',[3]};
            for i=1:size(params,1)
                for j=1:length(params{i,2})
                    p=p.set.(params{i,1})(params{i,2}(j));
                    if p.doStdAttnFit
                        p=p.fitStdAttn();
                    end
                    p=p.runSimulation();
                    
                    
                    %store and save
                    p.cache.batchData{end+1}.xn=p.cache.xn;
                    p.cache.batchData{end+1}.xs=p.cache.xs;
                    p.cache.batchData{end+1}.crit=p.crit;
                    p.cache.batchData{end+1}.stdAttn=p.stdAttn;
                    p.save;
                end
            end
        end
        function h=plotCurve(p,x,y,color,mode,yOffset,yScale,cropEdgesBelowThresh)
            %h=plotCurve(x,y,[0.8 0 0],'fill',yOffset,yScale,0.001)
            if ~exist('color','var') || isempty(color)
                color=[.8 .8 .8];
            end
            if ~exist('mode','var') || isempty(mode)
                mode='fill'; %line, bar
            end
            if ~exist('yOffset','var') || isempty(yOffset)
                yOffset=0;
            end
            if ~exist('yScale','var') || isempty(yScale)
                yScale=1;
            end
            if ~exist('cropEdgesBelowThresh','var') || isempty(cropEdgesBelowThresh)
                cropEdgesBelowThresh=0;
            end
            % remove really low values at the edges
            relevant=find(y>cropEdgesBelowThresh);
            relevantCenter=[min(relevant):max(relevant)];
            if isempty(relevantCenter)
                return
            end
            x=x(relevantCenter);
            y=y(relevantCenter);
            % do the plot
            switch mode
                case 'fill'
                    h=fill([x(1) x x(end)],(yScale*[0 y 0])+yOffset,color,'EdgeAlpha',0);%,'FaceColor',color);
                case 'line'
                    h=plot(x,(yScale*y)+yOffset,'lineWidth',2,'color',color);
                case 'verticalLines'
                    h=plot([x; x], [(yScale*y)+yOffset; yOffset*ones(1,length(y))],'lineWidth',2,'color',color);
                otherwise
                    mode
                    error('bad')
            end
        end
        function im=getStimImage(p)
            s=ifFeatureGoRightWithTwoFlank('basic');
            [param]=getDefaultParameters(s);
            param.flankerOffset=3;
            param.flankerContrast=0.5;
            param.stdGaussMask=1/16;
            param.pixPerCycs=32;
            param.phase=0;
            [ts]=setFlankerStimRewardAndTrialManager(param);
            im=sampleStimFrame(ts);
            imagesc(im); colormap(gray);
            cleanUpFigure
            set(gca,'xtick',[],'ytick',[])
        end
        function p=loadDataFromServer(p,subjects);
            
            %subjects={'234','231'} % all colin, many target contrasts on 12, or many flanker onctrasts on 15, or joint contrast on colinear on 16
            %conditionType='allBlockIDs';
            %filter{1}.type='16';
            %d=getSmalls(subject,dateRange);
            %d=addYesResponse(d);
            %d=removeSomeSmalls(d,isnan(d.blockID));
            %[x.stats x.CI x.names x.params]=getFlankerStats({subject},conditionType,{'hits','CRs','yes','pctCorrect'},filter,dateRange);
            if ~iscell(subjects)
                error('must be a cell')
            end
            dateRange= [pmmEvent('231&234-jointSweep')+1 pmmEvent('231-test200msecDelay')];
            raw.subjectID=[];
            for i=1:length(subjects)
                [x.stats x.CI x.names x.params]=getFlankerStats(subjects(i),'allBlockIDs',{'hits','CRs'},'16',dateRange);
                
                %THE CACHE IS ORGANIZED PER SUBJECT
                p.cache.subjectData(i)=x;
                
                %the raw fields are flat for ALL SUBJECTS
                raw=p.combineStructs(raw,x.params.raw);
                raw.subjectID=[raw.subjectID repmat(str2double(x.names.subjects{1}),1,length(x.params.raw.numCorrect))];
            end
            p.cache.raw=raw;
        end
        function s1=combineStructs(p,s1,s2)
            f=fields(s2);
            for j=1:length(f)
                if ~isfield(s1,f{j})
                    s1.(f{j})=[]; %init empty first time around
                end
                s1.(f{j}) =[s1.(f{j}) s2.(f{j})];
            end
        end
        function  [data params]=getDataFromSubjectCache(p)
            data=p.cache.raw;
            %data(i)=p.cache.subjectData(i).params.raw)
            
            
            data.numSig=data.numHits+data.numMisses;
            data.numNoSig=data.numFAs+data.numCRs;
            data.hit=data.numHits./(data.numHits+data.numMisses);
            data.miss=data.numMisses./(data.numHits+data.numMisses);
            data.fa=data.numFAs./(data.numFAs+data.numCRs);
            data.cr=data.numCRs./(data.numFAs+data.numCRs);
            
            %pre-compute params for speed and orderliness
            params.tcs=[]; params.fcs=[];
            params.subjectID=data.subjectID;
            for i=1:length(p.cache.subjectData)
                params.tcs=[params.tcs  p.cache.subjectData(i).params.factors.targetContrast];
                params.fcs=[params.fcs  p.cache.subjectData(i).params.factors.flankerContrast];
            end
            params.dataLL=p.logLiklihood(data,data.hit,data.fa,data.miss,data.cr);
            params.numTc=length(unique(params.tcs));
            params.numFc=length(unique(params.fcs));
        end
        function  [hit fa miss cr] = adjustForGuessingAndBias(p,x,params,hit,fa,miss,cr);
            
            if p.isGEV
                error('never tested')
                % why can't we do this with GEV... we prob could is just never been
                % tested, though some previous comments make is seem like there might
                % be problems, could have been parameter organization now solved.
            end
            
            if p.hasGuessing
                %in current code this must be both rats, a guessing term for each
                sIDs=unique(params.subjectID);
                if length(sIDs)~=2
                    error('code only written for 2 rats at most')
                    %^'notably this is all about the indexing of the
                    %parameters..if ever expanding, consider a way of
                    %dynamically naming value pairs of the parameters, so
                    %that the right names get picked and used out of the
                    %list 'y1' for yes guessing of rat 3  or 'g2' for
                    %global guessing of rat 2
                end
                for i=1:length(sIDs)
                    which=params.subjectID==sIDs(i);
                    
                    
                    %adjust for guessing - this could be updated to reflect
                    %new feature names
                    %
                    %guessID=find(strcmp(p.modelFeatures,['guess' num2str(i)]))
                    
                    pGuess=x(7+i); % 8th and 9th param, per 2 subjects
                    pYesGivenGuess=x(9+i); % 10th and 11th param, per 2 subjects
                    pGuess=1/(1+exp(pGuess));  % sigmoid to bound
                    pYesGivenGuess=1/(1+exp(pYesGivenGuess));  % sigmoid to bound
                    
                    %yes
                    hit(which)=(1-pGuess)*(hit(which))+pGuess*(pYesGivenGuess);
                    fa(which)=(1-pGuess)*(fa(which))+pGuess*(pYesGivenGuess);
                    %no
                    if nargout==3
                        error('only hit and fa, or all 4, not 3');
                    end
                    if nargout==4
                        miss(which)=(1-pGuess)*(miss(which))+pGuess*(1-pYesGivenGuess);
                        cr(which)=(1-pGuess)*(cr(which))+pGuess*(1-pYesGivenGuess);
                        %check that things are normal
                        if ~(all(1-(miss+hit)<10^-10) && all(1-(cr+fa)<10^-10))
                            error('something wrong.. hits and miss should sum to 1')
                        end
                    end
                end %for
            end %if
        end % function
    end % methods
end % classdef