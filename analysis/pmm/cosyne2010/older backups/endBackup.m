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
        modelName='Gauss-nonlinearTFcontrast' %% LL, fixedEye, fitAttnfixedEye
        
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
            relevantCenter=min(relevant):max(relevant);
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
                raw.subjectID=[raw.subjectID repmat(str2num(x.names.subjects{1}),1,length(x.params.raw.numCorrect))];
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
        function  [hit miss fa cr] = adjustForGuessingAndBias(p,x,params,hit,miss,fa,cr)
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
                    try
                        hit(which)=(1-pGuess)*(hit(which))+pGuess*(pYesGivenGuess);
                        fa(which)=(1-pGuess)*(fa(which))+pGuess*(pYesGivenGuess);
                        %no
                        miss(which)=(1-pGuess)*(miss(which))+pGuess*(1-pYesGivenGuess);
                        cr(which)=(1-pGuess)*(cr(which))+pGuess*(1-pYesGivenGuess);
                    catch
                        warning('this is prob b/c which must be numcondition * num subjects and tcs are nto obvious doubled per subject')
                        %consider having params.subjectID reflects the two
                        %subjects and being the right length
                        keyboard
                    end
                end
                
                %check that things are normal
                if ~(all(1-(miss+hit)<10^-10) && all(1-(cr+fa)<10^-10))
                    error('something wrong.. hits and miss should sum to 1')
                end
            end
        end
    end % methods
end % classdef