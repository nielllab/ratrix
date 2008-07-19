function [smallData largeData]=getRatrixDataFromStation(remotePath,subjects,loadMethod,loadMethodParams,stations,stationIP,saveSmallData,saveLargeData,data)
% load out/rat_102/largeData
% [smallData]=getRatrixDataFromStation('C\pmeier\Ratrix\Boxes\box1\',{'rat_102'},'sinceDate',then,1,[],1,largeData)
% [smallData largeData]=getRatrixDataFromStation('C\pmeier\Ratrix\Boxes\box1\',{'rat_106'},2,[],1)
% [smallData largeData]=getRatrixDataFromStation('C\pmeier\Ratrix\Boxes\box1\',{'rat_107'},3,[],1)
%if "data" is present as last argument it is assumed to be largeData and overrides the remote loading

%load bigData_rat102 %contains 10364 trials in full, includes many missed frames, 650MB

savePath=('C:\pmeier\RSTools\out');

if isempty(stationIP)
    stationIP{1}='192.168.0.101';
    stationIP{2}='192.168.0.102';
    stationIP{3}='192.168.0.103';
    stationIP{4}='192.168.0.104';
    stationIP{9}='192.168.0.109';
    stationIP{10}='192.168.0.110';
    stationIP{11}='192.168.0.111';
end

if ~exist('saveLargeData','var')
    saveLargeData = 0;
end

if ~exist('data','var')
    %remotePath=['C\pmeier\Ratrix\Boxes\box1\'];
    %subjects={'rat_102'}; %{'test','rat_w'}; %set subjects=[] for all

    %     %make sure we can call the recent verison of loadRatrixData
    %         rootPath='C:\pmeier\Ratrix\'; pathSep='\';
    %         warning('off','MATLAB:dispatcher:nameConflict')
    %         addpath(genpath([rootPath 'Server' pathSep]));
    %         warning('on','MATLAB:dispatcher:nameConflict')
    %     %but the most recent version in this folder

    numStations=size(stationIP,2);
    selectedStations=[1:numStations];  %eventually could do all but right now just 1
    selectedStations=stations;  %=stations;  %have to make sure to format data chronologically if more than on station

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for selectedStation=selectedStations
        path=sprintf('\\\\%s\\%s',char(stationIP(selectedStation)),remotePath);
        [data sessionIDs]=loadRatrixData(path,subjects,loadMethod,loadMethodParams);
        largeData=data;
    end
else
    sessionIDs='unknown';
    %or check to see if it exists within the large data ...
end

%reduce dataSize and concatenate
%dataSmall=returnSmallData(data)
selectVariablesMethod='specificList'

%sort dates of the sessions here

%preallocate to speed it up
numSessions=length({data{:,2}});
for session=1:numSessions
    if ~isempty(data{session})
        numTrialsPerSession(session)=size(data{session}.trialRecords,2);
    else
        numTrialsPerSession(session)=0;
    end
end
preAllocationLength=sum(numTrialsPerSession);
cumTrialsAtStart=[0 cumsum(numTrialsPerSession)];

%createEmptyFields
switch selectVariablesMethod
    case 'GeneralMethod'
        [vecNames junk temp]=trialRecordStructureToVector(data{1}.trialRecords);
        F=fields(temp); numFields=size(F,1);
        smallData=initializeFields(struct(),varNames,structNames,data{1}.trialRecords);
        numTimesNewFieldShowedUp=0;
    case 'specificList'
        savedVariableNames=...
            {'containedManualPokes','.containedManualPokes','int8';...  % this field causes problems sometimes..why? - because its the first one in the list... all have probs.  why? dunno. problem fixed by doing a trial, consider rejecting last trial
            'correct','.correct','int8';...
            'msPenalty','.trialManager.trialManager.msPenalty','double';...
            'totalFrames','.responseDetails.totalFrames','uint32';...
            'startTime','.responseDetails.startTime','double';...
            'numMisses','.responseDetails.numMisses','uint32';...
            'expectedRewardIfRight','.trialManager.trialManager.rewardSizeULorMS', 'double'; ... %This doesn't update every trial like it should.  07/05/30 hopefully fixed 07/06/13 -pmm
            'correctionTrial','.stimDetails.correctionTrial','int8';...
            'correctResponseIsLeft','.stimDetails.correctResponseIsLeft','int8';...
            'targetContrast','.stimDetails.targetContrast','double';...
            'targetOrientation','.stimDetails.targetOrientation','double';...
            'flankerContrast','.stimDetails.flankerContrast','double';...
            'flankerOrientation','.stimDetails.flankerOrientation(1)','double';... %need to deal with when there is more than 1 flanker!
            'deviation','.stimDetails.deviation','double';...
            'devPix','.stimDetails.devPix','double';...
            'phase','.stimDetails.phase','double'};
        % 'actualRewardDuration','.actualRewardDuration','double'};

        maxGeneralFields=7;


        numFields=size(savedVariableNames,1);
        smallData=initializeFields(struct(),savedVariableNames(:,1),savedVariableNames(:,2),data{1}.trialRecords,preAllocationLength,savedVariableNames(:,3));
        %specialCaseVariables={'date', 'response'}
        smallData.date=zeros(1,preAllocationLength);
        smallData.response=zeros(1,preAllocationLength,'uint8');
        smallData.responseTime=zeros(1,preAllocationLength);
        smallData.numRequestLicks=zeros(1,preAllocationLength,'uint8');
        smallData.actualRewardDuration=zeros(1,preAllocationLength,'double');
end

%concatenate each session
disp('Converting largeData to smallData')
for session=1:numSessions
    numTrials=numTrialsPerSession(session); %size(data{session}.trialRecords,2);
    numSoFar=cumTrialsAtStart(session);
    if ~isempty(data{session})
        trialRecords=data{session}.trialRecords;
        curFields=fields(trialRecords);
    else
        trialRecords=[];
    end
    disp(sprintf('Number of trials gathered so far: %d \t Percent complete: %4.1f', numSoFar,100*numSoFar/cumTrialsAtStart(end)))
    if size(trialRecords,2)>0
        switch selectVariablesMethod

            case 'GeneralMethod'  %problems still: Reference to non-existent field 'trialManager_trialManager_msRewardSoundDuration'.
                [vecNames structNames temp]=trialRecordStructureToVector(trialRecords);

                getNewFieldsIfTheyShowUp=0;
                %     if getNewFieldsIfTheyShowUp
                %         %initialize any new fields if they show up
                %         newFields=setdiff(vecNames,fields(smallData));
                %         if size(newFields,1)>0
                %             numTimesNewFieldShowedUp=numTimesNewFieldShowedUp+1
                %             newFieldsStored(numTimesNewFieldShowedUp).newFields=newFields;  %just usable for debugging
                %             size(newFields)
                %             smallData=initializeFields(smallData,newFields,temp)
                %             smallData=initializeFields(smallData,varNames,structNames,trialRecords)
                %             warning('a new field appeared!')
                %             pause
                %         end
                %         F=fields(temp);
                %         numFields=size(F,1);
                %     end

                %add on to each field
                for f=1:numFields
                    if iscell(eval(sprintf('temp.%s',char(F(f)))))
                        %cells must be filled per trial
                        for i=1:numTrials
                            trial=numSoFar+i;
                            command=sprintf('smallData.%s{%d}=temp.%s(%d);',char(F(f)),trial,char(F(f)),i)
                            eval(command)
                        end
                    else
                        command=sprintf('smallData.%s(end+1:end+numTrials)=temp.%s;',char(F(f)),char(F(f)))
                        eval(command)
                    end
                end
            case 'specificList'

                %here is where we need to make the lists specific to each
                %trial manager. right now, just limiting fields for free
                %drinks. consider having a general list and a specifics
                %list.
                if strcmp(trialRecords(1).trialManagerClass,'freeDrinks')
                    %this will prevent the latter fields from being
                    %filled... better would be to initialize the Nans
                    disp('**WARNING: many empty fields b/c freedrinks--> values set to 0**')
                    numFields=maxGeneralFields;
                end
                %SAVE UNMODIFIED LIST OF VARIABLES
                for f=1:numFields
                    %cells must be filled per trial AND 2 deep structures must be filled per trial
                    for i=1:numTrials
                        trial=numSoFar+i;
                        if iscell(eval(sprintf('trialRecords(1)%s',char(savedVariableNames(f,2)))))
                            command=sprintf('smallData.%s{%d}=trialRecords(%d)%s;',char(savedVariableNames(f,1)),trial,i,char(savedVariableNames(f,2)));
                        else
                            command=sprintf('smallData.%s(%d)=trialRecords(%d)%s;',char(savedVariableNames(f,1)),trial,i,char(savedVariableNames(f,2)));
                        end
                        if 0
                            disp(sprintf('smallData.%s(%d)',char(savedVariableNames(f,1)),trial))
                            eval(sprintf('smallData.%s(%d)',char(savedVariableNames(f,1)),trial))
                            disp(sprintf('trialRecords(%d)%s',i,char(savedVariableNames(f,2))))
                            eval(sprintf('trialRecords(%d)%s',i,char(savedVariableNames(f,2))))
                            disp(command)
                        end
                        eval(command)
                    end
                end

                %SAVE SPECIAL CASE VARIABLES
                for i=1:numTrials
                    trial=numSoFar+i;
                    %response can be represented as one number
                    r=find(trialRecords(i).response);
                    if size(r,2)==1 %only one response
                        smallData.response(trial)=r;
                    else
                        smallData.response(trial)=-1;
                    end

                    %should flanker orientation become a structure?
                    %in which case remove it from the list above with
                    %that hack call to only save the first one...
                    %smallData.flankerOrientation{trial}=trialRecords(i).stimDetails.flankerOrientation;
                    %must change flanker analysis code a bunch if so

                    %or maybe a for loop that makes each flanker its own
                    %variable - can't depends on a constant muber of
                    %flankers need NaN's

                    %date can be represented as one number
                    smallData.date(trial)=datenum(trialRecords(i).date);

                    %reponse details: responseTime, numRequestLicks
                    temp=trialRecords(i).responseDetails;


                    jhfhgf=-1;  %can't figure out why errors occur on cell2num only if using datacollection gui

                    if any(strcmp(fields(temp),'times')) % if the field exists
                        smallData.responseTime(trial)=cell2num(temp.times(end));
                        %interLickInterval=diff(cell2num(temp.times));  % a vector of unknown length
                    else
                        smallData.responseTime(trial)=-1;
                    end

                    if any(strcmp(fields(temp),'tries')) % if the field exists
                        smallData.numRequestLicks(trial)=size(temp.tries,2)-1;
                    else
                        smallData.numRequestLicks(trial)=-1;
                    end

                    %confirm field exists
                    if any(strcmp(curFields,'actualRewardDuration'))
                        %Must check if empty.
                        if ~isempty(trialRecords(i).actualRewardDuration) % if the field is not empty!!
                            smallData.actualRewardDuration(trial)=trialRecords(i).actualRewardDuration;
                        else
                            smallData.actualRewardDuration(trial)=0;
                        end
                    else
                        smallData.actualRewardDuration(trial)=NaN; %sometimes b/c of manual kill
                    end

                end

            otherwise
                error('unknown method of saving variables')
        end

    end
end

%make sure sorted chronological
[junk chonological]=sort(smallData.date);
outFields=fields(smallData);
numFields=size(outFields,1);
for f=1:numFields
    command=sprintf('smallData.%s=smallData.%s(chonological);',char(outFields(f)),char(outFields(f)));
    %disp(command)
    eval(command)
end

smallData.info.sessionIDs=sessionIDs;


if saveSmallData
    disp('saving smallData... ')
    subjectFolder=lower(char(subjects(1)));
    dirs=dir(sprintf('%s/*%s',savePath,subjectFolder));

    if size(dirs,1)==1
        %continue
    elseif size(dirs,1)==0
        [SUCCESS,MESSAGE,MESSAGEID] = mkdir(savePath,subjectFolder);
        disp(sprintf('making a new directory for %s', subjectFolder));
        save(sprintf('%s/%s/smallData',savePath,subjectFolder), 'smallData');
    else
        error('unexpected number of directories with the same name.')
    end

    save(sprintf('%s/%s/smallData',savePath,subjectFolder), 'smallData');
end

if saveLargeData
    if exist('largeData','var') %it only exists if we grabbed it remotely

        disp('saving largeData... this could take a little while')
        save(sprintf('%s/%s/largeData',savePath,subjectFolder), 'largeData')
        valveErrors=inspectValveErrors(largeData,selectedStation,0)
        save(sprintf('%s/%s/valveErrors',savePath,subjectFolder), 'valveErrors')
    end
end

function smallData=initializeFields(smallData,varNames,structNames,trialRecords,preAllocationLength,varClass)
numFields=size(varNames,1);
for i=1:numFields
    if iscell(eval(sprintf('trialRecords(1)%s',char(structNames(i)))))
        command=sprintf('smallData.%s={};',char(varNames(i)));
    else
        command=sprintf('smallData.%s=[];',char(varNames(i)));
        if exist('preAllocationLength','var')
            if exist('varClass','var')
                command=sprintf('smallData.%s=zeros(1,preAllocationLength,''%s'');',char(varNames(i)),char(varClass(i)));
            else
                command=sprintf('smallData.%s=zeros(1,preAllocationLength);',char(varNames(i)));
            end
        end
    end
    %disp(command)
    eval(command);
end
