function quit = analysisManagerByChunk(subjectID, path, cellBoundary,channelsAnalyzed,spikeDetectionParams, spikeSortingParams,...
    timeRangePerTrialSecs,stimClassToAnalyze,overwriteAll,usePhotoDiodeSpikes,plottingParams,frameThresholds)
% 4/14/09 - for now, lets assume this function only processes a single trial
%	- one neuralRecords.mat file, with many chunks
%	- one stimRecords.mat file, specific to this trial
% tie this in with the old analysisManager that loops through trials!
%
% INPUTS:
%	subjectID - the subject to analyze
%	path - the path where neuralRecords are stored
%	cellBoundary - specifies which trials/chunks to analyze
%       eg: {'trialRange',[1 5]} means all chunks in trials 1-5
%       {'trialAndChunkRange',{[1 3], [4 6]}} means from trial 1, chunk 3 to trial 4, chunk 6 inclusive
%       {'physLog',{'04.21.2009','events','all','first'}} means get the cell boundaries from the phys log for 4/21/09 (and use the first cell)
%       {'physLog',{'04.21.2009','events',[4 200],'last'}} means get the last cell from 4/21/09 within events 4-200 (of that day)
%       {'physLog',{'04.21.2009','labels',5}) means the events (trials) defined by label 5 for the phys log from 4/21/09

%   channelsAnalyzed - a list of the channels that are grouped to find a single (spike waveform) event;
%      example: a stereotrode on channels 2 and 3, and a single channel on 8 would be {[2 3],[8]}
%      default: only analyzed the first of n channels: {[1]}
%	spikeDetectionParams - these should now be from the 'activeParameters'
%	spikeSortingParams - these should now be from the 'activeParameters'
%	timeRangePerTrialSecs - to analyze a fraction of a trial, fast but some anaylses may fail
%	stimClassToAnalyze - test that the trial is of this stimClass
%	overwriteAll - whether or not to overwrite existing analyses
%	usePhotoDiodeSpikes - flag to determine whether photoDiode or neuralRecording
%   plottingParams - sets what to plot and what not to plot
% OUTPUTS:
%	quit - a stop flag?
%	NOTE: this process creates a spikeRecord and physAnalysis file
%
% NOTE: for now, this processes a single trial, one chunk at a time. next step is to make this process chunk by chunk, but across trials
%	(at cell boundaries).

if ~exist('subjectID','var') || isempty(subjectID)
    subjectID = 'demo1'; %
end

if ~exist('path','var') || isempty(path)
    % path = '\\Reinagel-lab.AD.ucsd.edu\RLAB\Rodent-Data\Fan\datanet' % OLD
    path = '\\132.239.158.179\datanet_storage\';
end

% needed for physLog boundaryType
neuralRecordsPath = fullfile(path, subjectID, 'neuralRecords');
if ~isdir(neuralRecordsPath)
    neuralRecordsPath
    error('unable to find directory to neuralRecords');
end

if ~exist('cellBoundary','var') || isempty(cellBoundary)
    error('cellBoundary must be a valid input argument - default value is too dangerous here!');
elseif iscell(cellBoundary) && length(cellBoundary)==2
    boundaryType = cellBoundary{1};
    switch boundaryType
        case 'trialRange'
            if any(~isnumeric(cellBoundary{2}))
                error('invalid parameters for trialRange cellBoundary');
            end
            switch length(cellBoundary{2})
                case 2
                    %okay, thats normal
                case 1
                    %start trial is the stop trial
                    cellBoundary{2}=[cellBoundary{2} cellBoundary{2}];
                otherwise
                    error('must be length 2 for [start stop] or a single trial number')
            end
            boundaryRange=[cellBoundary{2}(1) 1 cellBoundary{2}(2) Inf]; % [startTrial startChunk endTrial endChunk]
        case 'trialAndChunkRange'
            if ~iscell(cellBoundary{2}) || length(cellBoundary{2})~=2 || length(cellBoundary{2}{1})~=2 || length(cellBoundary{2}{2})~=2
                error('trialAndChunkRange cellBoundary must be in format {''trialAndChunkRange'',{[startTrial startChunk], [endTrial endChunk]}}');
            end
            boundaryRange=[cellBoundary{2}{1}(1) cellBoundary{2}{1}(2) cellBoundary{2}{2}(1) cellBoundary{2}{2}(2)]; % [startTrial startChunk endTrial endChunk]
        case 'physLog'
            boundaryRange = getCellBoundaryFromEventLog(subjectID,cellBoundary{2},neuralRecordsPath);
            startSysTime=boundaryRange(3);
            endSysTime=boundaryRange(6);
            boundaryRange=boundaryRange([1 2 4 5]);
        otherwise
            error('bad type of cellBoundary!');
    end
    maskType = 'none';
    maskON = false;
    maskRange = [];
elseif iscell(cellBoundary) && length(cellBoundary)==4
    boundaryType = cellBoundary{1};
    switch boundaryType
        case 'trialRange'
            if any(~isnumeric(cellBoundary{2}))
                error('invalid parameters for trialRange cellBoundary');
            end
            switch length(cellBoundary{2})
                case 2
                    %okay, thats normal
                case 1
                    %start trial is the stop trial
                    cellBoundary{2}=[cellBoundary{2} cellBoundary{2}];
                otherwise
                    error('must be length 2 for [start stop] or a single trial number')
            end
            boundaryRange=[cellBoundary{2}(1) 1 cellBoundary{2}(2) Inf]; % [startTrial startChunk endTrial endChunk]
        case 'trialAndChunkRange'
            if ~iscell(cellBoundary{2}) || length(cellBoundary{2})~=2 || length(cellBoundary{2}{1})~=2 || length(cellBoundary{2}{2})~=2
                error('trialAndChunkRange cellBoundary must be in format {''trialAndChunkRange'',{[startTrial startChunk], [endTrial endChunk]}}');
            end
            boundaryRange=[cellBoundary{2}{1}(1) cellBoundary{2}{1}(2) cellBoundary{2}{2}(1) cellBoundary{2}{2}(2)]; % [startTrial startChunk endTrial endChunk]
        case 'physLog'
            boundaryRange = getCellBoundaryFromEventLog(subjectID,cellBoundary{2},neuralRecordsPath);
            startSysTime=boundaryRange(3);
            endSysTime=boundaryRange(6);
            boundaryRange=boundaryRange([1 2 4 5]);
        otherwise
            error('bad type of cellBoundary!');
    end
    maskType = cellBoundary{3};
    switch maskType
        case 'trialMask'
            if any(~isnumeric(cellBoundary{4}))
                error('invalid parameters for maskRange');
            end
            maskRange = cellBoundary{4};
        otherwise
            error('mask type is not supported');
    end
    maskON = true;
else
    error('bad cellBoundary input');
end

if ~exist('channelsAnalyzed','var') || isempty(channelsAnalyzed)
    channelsAnalyzed={[1]}; % default only look at first phys channel
else
    %error check
    if ~(iscell(channelsAnalyzed))
        error('must be a cell of groups of channels');
    else
        if ~all(size(channelsAnalyzed)==[1 1])
            channelsAnalyzed
            error('haven''t handled analysis of multiple groups yet')
        end
        
        if ~all(size(channelsAnalyzed{1})==[1 1])
            channelsAnalyzed
            error('haven''t handled analysis of multiple channels per group yet')
        end
        
    end
end

