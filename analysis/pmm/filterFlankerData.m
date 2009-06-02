function d=filterFlankerData(d,filter);
%removes trials to match the requested filter

switch class(filter)
    case 'char'
        temp=filter; clear filter;
        filter{1}.type=temp;
        filter{1}.paramters=[];
    case 'cell'
        %okay
    otherwise
        filter
        class(filter)
        error('bad filter class')
end

for i=1:length(filter)
    if ~isempty(filter{i})
        switch filter{i}.type
            case '9.4'
                d=removeSomeSmalls(d,d.step~=9 | d.flankerContrast~=0.4);
            case '9.4range'  % included interleaved no flanks
                cands=~(d.step~=9 | d.flankerContrast~=0.4);
                cands=cands & ~( d.date>datenum('May.2,2008') & d.date<datenum('May.11,2008')); % this filters out 3 days of contrast sweep that get in the way for early rats 
                %note:still don't have a solution for mulitple independant
                %blocks of 9.4... but this might never happen
                rng=minmax(find(cands));
                d=removeSomeSmalls(d,d.trialNumber<rng(1) | d.trialNumber>rng(2));
                if 0 % view
                     figure;plot(cands); hold on; plot(rng,[.8,.8],'r'); pause
                end
            case '9.4.1+nf'
                d=filterFlankerData(d,'9.4range');
                if any(~ismember(d.targetContrast,[0 1]))
                    error('need to pair up contrasts!')
                     xxx=nearestIndices(A,B);
                end
                if any(~ismember(d.flankerContrast,[0 .4]))
                    switch d.info.subject{1}
                        case '230'
                            % a quick hiccup to 9.3 can be reomved.
                            %this methpd keeps the thirty or so no flnkas during 9.3
                            [nfInds aa bb conditionColors d ]=getFlankerConditionInds(d,[],'noFlank');
                            %doPlotPercentCorrect(d,[],[],[],[],[],[],[],[],[],[],[],{nfInds,conditionColors})
                            pruneFraction=0.04; 
                            wrongNFs=nearestIndices(nfInds, d.flankerContrast==0.3,pruneFraction);  % this is faster to use 9.3.  more general would be to find the 9.4 side
                            keptNFs=(nfInds & ~wrongNFs);
                            d=removeSomeSmalls(d,~(keptNFs | d.flankerContrast==0.4))
                        otherwise
                            error('need to pair up contrasts! check that it works for this rat')
                    end

                end
            case 'X.4'
                % all steps where flankers are 0.4 (usually 9 and 10)
                % some rats have a different number of steps (this includes the functionally equialent 6 and 7)
                d=removeSomeSmalls(d,d.flankerContrast~=0.4);
                %case 'X.4.6' %used by 137 136
                %    d=removeSomeSmalls(d,~(d.flankerContrast==0.4 & abs(d.targetContrast-0.5)<10^-9));
            case {'9','11','12','13','14'}
                step=str2num(filter{i}.type);
                d=removeSomeSmalls(d,d.step~=step);
            case 'noFlanks'
                d=removeSomeSmalls(d,d.flankerContrast~=0);
            case 'preFlankerStep'
                firstFlankerStep=d.step(min(find(d.flankerContrast~=0 & ~isnan(d.flankerContrast))));
                d=removeSomeSmalls(d,d.step~=firstFlankerStep-1);  %only the step before it
            case 'preFlankerStep.last400'
                %get the trial right before, so as not to confuse the
                %learning process.
                firstFlankerStep=d.step(min(find(d.flankerContrast~=0 & ~isnan(d.flankerContrast))));
                numTrials=400;
                lastPreFlankerTrial=max(d.trialNumber(d.step==firstFlankerStep-1));
                d=removeSomeSmalls(d,d.step~=firstFlankerStep-1 | d.trialNumber<(lastPreFlankerTrial-numTrials+1));
                if size(d.date,2)~=400
                    keyboard
                    error(sprintf('didn''t get 500 trials... maybe this rat never did 500 trial on step %d',firstFlankerStep-1))
                end
            case 'preFlankerStep.matchTrials.1'
                %get the same numer of trials as flanker contrast 0.1 on
                %the first flanker step... this is a fair way to match
                %error bars...
                firstFlankerStep=d.step(min(find(d.flankerContrast~=0 & ~isnan(d.flankerContrast))));
                numTrials=sum(d.step==firstFlankerStep & d.flankerContrast==0.1)
                lastPreFlankerTrial=max(d.trialNumber(d.step==firstFlankerStep-1));
                d=removeSomeSmalls(d,d.step~=firstFlankerStep-1 | d.trialNumber<(lastPreFlankerTrial-numTrials+1));             
            case 'none'
                %don't filter; keep all
            case 'responseSpeed'               
                range=filter{i}.parameters.range;
                d=removeSomeSmalls(d,~(d.responseTime>range(1) & d.responseTime<range(2)));
            case {'manualVersion'}
               d=removeSomeSmalls(d,~(ismember(d.manualVersion,filter{i}.includedVersions)));      
            case 'responseSpeedPercentile'
                range=filter{i}.parameters.range;
                sorted=sort(d.responseTime);
                rangeInds=[max(floor(range(1)*length(sorted)),1) ceil(range(2)*length(sorted))];
                rangeValue=sorted(rangeInds);
                d=removeSomeSmalls(d,~(d.responseTime>rangeValue(1) & d.responseTime<rangeValue(2)));  
            case 'trialThisBlockRange'
                range=filter{i}.parameters.range;
                d=removeSomeSmalls(d,~(d.trialThisBlock>range(1) & d.trialThisBlock<range(2))); 
            case {'performanceRange','performancePercentile'}
                goods=getGoods(d,filter{i}.parameters.goodType);
                conditionType=filter{i}.parameters.whichCondition{1};
                conditionNumbers=filter{i}.parameters.whichCondition{2};
                whichForPerformanceConditions=getFlankerConditionInds(d,goods,conditionType);
                whichForPerformance=logical(zeros(size(d.date))); 
                for j=1:length(conditionNumbers)
                    %joint condition includes all the conditions listed
                    whichForPerformance=whichForPerformance | whichForPerformanceConditions(conditionNumbers(j),:);
                end
                switch filter{i}.parameters.performanceMethod
                    case 'pCorrect'
                        %calculate the performance at the desired condition
                        lowBound=filter{i}.parameters.performanceParameters{1}(1);
                        highBound=filter{i}.parameters.performanceParameters{1}(2);
                        kernal=filter{i}.parameters.performanceParameters{2};
                        smoothingWidth=filter{i}.parameters.performanceParameters{3};
                        [performance]=calculateSmoothedPerformances(d.correct(whichForPerformance)',smoothingWidth,kernal,'powerlawBW');
                        analyzedInds=find(whichForPerformance);

                        switch filter{i}.type
                            case 'performanceRange'
                                withinRange=performance>=lowBound & performance<=highBound;
                            case 'performancePercentile'
                                validPerformance=performance(~isnan(performance));
                                lowBoundInd=ceil([lowBound]*length(validPerformance));
                                highBoundInd=floor([highBound]*length(validPerformance));
                                ranked=sort(validPerformance,'ascend');
                                lowBound=ranked(lowBoundInd);
                                highBound=ranked(highBoundInd);
                                withinRange=performance>=lowBound & performance<=highBound;         
                        end    

                        selectedTrials=logical(zeros(size(d.date)));
                        % for every trial above threshold, set the range before it true
                        prevInd=1;
                        for j=1:length(analyzedInds)
                            if ~isnan(performance(j)) % this won't analyze the first pts which are garaunteed to be nans, so could potentially
                                selectedTrials(prevInd:analyzedInds(j))=withinRange(j);
                                prevInd=analyzedInds(j);                           
                            end
                        end

                    otherwise
                        filter{i}.parameters
                        filter{i}.parameters.performanceMethod
                        error('bad method')
                end

                disp(sprintf('fraction trials removed for performance out of range: %2.2g',1-mean(selectedTrials)))
                %check
                inspectFilter=0;
                if inspectFilter
                    figure; hold on;
                    %doPlotPercentCorrect(d,goods,smoothingWidth,[],[],[],[],[],[],[],[],[]); %filter might not match symetricBoxcar, etc
                    plot(find(selectedTrials), repmat(lowBound,1,sum(selectedTrials)),'.') %lb
                    plot(find(selectedTrials), repmat(highBound,1,sum(selectedTrials)),'.') %ub
                    plot(analyzedInds,performance) % measured performance
                    plot(analyzedInds(withinRange),performance(withinRange),'g.') %within range


                    
                    [p]=calculateSmoothedPerformances(d.correct(goods)',smoothingWidth,kernal,'powerlawBW');
                    plot(find(goods),p,'color',[0,0,0], 'linewidth', 2)
                    pause
                    figure
                    %%quick attempt to plot ontop of main, does not work indexing the wrong length performance b/c 
                    %plot(find(selectedTrials), p(find(selectedTrials)),'.r') %within, on top of full performance average

                    %alternate mini checks that works
                    %figure; plot(selectedTrials); axis([0 length(d.date) -.5 1.5]); pause;
                    %figure; plot(performance);hold on; plot(find(performance>lowBound & performance<highBound),performance(performance>lowBound & performance<highBound),'r.'); plot([0,length(performance)],[lowBound lowBound],'k'); plot([0,length(performance)],[highBound highBound],'k')
                end
                d=removeSomeSmalls(d,~selectedTrials)
            otherwise
                filter{i}.type
                error('not an approved filterType')
        end
    end
end