%maxDetectionModel

%% set parameters
numT=100;  % per target(x1)
numF=100;  % per flank (x2)
numTrials=1000; % per condition
SNR=1;  % signal magnitude for 1 contrast vs. noise magnitude for zero contrast, same scalar units as linear contrast
targetContrasts=[0.25 0.5 0.75 1];
flankerContrasts=[0 0.25 0.5 0.75 1];
flankerSuppressions=[0 0.25 0.5 0.75 1];  % 1 would be "perfect" for *independant* channels, full suppressed flankers never causes a response
blurs=[0 0.25 0.5 0.75 1]; %0.1;  % how much the target stimulus will drive the flanker neurons.   this could even be from the psf of optics.
initialThreshold=3; % this is just some tinkered param... not chosed for a principled reason, initial threshold
learningRate=initialThreshold/1000;  % set to zero for no adapting


%%  initialize
targetPresent=rand(length(targetContrasts),length(flankerContrasts),numTrials)<0.5;
response=nan(size(targetPresent));
thresholdHistory=nan(size(targetPresent));
targetMax=nan(size(targetPresent));
flankerMax=nan(size(targetPresent));
threshold=initialThreshold;

%variables for plotting
names.stats={'hits','CRs'};%,'yes','pctCorrect'}; only need hits CRs for doHitFaScatter
names.subjects={'model'};
nameStr='colin';  %for now cuz thats what 234/231 did
names.conditions=[];  % fill as you go
close all
mainFigure=figure;



%% do similation

