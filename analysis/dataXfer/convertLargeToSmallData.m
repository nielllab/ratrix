function smallData=convertLargeToSmallData(dataStoragePath,dataStorageIP,subject,station,loadMethod,loadMethodParams,saveValveErrors,saveInSmallDataFolder, verbose)

switch loadMethod
    case 'singleSession'
        sessionID=loadMethodParams;
        sessionIDs=sessionID;
        loadPath=fullfile(dataStoragePath, subject,'largeData',['Data.' datestr(sessionID,30)]);
    otherwise
        error ('unknown loadMethod')
end

%load large data
disp(sprintf('loading %s',loadPath))
data = load(fullfile('\\',dataStorageIP,loadPath,'trialRecords.mat'));

%convert
if strcmp(fields(data),'trialRecords')
    trialRecords=data.trialRecords;
    numTrials=size(trialRecords,2);
    if numTrials>0
        trialManagerClass=trialRecords(1).trialManagerClass;
        switch trialManagerClass
            case 'freeDrinks'
                smallData=generalConverter(trialRecords);
                stimManagerClass=trialRecords(1).stimManagerClass;
            case 'nAFC'
                smallData=generalConverter(trialRecords);
                stimManagerClass=trialRecords(1).stimManagerClass;
                switch stimManagerClass
                    case 'ifFeatureGoRightWithTwoFlank'
                        smallData=flankerConverter(trialRecords,smallData);
                    case 'cuedIfFeatureGoRightWithTwoFlank'
                        smallData=flankerConverter(trialRecords,smallData);
                    case 'coherentDots'
                        % do nothing
                    otherwise
                        trialRecords(1).stimManagerClass
                        error('unknown Stim Format')
                end

                smallData=addRewardManager(trialRecords,smallData);

            case 'ifFeatureGoToSideWithTwoFlank'
                stimManagerClass='defunct';
                error ('need to update conversion to smallData from new trialManager-only method')
            otherwise
                trialManagerClass
                error ('convert large to small is not defined for that method yet')
                %consider calling a general converter here
        end

        if saveValveErrors
            valveErrors=inspectValveErrors(data,station,0)
            save(sprintf('%s/%s/%s/%s',dataStorageIP,dataStoragePath, char(subject),['valveErrorData.' datestr(sessionID,30) '.mat']), 'valveErrors')
        end
    else
        warning('this trialRecords is empty')
        smallData=[];
        numTrials=0;
        trialManagerClass={};
        stimManagerClass={};
    end
else
    error ('couldn''t find trialRecords in data')
end

%SHOULDN'T NEED THIS, this was used for multisession sorting
% %make sure sorted chronological
% [junk chonological]=sort(smallData.date);
% outFields=fields(smallData);
% numFields=size(outFields,1);
% for f=1:numFields
%     command=sprintf('smallData.%s=smallData.%s(chonological);',char(outFields(f)),char(outFields(f)));
%     %disp(command)
%     eval(command)
% end

%add non trial information
smallData.info.sessionIDs=sessionIDs;
smallData.info.subject={subject};
smallData.info.station=station;
smallData.info.trialManagerClass={trialManagerClass};
smallData.info.stimManagerClass={stimManagerClass};
%smallData.info.numTrials=size(smallData.date,2); %this is redundant info, just recompute

%save small data
if verbose
    disp(sprintf('saving smallData %s %s', datestr(sessionID,30),datestr(sessionID)))
end
pathAndName=fullfile(fullfile('\\',dataStorageIP,dataStoragePath, char(subject)),'smallData',['Data.' datestr(sessionID,30) '.mat']);
save(pathAndName, 'smallData');



function smallData=generalConverter(trialRecords)

curFields=fields(trialRecords);
numTrials=size(trialRecords,2);
preAllocationLength=numTrials;

