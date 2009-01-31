function data=ratrixAnalysis(varargin)
if nargin==0
    path='\\Rlab_rig1a\ratrix\Boxes\box1\';
    subjects={'maximillian'};%[];%{'erik'};
    data=loadRatrixData(path,subjects);
elseif nargin==1
    data=varargin{1};
else
    error('wrong nargin')
end

count=0;
for i=1:size(data,1)
    if ~isempty(data{i,1})
        if ~isempty(data{i,2})
            count=count+1;
            realdata{count,1}=data{i,1};
            realdata{count,2}=data{i,2};
        else
            error('first element of data is not empty but second is')
        end
    else
        if ~isempty(data{i,2})
            error('first element of data is empty but second isn''t')
        end
    end
end
realdata

data=realdata;
uniqueNames=unique({data{:,2}});

close all
for subNum=1:length(uniqueNames)
    subData={data{strcmp({data{:,2}},uniqueNames{subNum}),1}};

    firstTrialTime=[];
    for sessionNum=1:length(subData)
        sessionData=subData{sessionNum}.trialRecords;

        if length(sessionData)>=1
            sessionData=sessionData(strcmp({sessionData.trialManagerClass},'nAFC'));
            for i=1:length(sessionData)
                if isempty(firstTrialTime) || etime(firstTrialTime,sessionData(i).date)>0
                    firstTrialTime=sessionData(i).date;
                end
            end
        end
    end

    firstTrialTime

    for sessionNum=1:length(subData)
        sessionData=subData{sessionNum}.trialRecords;

     
        %check integrity of correction trials
        sessionData
        if length(sessionData)>0
            n=length(sessionData)-1; %just look at n previous trials
            details=[sessionData(end-n:end).stimDetails];
            check=[[sessionData(end-n:end).correct]; [sessionData(end-n:end).targetPorts];[details.correctionTrial]];
            check
            for thisCheck=find(check(3,:))
                if thisCheck~=length(sessionData)
                    % on a correction trial...
                    if check(2,thisCheck)==check(2,thisCheck-1) && ...    %the answer has to be the same
                            check(1,thisCheck-1)==0 && ...                     %the previous trial had to be wrong
                            (check(3,thisCheck+1)==1 || check(1,thisCheck)==1) %either the answer is right or the next trial is a correction trial
                        %'correction trial check succeeded'
                    else
                        error('correction trial problem')
                    end
                end
            end
        end
        

        
        if length(sessionData)>=1
            sessionData=sessionData(strcmp({sessionData.trialManagerClass},'nAFC'));

            goodTrials=[];
            for i=1:length(sessionData)
                if islogical(sessionData(i).response) && length(find(sessionData(i).response))==1
                    goodTrials(i)=1;
                else
                    goodTrials(i)=0;
                    %sessionData(i).response
                end

            end
            goodTrials=logical(goodTrials);
            %[length(find(goodTrials==0)) length(find(goodTrials==1)) length(sessionData)]
            sessionData=sessionData(goodTrials);

            if length(sessionData)>1
                disp(sprintf('found data for %s:\t%d good trials',uniqueNames{subNum},length(sessionData)))
                trialDates=[];
                for i=1:length(sessionData)
                    trialDates(i)=etime(sessionData(i).date,firstTrialTime);%datenum(sessionData(i).date);
                end

                [rows cols] = find(vertcat(sessionData.response));
                [rows order]=sort(rows);
                rows=rows';
                responses=cols(order);

                if any(rows~=1:length(sessionData))
                    vertcat(sessionData.response)
                    error('found trials with ambiguous responses')
                end

                performance{subNum,sessionNum}=[[sessionData.correct];trialDates;responses'];
                %performance{subNum,sessionNum}
                

                %save extra parameters for analysis with certain types -pmm
                specialAnalysisType=[]; 
                stimManagers=unique({sessionData.stimManagerClass});
                
                acceptableFlankerStimManagers={'ifFeatureGoRightWithTwoFlank';'blahTest'}
                whereFlankersAre=[];
                for stimManNum=1:size(acceptableFlankerStimManagers,1)
                    whereFlankersAre(stimManNum,:)=strcmp({sessionData.stimManagerClass},acceptableFlankerStimManagers(stimManNum)); 
                end
                flankerTrialInds{subNum,sessionNum}=sum(whereFlankersAre);  %this finds the flanker trials very generally 
                
                if any(flankerTrialInds{subNum,sessionNum})
                    specialAnalysisType='flanker'

                    if ~all(flankerTrialInds{subNum,sessionNum})
                        sprintf('subject: %s',char(uniqueNames(subNum)))
                        sprintf('sessionNum: %d',sessionNum)
                        stimManagers=stimManagers
                        error('not all the flankers in this session use the same stim manager...')
                    end
                end
                
                switch specialAnalysisType
                    case 'flanker'  
                       stimDetails=[sessionData.stimDetails];
                       trialParams{subNum,sessionNum}=[[sessionData.correct];...
                                                        trialDates;...
                                                        responses';...
                                                       [stimDetails.targetContrast];...
                                                       [stimDetails.targetOrientation];...
                                                       [stimDetails.flankerOrientation]];
                    otherwise
                      sprintf('No special analysis parameters saved')
                      trialParams{subNum,sessionNum}=[];
                end
                

                
                subplot(length(uniqueNames),2,subNum*2-1)
                
                %in 2006b, this title is getting erased.  moved to below
                %title(uniqueNames{subNum})
                
                correctInds=find([sessionData.correct]);
                incorrectInds=find(~[sessionData.correct]);
                plot(trialDates(correctInds)/60,responses(correctInds),'go','MarkerSize',3)
                hold on
                plot(trialDates(incorrectInds)/60,responses(incorrectInds),'rx','MarkerSize',3)

                ylim([min(responses)-1 max(responses)+1])
                
                %this is where we moved the title so it wouldn't get erased
                title(uniqueNames{subNum})
            end
        end
    end


    subTrials=[];
    trialNum=1;
    numSessionTrials=zeros(1,size(performance,2));
    for sessionNum=1:size(performance,2)
        numSessionTrials(sessionNum)=size(performance{subNum,sessionNum},2);
        if numSessionTrials(sessionNum)>0
            subTrials(trialNum:trialNum+numSessionTrials(sessionNum)-1,:)=(performance{subNum,sessionNum})';
            trialNum=trialNum+numSessionTrials(sessionNum);
        end
    end

    totalTrials=size(subTrials,1);
    
    [garbage order]=sort(subTrials(:,2));
    subTrials=subTrials(order,:);
    
    correct=subTrials(:,1);
    windowSizes = [10 50 100];
    [performances colors]=calculateSmoothedPerformances(correct,windowSizes,'boxcar','powerlawBW');
    
    subplot(length(uniqueNames),2,subNum*2);
    H2=plot(([1:totalTrials]'), performances*100);

    for i=1:length(H2)
        set(H2(i),'Color',colors(i,:));
    end
    
    plotResponsePatterns=1;
    whichTrialsToAnalyze='lastSession'; %'all','lastSession',500;
    if plotResponsePatterns  
        
        %determine the responseForPatterns vector
        if isnumeric(whichTrialsToAnalyze)
            lastN=min(whichTrialsToAnalyze,size(subTrials,1))
            responseForPatterns=subTrials(end-(lastN-1):end,3)'; % use last N trials
        else
            switch whichTrialsToAnalyze
                case 'all'
                    responseForPatterns=subTrials(:,3)'; % use all trials
                case 'lastSession'
                    responseForPatterns=performance{subNum,1}(3,:);  %only look at the last sessions worth
                otherwise
                    error('unknown request for whichTrialsToAnalyze')
            end
        end
  
        lengthHistory=3;
        numResponseTypes=2;
        plotOn=1;
        if size(responseForPatterns,2)>lengthHistory
            figure
            out=findResponsePatterns(responseForPatterns,lengthHistory,numResponseTypes,plotOn)
        else
            sprintf('No response pattern analysis performed b/c only had %d trials to analyze.',size(responseForPatterns,2))
        end
    end
    
    switch specialAnalysisType
        case 'flanker'
            
            subTrialParams=[];
            trialNum=1;
            for sessionNum=1:size(performance,2)
                numSessionTrials=size(performance{subNum,sessionNum},2);
                if any(flankerTrialInds{subNum,sessionNum})>0
                    
                    numSessionFlankerTrials=sum(flankerTrialInds{subNum,sessionNum});
                   
                    flankerInds=find(flankerTrialInds{subNum,sessionNum});
                    subTrialParams(trialNum:trialNum+numSessionFlankerTrials-1,:)=(trialParams{subNum,sessionNum}(:,flankerInds))';
                    trialNum=trialNum+numSessionFlankerTrials;
                      
                end
            end

            numSubFlankerTrials=size(subTrialParams,1);
            
            [garbage order]=sort(subTrialParams(:,2));
            subTrialParams=subTrialParams(order,:);
 
%             correct=subTrialParams(:,1);
%             trialDates=subTrialParams(:,2);
%             responses=subTrialParams(:,3);
%             targetContrast=subTrialParams(:,4);
%             targetOrientationt=subTrialParams(:,5);
%             flankerOrientation=subTrialParams(:,6);           
            flankerPerformances=doSubjectFlankerAnalysis(subTrialParams);
        otherwise
            sprintf('No special analysis performed.')
    end
    
   

end