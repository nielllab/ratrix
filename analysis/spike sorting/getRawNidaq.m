
function [data trialChunkStartStop]=getRawNidaq(subject,boundaryMethod,dataFormat,physDataPath,rawNidaqPath,confirmItMatchesNeuralRecords,doPlot)
%data=getRawNidaq('138',[129 131],'all',[],[],true,true);
% where trialChunkStartStop=[trialNum chunkNum startTimeSec stopTimeSec]

if ~exist('subject','var') || isempty(subject)
    subject='138';
end

if ~exist('boundaryMethod','var') || isempty(boundaryMethod)
    boundaryMethod=[1 3];  % trials 1 to 3
end

if ~exist('physDataPath','var') || isempty(physDataPath)
    physDataPath='\\132.239.158.179\datanet_storage';
end

if ~exist('rawNidaqPath','var') || isempty(rawNidaqPath)
    rawNidaqPath='\\132.239.158.179\pmeier\trunk\bootstrap\data';
end

if ~exist('confirmItMatchesNeuralRecords','var') || isempty(confirmItMatchesNeuralRecords)
    confirmItMatchesNeuralRecords=false;
end

if ~exist('dataFormat','var') || isempty(dataFormat)
    dataFormat='all';  % all,iti, trial, iti&trial
end

if ~exist('doPlot','var') || isempty(doPlot)
    doPlot=true;
end

if iscell(boundaryMethod)
    params=boundaryMethod(2:end);
    boundaryMethod=boundaryMethod{1};
    switch boundaryMethod
        case 'trialRange'
            trialRange=params{1};
        otherwise
            error('bad methd')
    end
elseif isnumeric(boundaryMethod) && length(boundaryMethod)==2 && boundaryMethod(1)<=boundaryMethod(2)
    trialRange=boundaryMethod;
    boundaryMethod='trialRange';
else
    boundaryMethod
    error('trialRangeOrBoundaryMethod must be a start stop trial or a cell of method and args')
end

%% get start dates for all the valid raw nidaq files
d=dir(rawNidaqPath);
rawFileNames={};
rawStartDates=[];
for i=1:length(d)
    [matches tokens] = regexpi(d(i).name, 'data.(\d+)T(\d+).daq', 'match', 'tokens');
    if length(matches)==0
        continue
    else
        if length(matches{1}) == length(d(i).name)
            rawFileNames{end+1}=d(i).name;
            rawStartDates(end+1)=datenumFor30([tokens{1}{1} 'T' tokens{1}{2}]);
        else
            matches{1}
            error('unexpected match')
        end
    end
end

%enforce chronological
[rawStartDates inds]=sort(rawStartDates);
rawFileNames=rawFileNames(inds);

%% get the neural data dates for all trials


neuralDataPath=fullfile(physDataPath,subject,'neuralRecords');
d=dir(neuralDataPath);

perTrialFileNames={};
perTrialStartDates=[];
trialsWithNeuralRecords=[];
for i=1:length(d)
    [matches tokens] = regexpi(d(i).name, 'neuralRecords_(\d+)-(\d+)T(\d+).mat', 'match', 'tokens');
    if length(matches)==0
        continue
    else
        if length(matches{1}) == length(d(i).name)
            perTrialFileNames{end+1}=d(i).name;
            trialsWithNeuralRecords(end+1)=str2num(tokens{1}{1});
            perTrialStartDates(end+1)=dateNumFor30([tokens{1}{2} 'T' tokens{1}{3}]);
        else
            matches{1}
            error('unexpected match')
        end
    end
end

%enforce chronological
[trialsWithNeuralRecords inds]=sort(trialsWithNeuralRecords);
perTrialFileNames=perTrialFileNames(inds);
perTrialStartDates=perTrialStartDates(inds);
if any(diff(perTrialStartDates)<=0)
    error('all trial numbers expected to increase... you have nonchronological trial numbers!')
end