%define variable names, locations and types
savedVariableNames=...
    {'containedManualPokes','.containedManualPokes','int8';...  % this field causes problems sometimes..why? - because its the first one in the list... all have probs.  why? dunno. problem fixed by doing a trial, consider rejecting last trial
    ...%probably its bc the field might contain the empty set, and the general converter fails... if it contained NaNs, this might not have happened...
    'correct','.correct','int8';...
    'msPenalty','.trialManager.trialManager.msPenalty','double';...
    'totalFrames','.responseDetails.totalFrames','uint32';...
    'startTime','.responseDetails.startTime','double';...
    'numMisses','.responseDetails.numMisses','uint32';...
    'expectedRewardIfRight','.trialManager.trialManager.rewardSizeULorMS', 'double';... %This doesn't update every trial like it should.  07/05/30 hopefully fixed 07/06/13 -pmm
    'step','.trainingStepNum', 'uint8'};
% the converter

%initialize fields
smallData=initializeFieldsForSmallData(struct(),savedVariableNames(:,1),savedVariableNames(:,2),trialRecords,preAllocationLength,savedVariableNames(:,3));

%specialCaseVariables={'date','response','responseTime','numRequestLicks','actualRewardDuration'}
smallData.date=zeros(1,preAllocationLength);
smallData.response=zeros(1,preAllocationLength,'uint8');
smallData.responseTime=zeros(1,preAllocationLength);
smallData.numRequestLicks=zeros(1,preAllocationLength,'uint8');
smallData.actualRewardDuration=zeros(1,preAllocationLength,'double');
%smallData.containedManualPokes=zeros(1,preAllocationLength,'double');

%SAVE LIST OF VARIABLES
smallData=setSmallDataFromListOfVariableNames(smallData,trialRecords,savedVariableNames);

%SAVE SPECIAL CASE VARIABLES
for i=1:numTrials
    trial=i;
    %response can be represented as one number
    r=find(trialRecords(i).response);
    if size(r,2)==1 %only one response
        smallData.response(trial)=r;
    else
        smallData.response(trial)=-1;
    end

    %date can be represented as one number
    smallData.date(trial)=datenum(trialRecords(i).date);

    %reponse details: responseTime, numRequestLicks
    temp=trialRecords(i).responseDetails;

    jhfhgf=-1;  %can't figure out why errors occur on cell2num only if using datacollection gui

    if any(strcmp(fields(temp),'times')) % if the field exists
        smallData.responseTime(trial)=temp.times{end};
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

    %removed 'containedManualPokes' from the general List of savedVariableNames -pmm 080102
    % There was a problem, b/c the field contained the empty set in records from long ago
    %for example: trial 269 in rat_116\largeData\Data.20070927T081849 which can be found with dateRange=[datenum('Sep.26,2007') datenum('Sep.30,2007')]
    % test: moved to specific converter where each trial is explicitly checked not to be empty
    %found that other fields were empty too..  like even the date!
    %the empty fields are a real problem, the file needs to be fixed or removed...see corruptFilleFixer.m
    %the strategy was to remove all trials that had no date.. this solved it

    %     confirm field exists -added pmm 0080102, removed same day
    %     if any(strcmp(curFields,'containedManualPokes'))
    %         Must check if empty.
    %         if ~isempty(trialRecords(i).containedManualPokes) % if the field is not empty!!
    %             smallData.containedManualPokes(trial)=trialRecords(i).containedManualPokes;
    %         else
    %             smallData.containedManualPokes(trial)=0;
    %         end
    %     else
    %         smallData.containedManualPokes(trial)=NaN;
    %     end

end

function smallData=flankerConverter(trialRecords,previousSmallData)
%this function lets adds stimulus specific information to the smallData
%if values are just single numbers add them to savedVariableNames
%if you want more complex structures special case them like in the general
%converter

