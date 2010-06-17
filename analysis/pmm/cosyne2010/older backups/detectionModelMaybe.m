classdef detectionModel
    properties
        
        %contrasts used
        tc=[0 0.25 0.5 0.75 1];
        fc=[0 0.25 0.5 0.75 1];
        
        %generative model params
        numIttn=2000;
        numNodes=150;
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
        combinationRule='sampleGEV' %mean, sum, max, LL, sampleGEV
        optimalCritMethod='fitEvd'; %raw, fitEvd
        
        %model fitting params
        sdtDistributionType='gaussian';  %gaussian, eqVarGaussian, %gev
        critLearningRate='fit';  %'zero','one','fit' ;fit uses erf 0-->1
        signalCombination = 'linearIndependant';
        
        %contrastFunction='bothLinear'; %'bothPower', 'independantPower'
        mcmcModel='noneWorkingNow.txt'; %'GEV-linearTFcontrast.txt'
        
        %infrastructure
        savePath='C:\Documents and Settings\rlab\Desktop\detectionModels'
        modelName='startSimTesting' %% LL, fixedEye, fitAttnfixedEye
        
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
            p.testBed();%do first thing automatically
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
            
            %%
            %p=p.loadDataFromServer;
            %p=p.fitSubjectDataWithSDT
            %p.save;
            
            %p=p.load;
            %p.viewModel
            
            %% do both rats at jointly
            p=p.load;
            p=p.fitSubjectDataWithSDT
            
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
        function p=fitSubjectDataWithSDT(p)
            [data params]=p.getDataFromSubjectCache;
            
            if any(unique([0 params.tcs])~=p.tc) || any(unique(params.fcs)~=p.fc)
                unique([0 params.tcs])
                unique(params.fcs)
                p.tc
                p.fc
                error('may have issues with relating model to the subject data becuase different contrast values')
            end
            
            tic
            switch p.sdtDistributionType  % maybe the model name sets the other params?
                case 'eqVarGaussian'
                    x0=[.7 1.4 2.4];  % good for learning
                    [x er]=fminsearch(@(x)gaussLinearSimpleMLErrorFun(p,x,data,params),x0); %get trapped with
                case 'gaussian'
                    x0= [0  1 .1 -0.2 0 ];  % when no learning
                    x0= [.7 2 4 -0.2 1.6 ];  % good for learning'
                    
                    x0= [.81 1.96 5.67 -0.35 3.17 0.99 2.36];  % good for learning..include gamma
                    
                    x0= [.81 1.96 5.67 -0.35 3.17 0.99 2.36 3 3 3 3 1 1];  % 2 rat model
                    [x er]=fminsearch(@(x)gaussLinearSimpleMLErrorFun(p,x,data,params),x0); %get trapped with
                    %lb=[-100  -100 -100 -100 -100];
                    %ub=[100  100  100  100  100];
                    %[x er]=fminbnd(@(x)gaussMLErrorFun(p,x,data,params),lb,ub);
                    %%sometimes way left of the whole distibution
                    p=p.setGaussDistParamsFromModelFit(x);
                case 'gev'
                    x0=[.5 2.7 38 0.6 2 .6 .2]
                    %x0=[.5 2.7 38 0.6 2 0.01 0.01 -0.3] plus kappa0
                    [x er]=fminsearch(@(x)gevLinearSimpleMLErrorFun(p,x,data,params),x0); %get trapped with
                    warning('here')
                    keyboard
                    p=p.setDistParamsFromModelFit(x);
            end
            
            if flag~=1
                p.current
                warning('bad fit..why?')
                keyboard
            end
            
            figure;
            p.viewModel
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
        function [muS muN sigmaS sigmaN shapeS shapeN]=getLinearMuSigma(p,x,tcs,fcs);
            
            %default if not defined
            shapeS=[];
            shapeN=[];
            switch p.sdtDistributionType
                case 'eqVarGaussian'
                    tm=x(2); fm=x(3);
                    muS=tcs*tm+fcs*fm;
                    muN=fcs*fm;
                    sigmaS=ones(1,length(tcs));
                    sigmaN=ones(1,length(tcs));
                case 'gaussian'
                    tm=x(2); fm=x(3); ts=x(4); fs=x(5);
                    if length(x)==6
                        %same contrast exponent
                        gammaT=x(6);
                        gammaF=x(6);
                    elseif length(x)>6
                        %independant exponent
                        gammaT=x(6);
                        gammaF=x(7);
                    else
                        %linear
                        gammaT=1;
                        gammaF=1;
                    end
                    
                    muS=tcs.^gammaT*tm+fcs.^gammaF*fm;
                    muN=fcs.^gammaF*fm;
                    sigmaS=max(1+tcs.^gammaT*ts+fcs.^gammaF*fs,0.001);
                    sigmaN=max(1+fcs.^gammaF*fs,0.001);
                case 'gev'
                    tm=x(2); fm=x(3); ts=x(4); fs=x(5);
                    %shape is bounded between -1 and 1
                    tk=x(6);
                    fk=x(7);
                    %k=x(8);
                    
                    muS=tcs*tm+fcs*fm;
                    muN=fcs*fm;
                    sigmaS=max(1+tcs*ts+fcs*fs,0.001);
                    sigmaN=max(1+fcs*fs,0.001);
                    shapeS=tcs*tk+fcs*fk;
                    shapeN=fcs*fk;
                otherwise
                    error('bad')
            end
        end
        function [muS muN sigmaS sigmaN shapeS shapeN]=getNonLinearMuSigma(p,x,tcs,fcs);
            %default if not defined
            shapeS=[];
            shapeN=[];
            switch p.sdtDistributionType
                case 'gaussian'
                    tm=x(2); fm=x(3); ts=x(4); fs=x(5);
                    if length(x)==6
                        %same contrast exponent
                        gammaT=x(6);
                        gammaF=x(6);
                    elseif length(x)>6
                        %independant exponent
                        gammaT=x(6);
                        gammaF=x(7);
                    else
                        %linear
                        gammaT=1;
                        gammaF=1;
                    end
                    
                    %effective flanker and target contrast,
                    %first gamma'd,
                    %then normalized by local contrast
                    fallOff=1; %1= no falloff, normalize to full screen, not locally
                    tce=tcs.^gammaT./(2*fallOff*fcs.^gammaF + tcs.^gammaT);
                    fce=fcs.^gammaF./(fcs.^gammaF + fallOff*tcs.^gammaT); % ignoring the effect of the other flanker
                    
                    muS=tce*tm+fce*fm;
                    muN=fce*fm;
                    sigmaS=max(1+tce*ts+fce*fs,0.001);
                    sigmaN=max(1+fce*fs,0.001);
                otherwise
                    p.sdtDistributionType
                    error('never defined other sdtDistributionType for non gaussian')
            end
        end
        function [hit fa miss cr adjustedCrit critUsed params]=getRatesAndCriteria(p,x,tcs,fcs,params,anchorCriteria)
            
            %the model parameter relationships
            switch p.signalCombination
                case 'linearIndependant'
                    [muS,muN,sigmaS,sigmaN,shapeS,shapeN]=getLinearMuSigma(p,x,tcs,fcs);
                case 'divisiveNormalization'
                    [muS,muN,sigmaS,sigmaN,shapeS,shapeN]=getNonLinearMuSigma(p,x,tcs,fcs);
            end
            
            adjustedCrit=nan(1,length(muS));
            for i=1:length(muS);   %the optimal (unbiased) criteria per condition
                if length(x)>11
                    %in current code this must be both rats, with bias term for each
                    sID=params.subjectID(i)~=params.subjectID(1)+1; % evaluates to 1 and 2 for 1st and 2nd rat (not good for n rats)
                    p.relativeMissCost=x(11+sID);
                end
                switch p.sdtDistributionType
                    case {'gaussian','eqVarGaussian'}
                        adjustedCrit(i)=p.fitCriterionFromGaussParams([muN(i) sigmaN(i)],[muS(i) sigmaS(i)]);
                    case 'gev'
                        adjustedCrit(i)=p.fitCriterionFromEvdParams([shapeN(i) sigmaN(i) muN(i)],[shapeS(i) sigmaS(i) muS(i)]);
                    otherwise
                        error('bad')
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
            
            miss=normcdf(critUsed,muS,sigmaS); hit=1-miss;
            cr=normcdf(critUsed,muN,sigmaN); fa=1-cr;
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
            if doPlot
                p.viewOnGoingFit(hit,miss,fa,cr,data,x,params,[1 2]);
                
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
            if doPlot
                p.viewOnGoingFit(hit,miss,fa,cr,data,x,params,[1 2],true)
                
                figure(3);
                for i=1:length(params.numTc*params.numFc);
                    subplot(params.numTc,params.numFc,i); hold off
                    loc=linspace(-10,10,100);
                    plot(loc,normpdf(loc,params.muS(i),params.sigmaS(i)),'g'); hold on
                    plot(loc,normpdf(loc,params.muN(i),params.sigmaN(i)),'r')
                    
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
        function viewOnGoingFit(p,hit,miss,fa,cr,data,x,params,handles,includeSubjectData)
            
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
                plot(data.fa(1:5:16),data.hit(1:5:16),'.r');
                %plot(fa,hit,'ok');
                %plot(fa(end-params.numTc:end),hit(end-params.numTc:end),'ob');
                %plot(fa(1:5:16),hit(1:5:16),'or');
            end
            
            % plot one criterion curve
            cInd=length(params.muS)-p.numTc+1; %full contrast no flank ind
            
            
            
            switch p.sdtDistributionType
                case {'gaussian','eqVarGaussian'}
                    n=20;
                    critSweep=linspace(-1,3,n);
                    [tempParams numSubs]=p.adjustSubjectsIndex(params,n);
                    h=1-normcdf(repmat(critSweep,1,numSubs),params.muS(cInd),params.sigmaS(cInd));
                    f=1-normcdf(repmat(critSweep,1,numSubs),params.muN(cInd),params.sigmaN(cInd));
                    
                case 'gev'
                    n=30;
                    critSweep=linspace(-2,3,n);
                    [tempParams numSubs]=p.adjustSubjectsIndex(params,n);
                    h=1-gevcdf(repmat(critSweep,1,numSubs),params.shapeS(cInd),params.sigmaS(cInd),params.muS(cInd));
                    f=1-gevcdf(repmat(critSweep,1,numSubs),params.shapeN(cInd),params.sigmaN(cInd),params.muN(cInd));
                otherwise
                    error('bad')
            end
            [h f] = p.adjustForGuessingAndBias(x,tempParams,h,f);
            plot(f,h,'color',[0.8 0.8 0.8])
            
            for i=2:params.numTc+1  %fc curves, tc==1 --> blue
                n=10; % sample points along arc
                [modParams numSubs]=p.adjustSubjectsIndex(params,n);
                
                %fcs=linspace(-0.5,3,n); % watch it fall to zero for "negative flanker contrast"
                fcs=repmat(linspace(0,5,n),1,numSubs); % watch it fall to zero for "negative flanker contrast"
                tcs=p.tc(i)*ones(1,n*numSubs);  % subject-model same contrast assumption was previously checked
                %[muS muN sigmaS sigmaN]=getLinearMuSigma(p,x,tcs,fcs);
                [h f]=p.getRatesAndCriteria(x,tcs,fcs,modParams,params.anchorCriteria);
                if i==params.numTc+1
                    plot(f,h,'b')
                else
                    plot(f,h,'k')
                end
            end
            
            for i=1:params.numFc % tc curves, fc==0 --> red
                n=20; % sample points along arc
                [modParams numSubs]=p.adjustSubjectsIndex(params,n);
                tcs=repmat(linspace(0.001,10,n),1,numSubs);
                fcs=p.fc(i)*ones(1,n*numSubs);  % subject-model same contrast assumption was previously checked
                %[muS muN sigmaS sigmaN]=getLinearMuSigma(p,x,tcs,fcs);
                [h f]=p.getRatesAndCriteria(x,tcs,fcs,modParams,params.anchorCriteria);
                if i==1
                    plot(f,h,'r')
                else
                    plot(f,h,'k')
                end
            end
            
            xlabel('False Alarm Rate')
            ylabel('Hit Rate')
            axis square
            set(gca,'xTick',[0 1],'xTickLabel',[0  1],'yTick',[0  1],'yTickLabel',[0  1])
            
            writeParameterValues(p,x,data,params)
            set(gcf,'position',[50 100 750 750])
            drawnow
        end
        function [params numSubs]=adjustSubjectsIndex(p,params,n);
            numSubs=length(unique(params.subjectID));
            switch numSubs
                case 1
                    %nothing to do
                case 2
                    %get the values
                    first=params.subjectID(1);
                    second=params.subjectID(end);
                    params.subjectID=[repmat(first,1,n) repmat(second,1,n)]; % overwrite for the new size
                otherwise
                    error('code written for 2 subjects')
            end
            
            
        end
        function writeParameterValues(p,x,data,params)
            
            nckLL=sum(p.logNchoosekPerCondition(data));
            numParams=length(x);
            if ~strcmp(p.critLearningRate,'fit')
                % if alpha (learning rate) was not fit, don't count it
                numParams=numParams-1;
            end
            AIC=2*numParams-(params.modelLL+nckLL);
            
            switch p.sdtDistributionType  % maybe the model name sets the other params?
                case 'gaussian'
                    names={'\alpha','\mu_t','\mu_f','\sigma_t','\sigma_f'};
                    values=[p.getCritLearningRate(x(1)) x(2:5)];
                    if length(x)==6
                        names{end+1}='\gamma';
                        values=x(6);
                    elseif length(x)>6
                        names{end+1}='\gamma_t';
                        names{end+1}='\gamma_f';
                        values(6:7)=x(6:7);
                    end
                    
                    if length(x)==8
                        error('not yet')
                    elseif length(x)==11
                        error('not yet')
                    elseif length(x)==11
                        error('not yet')
                    elseif length(x)==13
                        names{end+1}='g_1'; %8
                        names{end+1}='g_2'; %9
                        names{end+1}='y|g_1';%10
                        names{end+1}='y|g_2';%11
                        names{end+1}='b_1';%12
                        names{end+1}='b_2';%13
                        values(8:11)=[1 1 1 1]./(1+exp(x(8:11)));
                        values(12:13)=x(12:13);
                    end
                    
                case 'eqVarGaussian'
                    names={'\alpha','\mu_t','\mu_f','\sigma_t','\sigma_f'};
                    values=[p.getCritLearningRate(x(1)) x(2:end) 0 0];
                case 'gev'
                    names={'\alpha','\mu_t','\mu_f','\sigma_t','\sigma_f','\kappa_t','\kappa_f'};
                    values=[p.getCritLearningRate(x(1)) x(2:end)];
                otherwise
                    error
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
        function AIC=viewModel(p,includeSubjectData)
            if ~exist('includeSubjectData','var') || isempty(includeSubjectData)
                includeSubjectData=true;
            end
            
            x=p.cache.gauss.modelParams;
            [data params]=p.getDataFromSubjectCache;
            [hit fa miss cr adjustedCrit critUsed params]=getRatesAndCriteria(p,x,params.tcs,params.fcs,params);
            params.modelLL=p.logLiklihood(data,hit,fa,miss,cr);
            
            p.viewOnGoingFit(hit,miss,fa,cr,data,x,params,gcf,false)
            if includeSubjectData
                includeArrows=false;
                p.plotROC([],[],'subject',includeArrows);
            end
            
            
        end
        function p=setGaussDistParamsFromModelFit(p,x)
            temp=p.relativeMissCost;
            p.relativeMissCost=x(1);
            tm=x(2);
            fm=x(3);
            ts=x(4);
            fs=x(5);
            
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
            for i=1:p.numIttn*10
                ce=p.gauss(p.loc,0,p.stdT);
                dv(i)=max(ce.*randn(1,p.numNodes));
            end
            figure; hist(dv,200);
            xs=gevfit(dv);
            j=1;
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
                                xn=p.cache.xn(fInds(f),tInds(t),:);
                                xs=p.cache.xs(fInds(f),tInds(t),:);
                                
                                ys=gevpdf(p.edges,xs(1),xs(2),xs(3));
                                yn=gevpdf(p.edges,xn(1),xn(2),xn(3));
                                plot(p.edges,yn,'r');
                                plot(p.edges,ys,'g');
                                
                                %plot([xn(3) xn(3)],ylim,'r')
                                %plot([xs(3) xs(3)],ylim,'g')
                                crit=p.crit(fInds(f),tInds(t));
                                plot(crit([1 1]),ylim,'k')
                                %set(gca,'xlim',[0 0.2],'ylim',[0 150])
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
                subjectInds=1:length(p.cache.subjectData);
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
            p=p.init;  % in case setup has changed
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
            ce=p.current.tc*targetThere*p.gauss(p.loc,0,p.stdT)+...
                p.current.fc*p.gauss(p.loc,-p.d,p.stdF)+...
                p.current.fc*p.gauss(p.loc,p.d,p.stdF);
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
                        p.current.offsetMatrix=p.offsetMatrix; % this is pre-cached purely for compute speed
                        
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
            p.save;
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
            [fInd tInd tIndNoSig]=p.getContrastIndsFromCurrentOrArg()
            
            for f=1:length(fInd)
                for t=1:length(tInd)
                    switch p.optimalCritMethod
                        case 'gauss.xn'
                            error('not yet.. still in fitGaussianSDT')
                            p.cache.gauss.crit(fInd(f),tInd(t))=crit;
                        case 'fitEvd'
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
                        case 'raw'
                            error('not yet ... copy from other code')
                        otherwise
                            p.optimalCritMethod
                            error('bad')
                    end
                    p.crit(fInd(f),tInd(t))=crit;
                end
            end
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
            er=(1-normcdf(crit,xn(1),xn(2)))+normcdf(crit,xs(1),xs(2))*relativeMissCost;
            er=er/2;
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
            if length(x)==8
                %in current code this must be a 1 global guess (pGuess)
                % (prob one rat)
                error('not yet')
            elseif length(x)==9
                %in current code this must be global guesses and guess bias (pGuess and pYesGivenGuess)
                % (prob one rat)
                error('not yet')
            elseif length(x)>9
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
                    %adjust for guessing
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
                end
                
                
            end
        end
    end % methods
end % classdef