activeParamFile = fullfile('\\132.239.158.179\datanet_storage\',subjectID,'activeSortingParams.mat');
if ~exist('spikeDetectionParams','var') || isempty(spikeDetectionParams)
    spikeDetectionParams.method='oSort';
    spikeDetectionParams.ISIviolationMS=2;
elseif strcmp(spikeDetectionParams.method,'activeSortingParameters')
    % get spikeDetectionParams from activeSortingParameters.mat
    spikeDetectionParams=load(activeParamFile,'spikeDetectionParams');
elseif strcmp(spikeDetectionParams.method,'activeSortingParametersThisAnalysis')
    %will load below
end

if ~exist('spikeSortingParams','var') || isempty(spikeSortingParams)
    spikeSortingParams.method='oSort';
elseif strcmp(spikeSortingParams.method,'activeSortingParameters')
    % get spikeSortingParams from activeSortingParameters.mat
    spikeSortingParams=load(activeParamFile,'spikeSortingParams');
end

if ~exist('timeRangePerTrialSecs','var') || isempty(timeRangePerTrialSecs)
    timeRangePerTrialSecs = [0 Inf]; %all
else
    if timeRangePerTrialSecs(1)~=0
        error('frame pulse detection has not been validated if you do not start at time=0')
        %do we throw out the first pulse?
    end
    if timeRangePerTrialSecs(2)<3
        requestedEndDuration= timeRangePerTrialSecs(2)
        error('frame pulse detection has not been validated if you do not have at least some pulses')
        %do we throw out the first pulse?
    end
end

if ~exist('stimClassToAnalyze','var') || isempty(stimClassToAnalyze)
    stimClassToAnalyze='all';
else
    if ~(iscell(stimClassToAnalyze) ) % and they are all chars
        stimClassToAnalyze
        error('must be a cell of chars of SM classes or ''all'' ')
    end
end

if ~exist('usePhotoDiodeSpikes','var') || isempty(usePhotoDiodeSpikes)
    usePhotoDiodeSpikes=false;
end

if ~exist('overwriteAll','var') || isempty(overwriteAll)
    overwriteAll=false;
end


if ~exist('plottingParams','var') || isempty(plottingParams)
    plottingParams.showSpikeAnalysis = true;
    plottingParams.showLFPAnalysis = true;
    plottingParams.plotSortingForTesting = true;
end

if ~exist('frameThresholds','var') || isempty(frameThresholds)
    frameThresholds.dropBound = 1.5;   %smallest fractional length of ifi that will cause the long tail to be called a drop(s)
    frameThresholds.warningBound = 0.1; %fractional difference that will cause a warning, (after drop adjusting)
    frameThresholds.errorBound = 0.5;   %fractional difference of ifi that will cause an error (after drop adjusting)
    frameThresholds.dropsAcceptableFirstNFrames=2; % first 2 frames won't kill the default quality test               
end

% ==========================================================================================

% some counters
quit = false;
doneWithThisTrial=false;
haveDeletedAnalysisRecords=false;
result=[];

%=========================================================================
% SETS UP THE PLOTTING CHARACTERISTICS OF THE ANALYSIS
plotParameters.doPlot=false;
% plotParameters.handle=figure; % some random extra window that opens up.
% annoying!!
plottingParamsFieldNames = fieldnames(plottingParams);
for currFieldNum = 1:length(plottingParamsFieldNames)
    plotParameters.(plottingParamsFieldNames{currFieldNum}) = plottingParams.(plottingParamsFieldNames{currFieldNum});
end

if ~isfield(spikeSortingParams,'plotSortingForTesting')
    if isfield(plotParameters,'plotSortingForTesting')
        spikeSortingParams.plotSortingForTesting = plotParameters.plotSortingForTesting;
    else
        spikeSortingParams.plotSortingForTesting = true;
    end
end

% END OF PLOTTING CHARACTERISTICS SETUP
%=========================================================================

% use boundaryRange to know where our cell is
currentTrial=boundaryRange(1);

processedChunks=[];
chunksToProcess=[];
cumulativedata=[];
lastStimManagerClass=[];
perChunkFilter=[];
numTriesWithNothing=1;

%SETUP: determine record paths (may need to mkdir) ... could be a function
stimRecordsPath = fullfile(path, subjectID, 'stimRecords');
if ~isdir(stimRecordsPath)
    mkdir(stimRecordsPath);
end
eyeRecordPath = fullfile(path, subjectID, 'eyeRecords');
if ~isdir(eyeRecordPath)
    mkdir(eyeRecordPath);
end
baseAnalysisPath = fullfile(path, subjectID, 'analysis',sprintf('%d-%d',boundaryRange(1),boundaryRange(3)));
if ~isdir(baseAnalysisPath)
    mkdir(baseAnalysisPath);
end

% 6/22/09 - should also save activeSortingParameters to a file in the base analysis location!
if strcmp(spikeDetectionParams.method,'activeSortingParametersThisAnalysis')
    spikeDetectionParams=load(fullfile(baseAnalysisPath,'activeSortingParams.mat'),'spikeDetectionParams');
    spikeSortingParams=load(fullfile(baseAnalysisPath,'activeSortingParams.mat'),'spikeSortingParams');
else
    save(fullfile(baseAnalysisPath,'activeSortingParams.mat'),'spikeDetectionParams','spikeSortingParams');
end
% ==========================================================================================
maskedPrevTrial = false;
while ~quit
    % THIS IS START OF THE LOOP FOR EACH CURRENTTRIAL
    doneWithThisTrial=false;
    currentChunkBoundary=[1 Inf]; % the chunk boundaries for the current trial
    if currentTrial==boundaryRange(1)
        currentChunkBoundary(1)=boundaryRange(2);
    end
    if currentTrial==boundaryRange(3)
        currentChunkBoundary(2)=boundaryRange(4);
    end
    
    % look for currentTrial's neuralRecord
    dirStr=fullfile(neuralRecordsPath,sprintf('neuralRecords_%d-*.mat',currentTrial));
    d=dir(dirStr);
    if length(d)==1
        neuralRecordFilename=d(1).name;
        % get the timestamp
        [matches tokens] = regexpi(d(1).name, 'neuralRecords_(\d+)-(.*)\.mat', 'match', 'tokens');
        if length(matches) ~= 1
            %         warning('not a neuralRecord file name');
        else
            timestamp = tokens{1}{2};
            currentTrialStartTime=datenumFor30(timestamp);
        end
    else
        disp('didnt find anything in d');
        currentTrial=min(currentTrial+1,boundaryRange(3));
        continue;
    end
    
    % setup filenames and paths -- could be a function...
    stimRecordLocation = fullfile(stimRecordsPath,sprintf('stimRecords_%d-%s.mat',currentTrial,timestamp));
    neuralRecordLocation = fullfile(neuralRecordsPath,sprintf('neuralRecords_%d-%s.mat',currentTrial,timestamp));
    analysisPath = fullfile(baseAnalysisPath,sprintf('%d-%s',currentTrial,timestamp));
    
    
    if exist(baseAnalysisPath,'dir')  & ~haveDeletedAnalysisRecords
        if overwriteAll
            
            % the first time we get here we delete the whole
            % folder and all the previous analysis, as we want to
            % overwrite ALL.  If we don't do this, we will store
            % muliple cumulative copies of each spike
            %(for every time the extraction/clustering is re-run)
            
            %delete the existing sub-directory for all the records with
            %this exact trial range (ie. the folder '31-35' but not the folder '32-32' which is its own redundant repository)
            [succ,msg,msgID] = rmdir(baseAnalysisPath,'s');  % includes all subdirectory regardless of permissions
            
            if ~succ
                msg
                error('failed to remove existing files when running with ''overwriteAll=true''')
            else
                haveDeletedAnalysisRecords=true;
            end
        else
            disp('the analysis is already there, and we are not resorting any of the spikes')
            disp('displaying the cumulative analysis of the last trial')
            
            %find the timestamp of the last trial in this analysis
            lastTrial=boundaryRange(3);
            d=dir(baseAnalysisPath);
            lastTrialTimestamp=[];
            for i=1:length(d)
                [matches tokens] = regexpi(d(i).name, sprintf('%d-(.*)',lastTrial), 'match', 'tokens'); %'(\d+)-(.*)'
                if length(matches) == 1
                    lastTrialTimestamp = tokens{1}{1};
                    break
                end
            end
            
            %determine the location and filename
            if ~isempty(lastTrialTimestamp)
                lastTrialAnalysisLocation = fullfile(baseAnalysisPath,matches{1},sprintf('physAnalysis_%d-%s.mat',lastTrial,lastTrialTimestamp));
            else
                error('some analysis exist, but the cumulative analysis of the last trial does not... rerun with overwriteall=true')
                %partially completed analysis can't use this... must
                %have finished successfully to be able to turn off overwriteall
            end
            
            %get the cumulative data
            out=stochasticLoad(lastTrialAnalysisLocation,{'cumulativedata'});
            cumulativedata=out.cumulativedata;
            
            %get the stim manager class of the last trial
            lastStimRecordLocation = fullfile(stimRecordsPath,sprintf('stimRecords_%d-%s.mat',lastTrial,lastTrialTimestamp));
            lastStimRecord=stochasticLoad(stimRecordLocation,{'stimManagerClass'});
            evalStr = sprintf('sm = %s();',lastStimRecord.stimManagerClass);
            eval(evalStr);
            
            figure;  displayCumulativePhysAnalysis(sm,cumulativedata);
            return
        end
    end
    
    if ~isdir(analysisPath)
        mkdir(analysisPath);
    end
    
    %     spikeRecordLocation = fullfile(baseAnalysisPath,sprintf('spikeRecords_%d-%s.mat',currentTrial,timestamp));
    spikeRecordLocation=fullfile(baseAnalysisPath,'spikeRecords.mat'); % HACK FOR NOW - per cell // per analysis range spikeRecord
    analysisLocation = fullfile(analysisPath,sprintf('physAnalysis_%d-%s.mat',currentTrial,timestamp));
    
    % check the stimRecord for stimManagerClass (and other stuff?)
    stimRecord=stochasticLoad(stimRecordLocation,{'stimManagerClass','refreshRate'});
    stimManagerClass=stimRecord.stimManagerClass;
    
    % trialMasking logical
    maskThisTrial = false;
    if strcmp(maskType,'trialMask')
        if  any(maskRange==currentTrial)
            maskThisTrial = true;
        end
    end
    
    if isempty(lastStimManagerClass)
        lastStimManagerClass=stimManagerClass;
    elseif ~strcmp(lastStimManagerClass,stimManagerClass)&& ~maskThisTrial
        % if last trial was diff stim, then reset cumulativedata
        % - should fix to not just ~strcmp(trialManagerClasses), but a function diff on the stimManager
        cumulativedata=[];
    end
    analyzeThisTrial= all(strcmp('all',stimClassToAnalyze)) ||  any(strcmp(stimRecord.stimManagerClass,stimClassToAnalyze));
    
    if analyzeThisTrial
        while ~doneWithThisTrial && ~maskThisTrial
            % look at the neuralRecord and see if there are any new chunks to process
            disp('checking chunk names... may be slow remotely...'); tic;
            chunkNames=who('-file',neuralRecordLocation);
            fprintf(' %2.2f seconds',toc)
            chunksToProcess=[];
            for i=1:length(chunkNames)
                [matches tokens] = regexpi(chunkNames{i}, 'chunk(\d+)', 'match', 'tokens');
                if length(matches) ~= 1
                    continue;
                else
                    chunkN = str2double(tokens{1}{1});
                end
                if ~isempty(processedChunks) && ~isempty(find(processedChunks(:,2)==chunkN&processedChunks(:,1)==currentTrial))
                    % already processed - pass
                elseif chunkN>=currentChunkBoundary(1) && chunkN<=currentChunkBoundary(2)
                    chunksToProcess=[chunksToProcess; currentTrial chunkN];
                end
            end
            % if no more chunks to process in currentTrial, then check for a new trial within boundaryRange
            if isempty(chunksToProcess)
                if numTriesWithNothing>=3
                    quit=true;
                    return;
                    % HACK FOR NOW - stop looping so matlab doesnt freeze
                end
                newTrial=min(currentTrial+1,boundaryRange(3));
                dirStr=fullfile(neuralRecordsPath,sprintf('neuralRecords_%d-*.mat',newTrial));
                d=dir(dirStr);
                if length(d)==1 % there is a new trial neuralRecord
                    fprintf('**** ADVANCING TO TRIAL %d (try number %d)*****\n',newTrial,numTriesWithNothing);
                    
                    
                    
                    %WaitSecs(8);
                    currentTrial=newTrial;
                    doneWithThisTrial=true;
                else
                    disp('****** NO CHUNKS LEFT ON TRIAL %d, BUT NO NEW TRIAL YET ******',currentTrial);
                    WaitSecs(2);
                end
                numTriesWithNothing=numTriesWithNothing+1;
            else
                numTriesWithNothing=1;
            end
            
            %SORT chunks to processing (they may be alphanumeric, we want by chunk number)
            chunksToProcess=sort(chunksToProcess,1);
            snippet=[]; snippetTimes=[];
            %disp('*********CHUNKS TO PROCESS*************')
            %currentTrial
            %chunksToProcess
            
            WaitSecs(.1); %slow down: gives cpu time, also allows stim to get saved
            % =================================================================================
            
            for currentChunkInd=1:size(chunksToProcess,1)
                try
                    % =================================================================================
                    chunkStr=sprintf('chunk%d',chunksToProcess(currentChunkInd,2));
                    fprintf('*********DOING %s*************\n',chunkStr)
                    if currentChunkInd==size(chunksToProcess,1)
                        isLastChunkInTrial=true;  % warning: this could be tripped by online analysis if you analyze an ongoing trial
                        %the reult would be that some stimManagers would
                        %get stimuli that are reported to be "the last of
                        %the trial, but the stim manager can not trust to be full, b/c they are partial trials
                        %...
                        %could also be tripped by requesting to analysis
                        %part of a chunk in the analysis range... in which
                        %case thats what we want
                    else
                        isLastChunkInTrial=false;
                    end
                    %chunksToProcess(currentChunkInd,2)
                    
                    processed=false;
                    if exist(spikeRecordLocation,'file') % if a spikeRecord already exists for this cell, check that this chunk hasn't been processed
                        p=stochasticLoad(spikeRecordLocation,{'chunkID','trialNum'});
                        if any(find(p.chunkID==chunksToProcess(currentChunkInd,2)&p.trialNum==chunksToProcess(currentChunkInd,1)))
                            processed=true;
                        end
                    end
                    
                    
                    neuralRecord=stochasticLoad(neuralRecordLocation,{chunkStr,'samplingRate'});
                    temp=neuralRecord.samplingRate;
                    neuralRecord=neuralRecord.(chunkStr);
                    neuralRecord.samplingRate=temp;
                    % reconstitute neuralDataTimes from start/end based on samplingRate
                    %neuralRecord.neuralDataTimes=[neuralRecord.neuralDataTimes(1):(1/neuralRecord.samplingRate):neuralRecord.neuralDataTimes(end)]'; % would prefer this old way to work, but it can return the wrnog number of samples (ie. one to few out of 1,234,944)
                    neuralRecord.neuralDataTimes=linspace(neuralRecord.neuralDataTimes(1),neuralRecord.neuralDataTimes(end),size(neuralRecord.neuralData,1))';
                    if any(abs(((unique(diff(neuralRecord.neuralDataTimes))-(1/neuralRecord.samplingRate))/(1/neuralRecord.samplingRate)))>10^-7)
                        samplingRateInterval=(1/neuralRecord.samplingRate)
                        foundSamplesSpaces=unique(diff(neuralRecord.neuralDataTimes))
                        %this is a check to make sure that the sampling
                        %calte we calculate is very darn close to the
                        %sampling rate we were told it was.
                        error('error on the length of one of the frames lengths was more than 1/ ten millionth')
                    end
                    
                    %check channel configuration is good for requestedAnalysis
                    if ~isfield(neuralRecord,'ai_parameters')
                        neuralRecord.ai_parameters.channelConfiguration={'framePulse','photodiode','phys1'};
                        if size(neuralRecord.neuralData,2)~=3
                            error('only expect old unlabeled data with 3 channels total... check assumptions')
                        end
                    end
                    %physChannelInds=~cellfun(@(x) isempty(x),strfind(neuralRecord.ai_parameters.channelConfiguration,'phys'));
                    %temp=cellfun(@(x) str2num(x(5:end)),neuralRecord.ai_parameters.channelConfiguration(physChannelInds),'UniformOutput',false)
                    %chansAvailable=unique([temp{:}]);
                    chansRequired=unique([channelsAnalyzed{:}]);
                    for c=1:length(chansRequired)
                        chansRequiredLabel{c}=['phys' num2str(chansRequired(c))];
                    end
                    
                    if any(~ismember(chansRequiredLabel,neuralRecord.ai_parameters.channelConfiguration))
                        chansRequiredLabel
                        neuralRecord.ai_parameters.channelConfiguration
                        error(sprintf('requested analysis on channels %s but thats not available',char(setdiff(chansRequiredLabel,neuralRecord.ai_parameters.channelConfiguration))))
                    end
                    
                    
                    %only analyze some channels
                    for c=1:length(channelsAnalyzed{1})
                        thesePhysChannelLabels{c}=['phys' num2str(channelsAnalyzed{1}(c))];
                    end
                    thesePhysChannelInds=find(ismember(neuralRecord.ai_parameters.channelConfiguration,thesePhysChannelLabels));
                    photoInd=find(strcmp(neuralRecord.ai_parameters.channelConfiguration,'photodiode'));
                    pulseInd=find(strcmp(neuralRecord.ai_parameters.channelConfiguration,'framePulse'));
                    
                    
                    
                    
                    % do optional filtering on this chunk (a mask, or maybe cut off some of the beginning/end)
                    %                         neuralRecord=applyChunkFilter(neuralRecord,currentTrialStartTime,[startSysTime endSysTime]);
                    % has neuralData, neuralDataTimes, samplingRate, activeParameters, matlabTimeStamp, firstNeuralDataTime
                    
                    %timeRangePerTrialSamps=timeRangePerTrialSecs*samplingRate; % not needed, but might be faster ;
                    %eben better is if we could load "part" of a matlab variable (specified inds) at a faster speeds.
                    % probably can't b/c matlab compression
                    
                    
                    %combine previous neuralData with (the snippet after the last frame, plus 1/2 frame before)
                    
                    
                    
                    
                    % avoid making big variables to filter the data if you can...
                    if timeRangePerTrialSecs(1)==0 & timeRangePerTrialSecs(2)> diff(neuralRecord.neuralDataTimes([1 end]))% use all
                        % do nothing, b/c using all
                    else %filter
                        timeSinceTrialStart=neuralRecord.neuralDataTimes-neuralRecord.neuralDataTimes(1);
                        withinTimeRange=timeSinceTrialStart>=timeRangePerTrialSecs(1) & timeSinceTrialStart<=timeRangePerTrialSecs(2);
                        neuralRecord.neuralData=neuralRecord.neuralData(withinTimeRange,:);
                        neuralRecord.neuralDataTimes=neuralRecord.neuralDataTimes(withinTimeRange);
                    end
                    if ~processed || overwriteAll
                        % get frameIndices and frameTimes (from screen pulses)
                        % bounds to decide whether or not to continue with analysis
                        ifi = 1/stimRecord.refreshRate;  % why don't we get this from stimulus? -pmm 091027 // done pmm 100111
                        spikeRecord.spikeDetails=[];
                        spikeRecord.samplingRate=neuralRecord.samplingRate;
                        % what is the difference between frameIndices and correctedFrameIndices?
                        % we pass correctedFrameIndices to spikeData, which is what physAnalysis sees, but
                        % we don't tell the getSpikesFromNeuralData function anything about dropped frames?
                        
                        % add snippet
                        
                        
                        neuralRecord.preModifiedStartStopTimes=neuralRecord.neuralDataTimes([1 end]); %keep a record of start stop before the modifications
                        if ~isempty(snippet)
                            %this is the data after the last flip (+ a few few sample indices for padding)
                            %if we do not do this, analysis will "drop" (fail to find) a frame between chunks
                            %the neural data is MOVED to the next chunk
                            neuralRecord.neuralData=[snippet; neuralRecord.neuralData ];
                            neuralRecord.neuralDataTimes=[snippetTimes; neuralRecord.neuralDataTimes];
                        end
                        
                        [spikeRecord.frameIndices spikeRecord.frameTimes spikeRecord.frameLengths spikeRecord.correctedFrameIndices...
                            spikeRecord.correctedFrameTimes spikeRecord.correctedFrameLengths spikeRecord.stimInds ...
                            spikeRecord.passedQualityTest] = ...
                            getFrameTimes(neuralRecord.neuralData(:,pulseInd),neuralRecord.neuralDataTimes,neuralRecord.samplingRate,...
                            frameThresholds.dropBound, frameThresholds.warningBound, frameThresholds.errorBound,ifi, frameThresholds.dropsAcceptableFirstNFrames); % pass in the pulse channel
                        
                        
                        % 01/11/10 - save the snippet for next chunk
                        if ~isempty(spikeRecord.correctedFrameIndices)
                            numPaddedSamples=2; % in each dirrection
                            lastSampleKept=spikeRecord.correctedFrameIndices(end); % these are still relative to the chenk, and so can index neural data
                            snippet=neuralRecord.neuralData(lastSampleKept-numPaddedSamples-1:end,:); %same the snippet after the last frame
                            snippetTimes=neuralRecord.neuralDataTimes(lastSampleKept-numPaddedSamples-1:end,:);
                            neuralRecord.neuralData=neuralRecord.neuralData(1:lastSampleKept,:); %remove snippet after the late frame
                            neuralRecord.neuralDataTimes=neuralRecord.neuralDataTimes(1:lastSampleKept,:); %remove snippet after the late frame
                        else
                            %if no frames found
                            %probably the last chunk, in which case go to the next trial,
                            %but if not the last chunk error
                            if currentChunkInd==size(chunksToProcess,1)
                                warning(sprintf('no frames found on the last chunk (%d) of trial %d...skipping to next trial',chunksToProcess(currentChunkInd,2),chunksToProcess(currentChunkInd,1)));
                                doneWithThisTrial=true;
                                if currentTrial+1>boundaryRange(3)
                                    quit=true;
                                else
                                    currentTrial=currentTrial+1;
                                end
                               
                                %option to do analysis in this odd location, that happens sometimes
                                doAnalysis=worthPhysAnalysis(sm,quality,analysisExists,overwriteAll,isLastChunkInTrial); %doAnalysis = isLastChunkInTrial;
                                if doAnalysis
                                    filteredSpikeRecord=getCurrentTrialSpikeRecords(currentTrial,trialNum,trialNumForCorrectedFrames,trialNumForDetails,...
                                        spikes,spikeTimestamps,spikeWaveforms,assignedClusters,chunkID,correctedFrameIndices,correctedFrameTimes,...
                                        stimInds,chunkIDForCorrectedFrames,photoDiode,spikeDetails,chunkIDForDetails,chunksToProcess,currentChunkInd);
                                    eyeData=getEyeRecords(eyeRecordPath, currentTrial,timestamp);
                                      
                                    %DON't LIKE HAVING THIS REDUNDANTCODE HERE .. but here it is
                                    neuralRecord.parameters=getNeuralRecordParameters(neuralRecord,neuralRecordLocation,subjectID);
                                    %Add some more activeParameters about the trial
                                    neuralRecord.parameters.trialNumber=currentTrial;
                                    neuralRecord.parameters.chunkID=chunksToProcess(currentChunkInd,2);
                                    neuralRecord.parameters.date=datenumFor30(timestamp);
                                    neuralRecord.parameters.ISIviolationMS=spikeDetectionParams.ISIviolationMS;
                                    neuralRecord.parameters.refreshRate=stimRecord.refreshRate; % where?
                                    
                                    [analysisdata cumulativedata] = physAnalysis(sm,filteredSpikeRecord,stimRecord.stimulusDetails,plotParameters,neuralRecord.parameters,cumulativedata,eyeData,LFPRecord);
                                end
                                break % chunksToProcess loop
                            else
                                spikeRecord
                                error(sprintf('no frames found on chunk %d which is not the last one! (trial %d has %d chunks)',chunksToProcess(currentChunkInd,2),chunksToProcess(currentChunkInd,1),size(chunksToProcess,1)))
                            end
                        end
                         
                        toInspectFramePulses = 0;
                        if toInspectFramePulses %for inspecting errors in frames
                            figure('position',[100 200 500 500])
                            inspectFramesPulses(neuralRecord.neuralData,neuralRecord.neuralDataTimes,spikeRecord.frameIndices,'longest');
                            %inspectFramesPulses(neuralRecord.neuralData,neuralRecord.neuralDataTimes,spikeRecord.frameIndices,'shortest');
                            % first last shortest longest
                        end
                        
                        if usePhotoDiodeSpikes
                            [spikeRecord.spikes spikeRecord.spikeWaveforms spikeRecord.photoDiode]=...
                                getSpikesFromPhotodiode(neuralRecord.neuralData(:,photoInd),...
                                neuralRecord.neuralDataTimes, spikeRecord.correctedFrameIndices,neuralRecord.samplingRate);
                            spikeRecord.spikeTimestamps = neuralRecord.neuralDataTimes(spikeRecord.spikes);
                            spikeRecord.assignedClusters=[ones(1,length(spikeRecord.spikeTimestamps))]';
                            %                             spikeRecord.spikeWaveforms=[];
                            det.rankedClusters=[];  % needs to be there for the contcatenation not to fail, though its empty
                            det.processedClusters=spikeRecord.assignedClusters'; % select all of them as belonging to a processed group
                            spikeRecord.spikeDetails=det;
                            
                            %                         frameTimes(:,1); %frame starts
                            %                         frameTimes(:,2); %frame stops
                        else
                            
                            %detection params needs samplingRate
                            spikeDetectionParams.samplingFreq=neuralRecord.samplingRate; % always overwrite with current value
                            %                     if ismember('samplingFreq',fields(spikeDetectionParams))
                            %                         spikeDetectionParams.samplingFreq
                            %                         error('when using analysis manager, samplingFreq is not specified by user, but rather loaded direct from the neural data file')
                            %                     else
                            %                         spikeDetectionParams.samplingFreq=samplingRate;
                            %                     end
                            [spikeRecord.spikes spikeRecord.spikeWaveforms spikeRecord.spikeTimestamps spikeRecord.assignedClusters ...
                                spikeRecord.rankedClusters]=...
                                getSpikesFromNeuralData(neuralRecord.neuralData(:,thesePhysChannelInds),neuralRecord.neuralDataTimes,...
                                spikeDetectionParams,spikeSortingParams,analysisPath);
                            % 6/3/09 - get integral under photoDiode curve
                            spikeRecord.photoDiode = getPhotoDiode(neuralRecord.neuralData(:,photoInd),spikeRecord.correctedFrameIndices);
                            
                            
                            
                            % 11/25/08 - do some post-processing on the spike's assignedClusters ('treatAllNonNoiseAsSpikes', 'largestClusterAsSpikes', etc)
                            
                            spikeRecord.spikeDetails = postProcessSpikeClusters(spikeRecord.assignedClusters,spikeRecord.rankedClusters,spikeSortingParams,spikeRecord.spikeWaveforms);
                            spikeRecord.spikeDetails.rankedClusters=spikeRecord.rankedClusters;
                            if isempty(spikeRecord.assignedClusters)
                                passedQualityTest=false;
                            end
                            % rename .clu, .klg, .fet, and .model files to be per-chunk
                            d=dir(analysisPath);
                            for di=1:length(d)
                                [matches tokens] = regexpi(d(di).name, 'temp\.(.*)\.\d+', 'match', 'tokens');
                                if length(matches) ~= 1
                                    %         warning('not a neuralRecord file name');
                                else
                                    [successM messageM messageIDM]=movefile(fullfile(analysisPath,d(di).name),...
                                        fullfile(analysisPath,sprintf('chunk%d.%s',chunksToProcess(currentChunkInd,2),tokens{1}{1})));
                                end
                            end
                        end
                        
                        %LFP resampling
                        if spikeDetectionParams.sampleLFP
                            spikeRecord.LFPRecord.data = resample(neuralRecord.neuralData(:,thesePhysChannelInds),spikeDetectionParams.LFPSamplingRateHz,neuralRecord.samplingRate);
                            if isfield(spikeDetectionParams,'LFPBandPass') %smooth each chunk separately? or do it at the end????
                                W = spikeDetectionParams.LFPBandPass*2/spikeDetectionParams.LFPSamplingRateHz;
                                N = 2; % second order filter...why? because!
                                [b a] = butter(N,W);
                                spikeRecord.LFPRecord.data=filter(b,a,spikeRecord.LFPRecord.data);
                            end
                            spikeRecord.LFPRecord.dataTimes = (linspace(neuralRecord.neuralDataTimes(1),neuralRecord.neuralDataTimes(end),length(spikeRecord.LFPRecord.data)))';
                            spikeRecord.LFPSamplingRateHz = spikeDetectionParams.LFPSamplingRateHz;
                        else
                            spikeRecord.LFPRecord.data = [];
                            spikeRecord.LFPRecord.dataTimes =[];
                            spikeRecord.LFPSamplingRateHz = [];
                        end
                        
                        
                        spikeRecord.chunkID=ones(length(spikeRecord.spikes),1)*chunksToProcess(currentChunkInd,2);
                        spikeRecord.chunkIDForCorrectedFrames=ones(length(spikeRecord.stimInds),1)*chunksToProcess(currentChunkInd,2);
                        spikeRecord.chunkIDForFrames=ones(size(spikeRecord.frameIndices,1),1)*chunksToProcess(currentChunkInd,2);
                        spikeRecord.chunkIDForDetails=chunksToProcess(currentChunkInd,2);
                        spikeRecord.trialNum=ones(length(spikeRecord.spikes),1)*currentTrial;
                        spikeRecord.trialNumForCorrectedFrames=ones(length(spikeRecord.stimInds),1)*currentTrial;
                        spikeRecord.trialNumForFrames=ones(size(spikeRecord.frameIndices,1),1)*currentTrial;
                        spikeRecord.trialNumForDetails=currentTrial;
                        
                        % these fields are per-chunk, not per-spike
                        % photoDiode
                        % passedQualityTest
                        % samplingRate
                        % spikeDetails
                        
                        
                        % 4/14/09 - replace the save here with a new save:
                        % - if no spikeRecord file, create one with spikeRecordFields in it
                        % - if already have a spikeRecord file, then append each variable (ie add spikeRecord.spikes to the spikes entry in the spikeRecord, etc)
                        if exist(spikeRecordLocation,'file')
                            prev=stochasticLoad(spikeRecordLocation);
                            
                            
                            try
                            % 6/3/09 - offset each chunk's stimInds by the last stimInd from previous chunk (moved 2/2/10) 
                            %maybe it should be after the ~proccessed || overwriteAll else
                            which=find(prev.trialNumForCorrectedFrames==currentTrial);
                            if ~isempty(which)
                                startingStimIndAdjustment=max(prev.stimInds(which));
                                startingSampleIndAdjustment=prev.correctedFrameIndices(which(end))+numPaddedSamples;
                            else
                                startingStimIndAdjustment=0;
                                startingSampleIndAdjustment=0;
                            end
                            catch ex
                                warning('a prob here')
                               keyboard
                               rethrow(ex) 
                            end
                            if prev.correctedFrameIndices(end)~=prev.frameIndices(end)
                                corrected=prev.correctedFrameIndices(end)
                                raw=prev.frameIndices(end)
                                error('the end frame was assumed to be the same... will this mess things up?')   
                            end
                        else
                            prev.spikes=[];
                            prev.spikeWaveforms=[];
                            prev.spikeTimestamps=[];
                            prev.assignedClusters=[];
                            prev.spikeDetails=[];
                            prev.frameIndices=[];
                            prev.frameTimes=[];
                            prev.frameLengths=[];
                            prev.correctedFrameIndices=[];
                            prev.correctedFrameTimes=[];
                            prev.correctedFrameLengths=[];
                            prev.stimInds=[];
                            prev.photoDiode=[];
                            prev.passedQualityTest=[];
                            prev.samplingRate=[];
                            prev.chunkID=[];
                            prev.chunkIDForFrames=[];
                            prev.chunkIDForCorrectedFrames=[];
                            prev.chunkIDForDetails=[];
                            prev.trialNum=[];
                            prev.trialNumForFrames=[];
                            prev.trialNumForCorrectedFrames=[];
                            prev.trialNumForDetails=[];
                            prev.LFPRecord.data = [];
                            prev.LFPRecord.dataTimes = [];
                            prev.LFPRecord.LFPSamplingRateHz = [];
                            startingStimIndAdjustment=0;
                            startingSampleIndAdjustment=0;
                            
                        end
                        % now append! (and take acount chunk counters like startingStimIndAdjustment startingSampleIndAdjustment)                    

                        spikes=[prev.spikes;spikeRecord.spikes                                                  + startingSampleIndAdjustment];
                        spikeWaveforms=[prev.spikeWaveforms;spikeRecord.spikeWaveforms];
                        spikeTimestamps=[prev.spikeTimestamps;spikeRecord.spikeTimestamps];
                        assignedClusters=[prev.assignedClusters;spikeRecord.assignedClusters];
                        spikeDetails=[prev.spikeDetails;spikeRecord.spikeDetails];
                        frameIndices=[prev.frameIndices;spikeRecord.frameIndices                                + startingSampleIndAdjustment];
                        frameTimes=[prev.frameTimes;spikeRecord.frameTimes];
                        frameLengths=[prev.frameLengths;spikeRecord.frameLengths];
                        correctedFrameIndices=[prev.correctedFrameIndices;spikeRecord.correctedFrameIndices     + startingSampleIndAdjustment];
                        correctedFrameTimes=[prev.correctedFrameTimes;spikeRecord.correctedFrameTimes];
                        correctedFrameLengths=[prev.correctedFrameLengths;spikeRecord.correctedFrameLengths];
                        stimInds=[prev.stimInds;spikeRecord.stimInds                                            + startingStimIndAdjustment];
                        photoDiode=[prev.photoDiode;spikeRecord.photoDiode];
                        passedQualityTest=[prev.passedQualityTest;spikeRecord.passedQualityTest];
                        samplingRate=[prev.samplingRate;spikeRecord.samplingRate];
                        chunkID=[prev.chunkID;spikeRecord.chunkID];
                        chunkIDForFrames=[prev.chunkIDForFrames;spikeRecord.chunkIDForFrames];
                        chunkIDForCorrectedFrames=[prev.chunkIDForCorrectedFrames;spikeRecord.chunkIDForCorrectedFrames];
                        chunkIDForDetails=[prev.chunkIDForDetails;spikeRecord.chunkIDForDetails];
                        trialNum=[prev.trialNum;spikeRecord.trialNum];
                        trialNumForFrames=[prev.trialNumForFrames;spikeRecord.trialNumForFrames];
                        trialNumForCorrectedFrames=[prev.trialNumForCorrectedFrames;spikeRecord.trialNumForCorrectedFrames];
                        trialNumForDetails=[prev.trialNumForDetails;spikeRecord.trialNumForDetails];
                        LFPRecord.data = [prev.LFPRecord.data; spikeRecord.LFPRecord.data];
                        LFPRecord.dataTimes = [prev.LFPRecord.dataTimes; spikeRecord.LFPRecord.dataTimes];
                        LFPRecord.LFPSamplingRateHz= [prev.LFPRecord.LFPSamplingRateHz;spikeRecord.LFPSamplingRateHz];
                        
                        %                                                 if 0 %Used to check for gaps between frames
                        %                                                     %%
                        %                                                     figure
                        %                                                     sz=size(correctedFrameTimes)
                        %                                                     x=correctedFrameTimes(:);
                        %                                                     x([1 end])=[]
                        %                                                     y=reshape(x,sz(1)-1,[])
                        %                                                     plot(y(5:end,1)-y(5:end,2))
                        %                                                 end
                        
                      
                        save(spikeRecordLocation,'spikes','spikeWaveforms','spikeTimestamps','assignedClusters','spikeDetails',...
                            'frameIndices','frameTimes','frameLengths','correctedFrameIndices','correctedFrameTimes','correctedFrameLengths',...
                            'stimInds','chunkID','chunkIDForFrames','chunkIDForCorrectedFrames','chunkIDForDetails',...
                            'trialNum','trialNumForFrames','trialNumForCorrectedFrames','trialNumForDetails',...
                            'photoDiode','passedQualityTest','samplingRate','LFPRecord');
                        
                        % check that we have spikes
                        if isempty(spikeRecord.assignedClusters)
                            spikeRecord.passedQualityTest(end)=false;
                        end
                    else % just load existing spikes for this chunk!
                        spikeRecord=stochasticLoad(spikeRecordLocation);
                        fn=fieldnames(spikeRecord);
                        for sp=1:length(fn)
                            str=sprintf('%s = spikeRecord.%s;',fn{sp},fn{sp});
                            eval(str);
                        end
                        % now filter each field in spikeRecord to only be this chunk
                        % pmm questions whether this should overwrite the local variable in the workspace, as opposed to filtering inside the spikeRecord struct (it doesn't on 2/2/10)
                        which=find(spikeRecord.chunkID==chunksToProcess(currentChunkInd,2)&spikeRecord.trialNum==chunksToProcess(currentChunkInd,1));
                        spikeRecord.assignedClusters=spikeRecord.assignedClusters(which);
                        spikeRecord.spikeTimestamps=spikeRecord.spikeTimestamps(which);
                        spikeRecord.spikeWaveforms=spikeRecord.spikeWaveforms(which);
                        spikeRecord.chunkID=spikeRecord.chunkID(which);
                        spikeRecord.trialNum=spikeRecord.trialNum(which);
                        which=find(spikeRecord.chunkIDForCorrectedFrames==chunksToProcess(currentChunkInd,2)&spikeRecord.trialNumForCorrectedFrames==chunksToProcess(currentChunkInd,1));
                        spikeRecord.correctedFrameIndices=spikeRecord.correctedFrameIndices(which);
                        spikeRecord.correctedFrameLengths=spikeRecord.correctedFrameLengths(which);
                        spikeRecord.correctedFrameTimes=spikeRecord.correctedFrameTimes(which);
                        spikeRecord.stimInds=spikeRecord.stimInds(which);
                        spikeRecord.chunkIDForCorrectedFrames=spikeRecord.chunkIDForCorrectedFrames(which);
                        spikeRecord.trialNumForCorrectedFrames=spikeRecord.trialNumForCorrectedFrames(which);
                        spikeRecord.photoDiode=spikeRecord.photoDiode(which);
                        which=find(spikeRecord.chunkIDForFrames==chunksToProcess(currentChunkInd,2)&spikeRecord.trialNumForFrames==chunksToProcess(currentChunkInd,1));
                        spikeRecord.frameIndices=spikeRecord.frameIndices(which);
                        spikeRecord.frameLengths=spikeRecord.frameLengths(which);
                        spikeRecord.frameTimes=spikeRecord.frameTimes(which);
                        spikeRecord.chunkIDForFrames=spikeRecord.chunkIDForFrames(which);
                        spikeRecord.trialNumForFrames=spikeRecord.trialNumForFrames(which);
                        which=find(spikeRecord.chunkIDForDetails==chunksToProcess(currentChunkInd,2)&spikeRecord.trialNumForDetails==chunksToProcess(currentChunkInd,1));
                        spikeRecord.passedQualityTest=spikeRecord.passedQualityTest(which);
                        spikeRecord.samplingRate=spikeRecord.samplingRate(which);
                        spikeRecord.spikeDetails=spikeRecord.spikeDetails(which);
                        spikeRecord.chunkIDForDetails=spikeRecord.chunkIDForDetails(which);
                        spikeRecord.trialNumForDetails=spikeRecord.trialNumForDetails(which);
                    end
                    
                      
                    
                    % =================================================================================
                    % now run analysis on spikeRecords and stimRecords
                    % try to get location of analysis file
                    
                    %  % deterimine the quality of this chunk file alone (maybe some analysis want this one day, but not needed yet)
                    %                     lastChunkQuality.passedQualityTest=spikeRecord.passedQualityTest;
                    %                     lastChunkQuality.frameIndices=spikeRecord.frameIndices;
                    %                     lastChunkQuality.frameTimes=spikeRecord.frameTimes;
                    %                     lastChunkQuality.frameLengths=spikeRecord.frameLengths;
                    %                     lastChunkQuality.correctedFrameIndices=spikeRecord.correctedFrameIndices;
                    %                     lastChunkQuality.correctedFrameTimes=spikeRecord.correctedFrameTimes;
                    %                     lastChunkQuality.correctedFrameLengths=spikeRecord.correctedFrameLengths;
                    %                     lastChunkQuality.samplingRate=spikeRecord.samplingRate; % from neuralRecord
                    %                     quality.lastChunkQuality=lastChunkQuality;
                    
                    %use the cumulative information (not just the last chunks information)
                    quality.passedQualityTest=passedQualityTest;
                    quality.frameIndices=frameIndices;
                    quality.frameTimes=frameTimes;
                    quality.frameLengths=frameLengths;
                    quality.correctedFrameIndices=correctedFrameIndices;
                    quality.correctedFrameTimes=correctedFrameTimes;
                    quality.correctedFrameLengths=correctedFrameLengths;
                    quality.samplingRate=samplingRate; % from neuralRecord
                    quality.chunkIDForCorrectedFrames=spikeRecord.chunkIDForCorrectedFrames;
                    quality.chunkIDForFrames=spikeRecord.chunkIDForFrames;
                    
                    stimRecord=stochasticLoad(stimRecordLocation);
                    evalStr = sprintf('sm = %s();',stimRecord.stimManagerClass);
                    eval(evalStr);
                    
                    % 6/15/09 - decide whether to do analysis in a stim-specific way
                    % (default = if quality is good)
                    % (whiteNoise = always do analysis for now)
                    % (manualCmrMotionEyeCal = always do analysis for now - future ignore spikes)
                    analysisExists=exist(analysisLocation,'file');
                    %spikeRecord.assignedClusters
                    %quality.passedQualityTest
                    doAnalysis=worthPhysAnalysis(sm,quality,analysisExists,overwriteAll,isLastChunkInTrial); %doAnalysis = isLastChunkInTrial;
                    %doAnalysis=isLastChunkInTrial

                    
                    % possible problem:  last chunk lacks frame pulses, and
                    % gets quality.passedQualityTest=false (not exactly sure how)
                    % but then the whole analysis never runs, becase the
                    % last chunk (isLastChunkInTrial=true) is the only
                    % chance
                    
                    if doAnalysis % 1
                        % do something with loaded information
                        % NOTE - neuralRecord refers to all the 'neuralRecord' for a particular chunk!
                        % get some paramteres from neual data
                        if exist('neuralRecord','var') && isfield(neuralRecord,'parameters')
                            %pass
                        else
                            neuralRecord.parameters=getNeuralRecordParameters(neuralRecord,neuralRecordLocation,subjectID);
                        end
                        %Add some more activeParameters about the trial
                        neuralRecord.parameters.trialNumber=currentTrial;
                        neuralRecord.parameters.chunkID=chunksToProcess(currentChunkInd,2);
                        neuralRecord.parameters.date=datenumFor30(timestamp);
                        neuralRecord.parameters.ISIviolationMS=spikeDetectionParams.ISIviolationMS;
                        neuralRecord.parameters.refreshRate=stimRecord.refreshRate; % where?
                        
                        eyeData=getEyeRecords(eyeRecordPath, currentTrial,timestamp);
                        % the stimManagerClass to be passed in is for class typing only -
                        % the analysis function is called as a static method of the stimManager class
                        % just pass in a default stimManager - no variables are used
                        % stuff to class type the analysis method
                        % stimManagerClass = stimulusDetails.stimManagerClass;
                        % already its own variable in stimRecords
                        
                        % 4/17/09 - only pass in the parts of the spikeRecord that belong to the currentTrial
                        % filteredSpikeRecord is a struct that contains all the spike data for the currentTrial to send to physAnalysis
                        filteredSpikeRecord=getCurrentTrialSpikeRecords(currentTrial,trialNum,trialNumForCorrectedFrames,trialNumForDetails,...
                            spikes,spikeTimestamps,spikeWaveforms,assignedClusters,chunkID,correctedFrameIndices,correctedFrameTimes,...
                            stimInds,chunkIDForCorrectedFrames,photoDiode,spikeDetails,chunkIDForDetails,chunksToProcess,currentChunkInd);

                        [analysisdata cumulativedata] = physAnalysis(sm,filteredSpikeRecord,stimRecord.stimulusDetails,plotParameters,neuralRecord.parameters,cumulativedata,eyeData,LFPRecord);
                        % parameters is from neuralRecord
                        % we pass in the analysisdata because it contains cumulative information that is specific to the analysis method
                        % this is the way of making sure it gets in every trial's analysis file, and that it will get propagated to the next analysis
                        
                        % 4/14/09 - similar to saving of spikeRecord
                        % if the file doesn't exist, create it and save both the cumulative analysisdata, and a chunk-specific analysisdata
                        % if the file exists, add a variable for this chunk's analysisdata, but also update the cumulative analysisdata!
                        evalStr=sprintf('chunk%d = analysisdata',chunksToProcess(currentChunkInd,2));
                        eval(evalStr);
                        if exist(analysisLocation,'file')
                            evalStr=sprintf('save ''%s'' chunk%d cumulativedata -append',analysisLocation,chunksToProcess(currentChunkInd,2));
                        else
                            evalStr=sprintf('save ''%s'' chunk%d cumulativedata',analysisLocation,chunksToProcess(currentChunkInd,2));
                        end
                        eval(evalStr);
                        evalStr=sprintf('clear chunk%d;',chunksToProcess(currentChunkInd,2));
                        eval(evalStr);
                    else
                        dispStr=sprintf('skipping analysis for trial %d chunk %d',chunksToProcess(currentChunkInd,1),chunksToProcess(currentChunkInd,2));
                        disp(dispStr);


                             
                        %                         if chunksToProcess(currentChunkInd,2)==1  % for debugging
                        %                             doAnalysis=worthPhysAnalysis(sm,quality,analysisExists,overwriteAll,isLastChunkInTrial)
                        %                             quality
                        %                             analysisExists
                        %                             overwriteAll
                        %                             isLastChunkInTrial
                        %                             class(sm)
                        %                             analyszesEachChunk=enableChunkedPhysAnalysis(sm)
                        %                             warning('skipped first chunk in trial...why?')
                        %                             keyboard
                        %                         end
                    end
                catch ex
                    disp(['CAUGHT EX: ' getReport(ex)])
                    %             break
                    % 11/25/08 - restart dir loop if tried to load corrupt file
                    rethrow(ex)
                    error('failed to load from file');
                end
                processedChunks=[processedChunks; chunksToProcess(currentChunkInd,:)];
            end
        end % end doneWithThisTrial loop
        if maskThisTrial
            disp(sprintf('skipping trialNumber: %d',currentTrial))
            currentTrial = min(currentTrial+1,boundaryRange(3));
        end
    else
        disp(sprintf('skipping class: %s',stimRecord.stimManagerClass))
        currentTrial=min(currentTrial+1,boundaryRange(3));
    end
end % end quit loop

%     % get a list of the available stimRecords
%     stimRecordsPath = fullfile(path, subjectID, 'stimRecords');
%     if ~isdir(stimRecordsPath)
%         error('unable to find directory to stimRecords');
%     end
%
%     d=dir(stimRecordsPath)
end % end main function
% ===============================================================================================



% ===============================================================================================

function [spikes spikeWaveforms photoDiode]=getSpikesFromPhotodiode(photoDiodeData,photoDiodeDataTimes,frameIndices,samplingRate)
% get spikes from neuralData and neuralDataTimes, and given frameTimes
spikeWaveforms=[];
photoDiode = getPhotoDiode(photoDiodeData,frameIndices);
% now calculate spikes in each frame
spikes = [];
if isempty(photoDiode)
    % that means frameIndices was empty
    return;
end

method='logistic'; %'threshold','logistic'
switch method
    case 'threshold'
        squaredVals = (photoDiode).^2;  % rescale so zero is smallest value... a bit funny
        % now sort the values, and choose the first 5% to show threshold
        %fractionBaselineSpikes=0.05; % chance of a single spike on a frame % not used
        fractionStimSpikes=0.1;      % chance of any spikes on a frame caused by stim
        maxNumStimSpikes=1;         % per frame
        valuesToCalcThreshold = sort(squaredVals,'descend');
        pivot = ceil(length(squaredVals) * fractionStimSpikes);
        threshold = (valuesToCalcThreshold(pivot) + valuesToCalcThreshold(pivot+1)) / 2;
        threshold=25000;
        %numSpikes=ceil(maxNumStimSpikes*(squaredVals-threshold)/(valuesToCalcThreshold(1)-threshold));
        
        % for each frame, see if it passes a threshold
        for i=1:size(frameIndices,1)
            if squaredVals(i) > threshold
                numSpikes=ceil(maxNumStimSpikes*(squaredVals(i)-threshold)/(valuesToCalcThreshold(1)-threshold));
                numSpikes=min(numSpikes,maxNumStimSpikes);
                randInds=randperm(diff(frameIndices(i,:)))+frameIndices(i,1); % randomly order the candidate locations
                spikes=[spikes;randInds(1:numSpikes)'];  % put N spikes at random locations (doesn't respect refractory)
            end
        end
    case 'logistic'
        %having dynamic params is usefull if you only have one chunk,
        %but dangerous for multiple chunks
        u=250; %mean
        B=30;   %slope
        pSpike=1./(1+exp((u-photoDiode)/B));
        
        if 0 % inspect parmater range for this luminance data
            figure;
            subplot(2,1,1); hist(photoDiode,100)
            x=linspace(min(photoDiode(:)),max(photoDiode(:)),100);
            subplot(2,1,2); plot(x,1./(1+exp((u-x')./B)));
        end
        for i=1:size(frameIndices,1)
            if pSpike(i) > rand % only 1 spike per frame at most
                randInd=ceil(rand*diff(frameIndices(i,:)))+frameIndices(i,1); % randomly order the candidate locations
                spikes=[spikes;randInd];  % put a spikes at a random locations (doesn't respect refractory)
            end
        end     
end

pre=floor(.58*samplingRate/1000);
post=floor(1.0*samplingRate/1000); % hard-coded 1.5ms and 0.5ms for now... matches the 64 samps made by osort
for j=1:length(spikes)
    if (spikes(j)+post)<length(photoDiodeData) && (spikes(j)-pre)>0
        try
            spikeWaveforms=[spikeWaveforms; photoDiodeData(spikes(j)-pre:spikes(j)+post)'];
        catch
            size(spikeWaveforms)
            length(photoDiodeData)
            spikes(j)-pre
            spikes(j)+post
            error('waveform prob')
        end
    elseif isempty(spikeWaveforms) %make noise if first
        spikeWaveforms=rand(1,length(pre:post));
    else  %copy previous waveform if at end
        
        %sometimes the spike goes off the end of the samples
        %available (tail is off the chunk boundary)
        %if so, add repeat the prev waveform
        spikeWaveforms=[spikeWaveforms; spikeWaveforms(end,:)];
    end
end
disp('got spikes from photo diode');

end % end function
% ===============================================================================================

function photoDiode = getPhotoDiode(photoDiodeData,frameIndices)
photoDiode=zeros(size(frameIndices,1),1);
% now calculate spikes in each frame
% channel = 1; % what channel of the neuralData to look at
% first go through and histogram the values to get a threshold

darkFloor=min(photoDiodeData); % is there a better way to determin the dark value?  noise is a problem! last value particularly bad... why?
darkFloor=-0.1; % somehting hard coded to get rid of some negative values (high gain mode on photodiode has negs), but be constant across chunks
for i=1:size(frameIndices,1)
    % photoDiode is the sum of all neuralData of the given channel for the given samples (determined by frame start/stop)
    photoDiode(i) = sum(photoDiodeData(frameIndices(i,1):frameIndices(i,2))-darkFloor);
    %why are these negative?... i thought black was zero... guess not! subtracting a darkfloor now -pmm 2009
    % a better value might be the mean... pmm 1/11/10
end

inspect=0;
if inspect
    %
    n=length(frameIndices)
    frameRange=[n-43 n]
    %frameRange=[1 min(1000,n)]
    plot(photoDiodeData(frameIndices(frameRange(1),1):frameIndices(frameRange(2),2)),'g')
    hold on
    for i=frameRange(1):frameRange(2)
        xIndStart= frameIndices(i,1)-frameIndices(frameRange(1),1);
        xIndEnd= frameIndices(i,2)-frameIndices(frameRange(1),1);
        %plot([xIndStart xIndEnd],-8+photoDiode([i i])/(12),'r-')
        plot([xIndStart xIndEnd],-0.46+10*photoDiode([i i])/(1+xIndEnd-xIndStart),'r-')
    end
end
end % end function

% ===============================================================================================


function inspectFramesPulses(neuralData,neuralDataTimes,frameIndices,mode,numFrames)

if ~exist('numFrames','var') || isempty(numFrames)
    numFrames=6;
end

numFramesPad=ceil(numFrames/2);
switch mode
    case {'start','first'}
        which=1+numFrames;
        timePad=4000;
    case {'end','last'}
        which=length(frameIndices)-numFrames;
        timePad=4000;
    case 'shortest'
        shortestFrameLength=min(unique(diff(frameIndices')));
        which=find(shortestFrameLength==diff(frameIndices'));
        timePad=0;
    case 'longest'
        longestFrameLength=max(unique(diff(frameIndices')));
        which=find(longestFrameLength==diff(frameIndices'));
        timePad=0;
    otherwise
        error('bad mode')
end

which=which(1);  % first one if there is a tie.

sss=max(which-numFramesPad,1);
eee=min(which+numFramesPad,size(frameIndices,1));
ss=frameIndices(sss)-timePad;
ee=frameIndices(eee)+timePad;

if ~isempty(frameIndices)
    hold off
    plot(neuralDataTimes(ss:ee),neuralData(ss:ee,2))
    hold on;
    plot(neuralDataTimes(ss:ee),neuralData(ss:ee,1),'r')
    
    plot(neuralDataTimes(frameIndices([sss:eee],1)),ones(1,1+eee-sss),'k.')
    plot(neuralDataTimes(frameIndices(which,1)),1,'ko')
else
    warning('frameIndices is empty... why does that happen?')
    % maybe the last chunk this trial has no frames in it, b/c maybe
    % datanet runs past the last frame pulse
end

end % end function

% ===============================================================================================
function out=stochasticLoad(filename,fieldsToLoad)
if ~exist('fieldsToLoad','var')
    fieldsToLoad=[];
end

success=false;
while ~success
    try
        if isempty(fieldsToLoad) % default to load all
            out=load(filename);
        else
            evalStr=sprintf('out = load(''%s''',filename);
            for i=1:length(fieldsToLoad)
                evalStr=[evalStr ','''  fieldsToLoad{i} ''''];
            end
            evalStr=[evalStr ');'];
            eval(evalStr);
        end
        success=true;
    catch
        WaitSecs(abs(randn));
        dispStr=sprintf('failed to load %s - trying again',filename);
        disp(dispStr)
    end
end


end % end function

% ===============================================================================================
function parameters=getNeuralRecordParameters(neuralRecord,neuralRecordLocation,subjectID)
% gets and handles the default
out=stochasticLoad(neuralRecordLocation,{'parameters'});
if isfield(out,'parameters')
    parameters=out.parameters;
else
    p=[];
    p.samplingRate=neuralRecord.samplingRate;
    p.subjectID=subjectID;
    parameters=p;
end
end

% ===============================================================================================
function filteredSpikeRecord=getCurrentTrialSpikeRecords(currentTrial,trialNum,trialNumForCorrectedFrames,trialNumForDetails,spikes,spikeTimestamps,spikeWaveforms,assignedClusters,chunkID,correctedFrameIndices,correctedFrameTimes,stimInds,chunkIDForCorrectedFrames,photoDiode,spikeDetails,chunkIDForDetails,chunksToProcess,currentChunkInd)

try
    filteredSpikeRecord=[];
    which=find(trialNum==currentTrial);
    filteredSpikeRecord.spikes=spikes(which);
    filteredSpikeRecord.spikeTimestamps=spikeTimestamps(which);
    filteredSpikeRecord.spikeWaveforms=spikeWaveforms(which,:);
    filteredSpikeRecord.assignedClusters=assignedClusters(which,:);
    filteredSpikeRecord.chunkID=chunkID(which);
    which=find(trialNumForCorrectedFrames==currentTrial);
    filteredSpikeRecord.correctedFrameIndices=correctedFrameIndices(which,:);
    filteredSpikeRecord.correctedFrameTimes = correctedFrameTimes(which,:);
    filteredSpikeRecord.stimInds=stimInds(which);
    filteredSpikeRecord.chunkIDForCorrectedFrames=chunkIDForCorrectedFrames(which);
    filteredSpikeRecord.photoDiode=photoDiode(which);
    which=find(trialNumForDetails==currentTrial);
    filteredSpikeRecord.spikeDetails=spikeDetails(which);
    filteredSpikeRecord.chunkIDForDetails=chunkIDForDetails(which);
    filteredSpikeRecord.currentChunk=chunksToProcess(currentChunkInd,2);
catch ex
    getReport(ex)
    keyboard
end
end