%% find the date right before the first and last trial requested

trialStartID=find(trialsWithNeuralRecords==trialRange(1));  % not the same as the trial number, but an index into the list of available trials with neural
trialEndID=find(trialsWithNeuralRecords==trialRange(2));

timeRawBeforeTrial=perTrialStartDates(trialStartID)-rawStartDates;
timeRawBeforeTrial(timeRawBeforeTrial<0)=inf;  %never select positive values
startRawID=find(min(abs(timeRawBeforeTrial))==abs(timeRawBeforeTrial));

timeRawBeforeTrial=perTrialStartDates(trialEndID)-rawStartDates;
timeRawBeforeTrial(timeRawBeforeTrial<0)=inf;  %never select positive values
endRawID=find(min(abs(timeRawBeforeTrial))==abs(timeRawBeforeTrial));

if startRawID~=endRawID
    % this method is not expected to work across nidaq sessions
    error(sprintf('first trial (%d) belongs to %s, and the last trial (%d) belongs to a different raw nidaq file: %s',trialRange(1),rawFileNames{startRawID},trialRange(2),rawFileNames{endRawID}))
end

%% calculate the samples to get from the neural records

firstTrialFirstChunk=load(fullfile(neuralDataPath,perTrialFileNames{trialStartID}),'chunk1');
firstTrialFirstChunk=firstTrialFirstChunk.chunk1;
overAllStart=firstTrialFirstChunk.neuralDataTimes(1); %in seconds

lastTrial=load(fullfile(neuralDataPath,perTrialFileNames{trialEndID}));  %could 'whos' to get the name, which is oldy slower remotely

%%
chunkNames=fields(lastTrial);
chunkN=[];
for i=1:length(chunkNames)
    [matches tokens] = regexpi(chunkNames{i}, 'chunk(\d+)', 'match', 'tokens');
    if length(matches) ~= 1
        continue;
    else
        chunkN(end+1) = str2double(tokens{1}{1});
    end
end
lastTrialLastChunk=lastTrial.(['chunk' num2str(max(chunkN))])
overAllEnd=lastTrialLastChunk.neuralDataTimes(2);
%% get the raw data

fprintf('doing the DAQ read... could take a while, esp remotely');  tic
switch dataFormat
    case 'quickTest'
        data = daqread(fullfile( rawNidaqPath,rawFileNames{startRawID}),'Samples',[500 1000]);
    case 'all'
        fprintf('\nreading %2.2g seconds of data',overAllEnd-overAllStart);
        [data, time, abstime, events, daqInfo] = daqread(fullfile( rawNidaqPath,rawFileNames{startRawID}),'Time',[overAllStart overAllEnd]);
    case 'iti'
        error('not yet')
    case 'trial'
        error('not yet')
    case 'iti&trial'
        error('not yet')
    otherwise
        dataFormat
        error('bad type of dataFormat')
end
fprintf('%2.2g seconds',toc)

%% compare the first chunk

pass=all(all(firstTrialFirstChunk.neuralData==data(1:length(firstTrialFirstChunk.neuralData),:)));
if ~pass
    error('some of the data in the raw file is different from the first chunk!')
else
    fprintf('all %d samples in the first chunk match those of the raw data file',length(firstTrialFirstChunk.neuralData))
end

%%

if nargout>1 || doPlot
    trials=trialRange(1):trialRange(2);
    trialChunkStartStop=nan(length(trials),4);
    %trialChunkStartStop=[trialNum chunkNum start stop]
    
    count=0;
    for i=length(trials)
        
        numChunks=1
        
        for j=1:numChunks
            count=count+1;
            start=2
            stop=3
            trialChunkStartStop(count,:)=[i j start stop]
        end
    end
end

if doPlot
    figure
    plot(data); hold on
    for i=1:size(trialChunkStartStop,1)
        plot(trialChunkStartStop([3 4]),trialChunkStartStop([2 2]),'k');  
    end
end