for fs=1:length(flankerSuppressions)
    flankerSuppression=flankerSuppressions(fs);
    for b=1:length(blurs)
        blur=blurs(b);
        thisRun=sprintf('\n run: fs=%2.2f b=%2.2f',flankerSuppression,blur);
        disp(thisRun)
        
        %reinitialize between runs
        stats=nan(1,length(names.stats),length(targetContrasts)*length(flankerContrasts));
        CI=nan(1,length(names.stats),length(targetContrasts)*length(flankerContrasts),2);
        response=nan(size(targetPresent));
        counter=0;

        for tc=1:length(targetContrasts)
            for fc=1:length(flankerContrasts)
                threshold=initialThreshold; % start each condition at the same point
                for i=1:numTrials
                    
                    %NOISE RESPONSE
                    t=(1/SNR)*randn(1,numT);   % targer neurons
                    f=(1/SNR)*randn(1,numF*2); % flanker neurons
                    % another idea:  restrict to positive
                    %t=baseline*abs(randn(1,numT));  % some posititive rate, like the error function
                    
                    %STIMULUS RESPONSE
                    
                    % add on the effect of the target if its there
                    if targetPresent(tc,fc,i)
                        targetContrast=targetContrasts(tc);
                    else
                        targetContrast=0;
                    end
                    
                    %flanker response
                    f=f...
                        +flankerContrasts(fc)*randn(1,numF*2)...  %the normal effect of the flanker
                        +targetContrast*blur*randn(1,numF*2);    % the "blurring" of the target ontop of the flanker
                    f=f*(1-flankerSuppression);
                    
                    %target response
                    t=t...
                        +targetContrast *randn(1,numT)...  %the normal effect of the flanker
                        +flankerContrasts(fc)*blur*2*randn(1,numT);  % the "blurring" of the flanker ontop of the target  (x2 cuz 2 flankers)
                    
                    %decision
                    response(tc,fc,i)=max([t f])>threshold;
                    %this should related to the extreme value distribution of the model system
                    %our threshold is "learned" through a staircase
                    
                    %learn
                    if learningRate~=0  %only bother if its non-zero
                        if response(tc,fc,i)~=targetPresent(tc,fc,i)
                            %change decision threshold when wrong
                            threshold=threshold+learningRate*(-1)^(targetPresent(tc,fc,i));
                            %if the target was there, then it was missed, and so threshold goes down (makes subject more likely to say yes)
                            %if the target was NOT there, then subj FA'd, and so threshold goes up   (makes subject more likely to say no)
                        end
                    end
                    
                    %save history for analysis
                    flankerMax(tc,fc,i)=max(f);
                    targetMax(tc,fc,i)=max(t);
                    thresholdHistory(tc,fc,i)=threshold;
                end
                
                counter=counter+1;
                thisName=sprintf('%s-%2.2f-%2.2f',nameStr,targetContrasts(tc),flankerContrasts(fc));
                %disp(thisName)
                fprintf('%d.',counter)
                names.conditions{counter}=thisName;
                
                %get stats for ROC
                for i=1:length(names.stats)
                    switch names.stats{i}
                        case 'hits'
                            [stats(1,counter,i) CI(1,counter,i,1:2)]=binofit(sum(targetPresent(tc,fc,:) & response(tc,fc,:)),sum(targetPresent(tc,fc,:)));
                        case 'CRs'
                            [stats(1,counter,i) CI(1,counter,i,1:2)]=binofit(sum(targetPresent(tc,fc,:)==0 & response(tc,fc,:)==0),sum(targetPresent(tc,fc,:)==0));
                        otherwise
                            error('don''t have it and its not needed.') %'yes','pctCorrect'
                    end
                end
            end
        end
        
        
        % plot distributions
        figure('Position',[10 540 600 600])
        for tc=1:length(targetContrasts)
            for fc=1:length(flankerContrasts)
                subplot(length(targetContrasts)+1,length(flankerContrasts),(tc-1)*length(flankerContrasts)+fc)
                edges=linspace(0,10,100);
                
                %         n=histc(reshape( targetMax(tc,fc,targetPresent(tc,fc,:)==0),1,[]),edges); plot(edges,log(n/sum(n)),'r'); hold on
                %         n=histc(reshape( targetMax(tc,fc,targetPresent(tc,fc,:)==1),1,[]),edges); plot(edges,log(n/sum(n)),'g'); hold on
                %         n=histc(reshape(flankerMax(tc,fc,:),1,[]),edges); plot(edges,log(n/sum(n)),'b');
                %         n=histc(reshape(thresholdHistory(tc,fc,:),1,[]),edges); plot(edges,log(n/sum(n)),'k');
                
                
                n=histc(reshape( targetMax(tc,fc,targetPresent(tc,fc,:)==0),1,[]),edges); plot(edges,n/sum(n),'r'); hold on
                n=histc(reshape( targetMax(tc,fc,targetPresent(tc,fc,:)==1),1,[]),edges); plot(edges,n/sum(n),'g'); hold on
                n=histc(reshape(flankerMax(tc,fc,:),1,[]),edges); plot(edges,n/sum(n),'b');
                n=histc(reshape(thresholdHistory(tc,fc,:),1,[]),edges); plot(edges,n/sum(n),'k');
                
                
                axis([0 5 0 0.15])
                %title(sprintf('c_t= %2.2f,c_f= %2.2f',targetContrasts(tc),flankerContrasts(fc)))
                set(gca,'xTickLabel',[],'yTickLabel',[]);
                if fc==1
                    ylabel(sprintf('t= %2.2f',targetContrasts(tc)))
                end
                if tc==length(targetContrasts)
                    xlabel(sprintf('f= %2.2f',flankerContrasts(fc)))
                    if fc==length(flankerContrasts)
                        ylabel('probability')
                    end
                end
            end
        end
        
        subplot(length(targetContrasts)+1,length(flankerContrasts),(length(flankerContrasts)*length(targetContrasts))+1);
        plot(.5,.5,'g'); hold on
        plot(.5,.5,'r'); hold on
        plot(.5,.5,'b'); hold on
        set(gca,'xTickLabel',[],'yTickLabel',[]);
        legend({'target present','target absent','flanker response'},'Location','NorthEastOutside')
        
        % plot leaning of criteria
        if learningRate~=0
            figure('Position',[390 10 500 500])
            for tc=1:length(targetContrasts)
                for fc=1:length(flankerContrasts)
                    subplot(length(targetContrasts),length(flankerContrasts),(tc-1)*length(flankerContrasts)+fc)
                    edges=linspace(0,10,100);
                    %hist(flankerMax(tc,fc,:))
                    plot([1 numTrials],initialThreshold([1 1]),'k'); hold on
                    plot(1:numTrials,reshape(thresholdHistory(tc,fc,:),1,[]),'g');
                    axis([1 numTrials 2.5 4.5])
                    ylabel('thresh')
                    xlabel('trial')
                    set(gca,'xTickLabel',[1 numTrials],'xTick',[1 numTrials]);
                end
            end
        end
        
        % plot ROC as in rat data
        figure(mainFigure)
        set(gcf,'Position',[10 10 1600 1000])
        subplot(length(flankerSuppressions),length(blurs),(fs-1)*length(blurs)+b);
        
        arrows=[];% for now
        conditions=[];
        subjects=[];
        %params.colors=params.colors; % steal from b4
        params.colors=repmat(jet(length(flankerContrasts)),length(targetContrasts),1); % make it here
        params.stats=stats;  % code uses this one
        doHitFAScatter(stats,CI,names,params,subjects,conditions,0,0,0,0,0,1,arrows);
        
        
        set(gca,'xTickLabel',[],'yTickLabel',[]);
        xlabel(''); ylabel('')
        if b==1
            ylabel(sprintf('fs= %2.2f',flankerSuppressions(fs)))
        end
        if fs==length(flankerSuppressions)
            xlabel(sprintf('b= %2.2f',blurs(b)))
            if b==length(blurs)
                ylabel('hit');
                xlabel('FA');
            end
        end
        
    end
end