%make sure the same number of trials exist in smallData and previousSmallData
%it is expected that the previous data started with the general converter
%which has the date fields
numTrials=size(trialRecords,2);
if length(previousSmallData.date)~= numTrials
    error ('every new field you add to the smallData with this method should preserve the number of trials for every field')
end

curFields=fields(trialRecords);
preAllocationLength=numTrials;

%define variable names, locations and types
savedVariableNames=...
    {'correctionTrial','.stimDetails.correctionTrial','int8';...
    'correctResponseIsLeft','.stimDetails.correctResponseIsLeft','int8';...
    'targetContrast','.stimDetails.targetContrast','double';...
    'targetOrientation','.stimDetails.targetOrientation','double';...
    'flankerContrast','.stimDetails.flankerContrast','double';...
    'flankerOrientation','.stimDetails.flankerOrientation(1)','double';... %need to deal with when there is more than 1 flanker!
    'deviation','.stimDetails.deviation','double';...
    'devPix','.stimDetails.devPix','double';...
    'targetPhase','.stimDetails.targetPhase','double';...
    'flankerPhase','.stimDetails.flankerPhase','double';...
    'currentShapedValue','.stimDetails.currentShapedValue','double';...
    'pixPerCycs','.stimDetails.pixPerCycs','double';...
    'redLUT','.stimDetails.LUT(end,1)','double';...
    'stdGaussMask','.stimDetails.stdGaussMask','double';...
    'maxCorrectForceSwitch','.stimDetails.maxCorrectForceSwitch','double'};
smallData=initializeFieldsForSmallData(struct(),savedVariableNames(:,1),savedVariableNames(:,2),trialRecords,preAllocationLength,savedVariableNames(:,3));

%SAVE LIST OF VARIABLES
smallData=setSmallDataFromListOfVariableNames(smallData,trialRecords,savedVariableNames);

%SAVE SPECIAL CASE VARIABLES
for trial=1:numTrials

    %should flanker orientation become a structure?
    %in which case remove it from the list above with
    %that hack call to only save the first one...
    %smallData.flankerOrientation{trial}=trialRecords(i).stimDetails.flankerOrientation;
    %must change flanker analysis code a bunch if so

    %or maybe a for loop that makes each flanker its own
    %variable - can't depends on a constant muber of
    %flankers need NaN's
end


%ADD PREVIOUS SMALL DATA TO SMALL DATA
f=fields(previousSmallData);
for i=1:length(f)
    command=sprintf('smallData.%s=previousSmallData.%s;',f{i},f{i});
    try
        eval(command)
    catch
        disp(command)
        error('bad command')
    end
end


function smallData=addRewardManager(trialRecords,smallData)


if any(strcmp(fields(trialRecords(end).trialManager.trialManager),reinforcementManager))
    rm=trialRecords(end).trialManager.trialManager.reinforcementManager;
    switch class(rm)
        case 'rewardNcorrectInARow'
            smallData.penalty=getPenalty(rm)*double(smallData.correct);
            smallData.rewardScalar=getScalar(rm)*ones(size(smallData.date));
        case 'struct'
            f=fields(trialRecords(1).trialManager.trialManager.reinforcementManager)
            if strcmp(f{1},'msRewardNthCorrect') | strcmp(f{1},'rewardNthCorrect')
                disp('guessing rewardNcorrectInARow because first field is msRewardNthCorrect or rewardNthCorrect');
                %old versions of rewardNcorrectInARow did not have a rewardScalar; effectively it was one
                %if other struct exists switch on
                p=trialRecords(1).trialManager.trialManager.reinforcementManager.msPenalty;
                smallData.penalty=p*double(smallData.correct);
                smallData.rewardScalar=1*ones(size(smallData.date));


            else
                error ('can''t retrieve information from that out of date rewardManager struct');
            end
        otherwise
            error ('can''t retrieve information from that rewardManager');
    end
else
    smallData.penalty=nan(size(smallData.date));
    smallData.rewardScalar=1*ones(size(smallData.date));
end





