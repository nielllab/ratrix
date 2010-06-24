function  optimizeSortingByChannel(subjectID, path, cellBoundary, channels, spikeDetectionParams, spikeSortingParams,...
    timeRangePerTrialSecs,stimClassToAnalyze,overwriteAll,usePhotoDiodeSpikes)

%% error checking
if ~exist('plottingParams','var') || isempty(plottingParams)
    plottingParams.showSpikeAnalysis = true;
    plottingParams.showLFPAnalysis = true;
    plottingParams.plotSortingForTesting = true;
end
if ~isfield(spikeSortingParams,'plotSortingForTesting')
    if isfield(plottingParams,'plotSortingForTesting')
        spikeSortingParams.plotSortingForTesting = plottingParams.plotSortingForTesting;
    else
        spikeSortingParams.plotSortingForTesting = false;
    end
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
        otherwise
            error('bad type of cellBoundary!');
    end
elseif iscell(cellBoundary) && length(cellBoundary)==4
    error('masking not supported');
else
    error('bad cellBoundary input');
end

if ~exist('channels','var') || isempty(channels)
    channelAnalysisMode = 'allPhysChannels';
else
    channelAnalysisMode = 'onlySelectedChannels';
end
    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
spikeDetectionAndSortingDone = false;

if overwriteAll
    %% CREATE THE ANALYSIS PATH FOR THE BOUNDARYRANGE
    if boundaryRange(1)==boundaryRange(3)
        analysisPathStr = sprintf('%d',boundaryRange(1));
    else
        analysisPathStr = sprintf('%d-%d',boundaryRange(1),boundaryRange(3));
    end
    analysisPathForBoundaryRange = fullfile(path,subjectID,'analysis',analysisPathStr);
end
    
% some logicals
doneWithAllTrials = false;

currentTrialNum = boundaryRange(1);
%% LOOP THROUGH TRIALS
while ~doneWithAllTrials    
    %% LOOK FOR NEURALRECORDS
    dirStr=fullfile(neuralRecordsPath,sprintf('neuralRecords_%d-*.mat',currentTrialNum));
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
        neuralRecordLocation = fullfile(neuralRecordsPath,sprintf('neuralRecords_%d-%s.mat',currentTrialNum,timestamp));
    elseif length(d)>1
        error('duplicates present');
    else
        error('didnt find anything in d');
    end
    
    %% DETERMINE CHUNKS TO PROCESS
    disp('checking chunk names... may be slow remotely...'); tic;
    chunkNames=who('-file',neuralRecordLocation);
    fprintf(' %2.2f seconds',toc)
    chunksToProcess=[];
    for i=1:length(chunkNames)
        [matches tokens] = regexpi(chunkNames{i}, 'chunk(\d+)', 'match', 'tokens');
        if length(matches)~=0
            chunksToProcess(end+1) =  str2double(tokens{1}{1});
        end
    end
    chunksToProcess = sort(chunksToProcess);
    
    %% IDENTIFY STORAGE LOCATIONS
    % make temporary analysis folder and locate the neuralRecordLocation
    analysisPathForTrial = fullfile(analysisPathForBoundaryRange,num2str(currentTrialNum));
    % spikeRecord.mat will contain info about all the channels for that trial.
    spikeRecordLocation=fullfile(analysisPathForTrial,'spikeRecordsCumulative.mat');
    
    % first delete analysis folder if it exists
    if exist(analysisPathForTrial,'dir')
        [succ,msg,msgID] = rmdir(analysisPathForTrial,'s');  % includes all subdirectory regardless of permissions
        if ~succ
            msg
            error('failed to remove existing files when running with ''overwriteAll=true''')
        end
    end
    % now make it again
    if ~isdir(analysisPathForTrial)
        mkdir(analysisPathForTrial);
    end
    
    %now create the Cumulative Spike Record variable (to be stored in the
    %analysis folder)
    spikeRecordsForTrial = [];
    
    %% LOOP THROUGH CHUNKS
    currentChunkInd = 1;
    doneWithAllChunksForTrial = false;
    while ~doneWithAllChunksForTrial
        % =================================================================================
        chunkStr=sprintf('chunk%d',chunksToProcess(currentChunkInd));
        fprintf('*********DOING %s*************\n',chunkStr)
        
        % load the chunk
        neuralRecord=stochasticLoad(neuralRecordLocation,{chunkStr,'samplingRate'});
        temp=neuralRecord.samplingRate;
        neuralRecord=neuralRecord.(chunkStr);
        neuralRecord.samplingRate=temp;
        neuralRecord.neuralDataTimes=linspace(neuralRecord.neuralDataTimes(1),neuralRecord.neuralDataTimes(end),size(neuralRecord.neuralData,1))';
        if ~isfield(neuralRecord,'ai_parameters')
            neuralRecord.ai_parameters.channelConfiguration={'framePulse','photodiode','phys1'};
            if size(neuralRecord.neuralData,2)~=3
                error('only expect old unlabeled data with 3 channels total... check assumptions')
            end
        end
        
        % name the channels
        photoInd=find(strcmp(neuralRecord.ai_parameters.channelConfiguration,'photodiode'));
        pulseInd=find(strcmp(neuralRecord.ai_parameters.channelConfiguration,'framePulse'));
        allPhysInds = find(~cellfun(@isempty, strfind(neuralRecord.ai_parameters.channelConfiguration,'phys')));
        if length(spikeDetectionParams)==1
            spikeDetectionParams = repmat(spikeDetectionParams,[length(allPhysInds) 1]);
        end 
        
        %% WHICH CHANNELS DO WE NEED?
        
        switch channelAnalysisMode
            case 'allPhysChannels'
                thesePhysChannelInds = allPhysInds;
                
            case 'onlySelectedChannels'
                chansRequired=[];
                for i = 1:length(channels)
                    chansRequired = unique([chansRequired channels{:}]);
                end
                for c=1:length(chansRequired)
                    chansRequiredLabel{c}=['phys' num2str(chansRequired(c))];
                end                
                if any(~ismember(chansRequiredLabel,neuralRecord.ai_parameters.channelConfiguration))
                    chansRequiredLabel
                    neuralRecord.ai_parameters.channelConfiguration
                    error(sprintf('requested analysis on channels %s but thats not available',char(setdiff(chansRequiredLabel,neuralRecord.ai_parameters.channelConfiguration))))
                end
                %only analyze some channels
                for c=1:length(spikeChannelsAnalyzed{1})
                    thesePhysChannelLabels{c}=['phys' num2str(spikeChannelsAnalyzed{1}(c))];
                    thesePhysChannelInds(c)=find(ismember(neuralRecord.ai_parameters.channelConfiguration,thesePhysChannelLabels{c}));
                end
        end
        %% NOW LOOP THROUGH THE CHANNELS
        for thisPhysChannelInd = thesePhysChannelInds
            which = find(allPhysInds==thisPhysChannelInd);
            analysisPathByChannel = fullfile(analysisPathForTrial,num2str(thisPhysChannelInd));
            if ~exist (analysisPathByChannel,'dir')
                mkdir(analysisPathByChannel)
            end
            
            spikeRecord.spikeDetails=[];
            spikeRecord.samplingRate=neuralRecord.samplingRate;
            spikeDetectionParams(which).samplingFreq=neuralRecord.samplingRate; % always overwrite with current value
            
            %% GET SPIKE DETAILS
            [spikeRecord.spikes spikeRecord.spikeWaveforms spikeRecord.spikeTimestamps spikeRecord.assignedClusters ...
                spikeRecord.rankedClusters]=...
                getSpikesFromNeuralData(neuralRecord.neuralData(:,thisPhysChannelInd),neuralRecord.neuralDataTimes,...
                spikeDetectionParams(which),spikeSortingParams,analysisPathByChannel);
            
            %% SAVE THE MODEL FILE FOR EACH CHUNK BY CHANNEL
            d=dir(analysisPathByChannel);
            for di=1:length(d)
                [matches tokens] = regexpi(d(di).name, 'temp\.(.*)\.\d+', 'match', 'tokens');
                if length(matches) ~= 1
                    %         warning('not a neuralRecord file name');
                else
                    [successM messageM messageIDM]=movefile(fullfile(analysisPathByChannel,d(di).name),...
                        fullfile(analysisPathByChannel,sprintf('chunk%d.%s',chunksToProcess(currentChunkInd),tokens{1}{1})));
                end
            end
            
            spikeRecord.chunkID=ones(length(spikeRecord.spikes),1)*chunksToProcess(currentChunkInd);
            
            %% NOW STORE THE DATA IN ONE PLACE
            chanID = sprintf('chan%d',thisPhysChannelInd);
            if isFirstChunkOfBoundaryRange(boundaryRange,currentTrialNum,currentChunkInd)
                spikeRecordCumulative.(chanID).samplingRate = neuralRecord.samplingRate;
                spikeRecordCumulative.(chanID).channelName = neuralRecord.ai_parameters.channelConfiguration(thisPhysChannelInd);
                spikeRecordCumulative.(chanID).PC = [];
                spikeRecordCumulative.(chanID).model = [];
                spikeRecordCumulative.(chanID).spikes = [];
                spikeRecordCumulative.(chanID).spikeWaveforms = [];
                spikeRecordCumulative.(chanID).spikeTimestamps = [];
                spikeRecordCumulative.(chanID).assignedClusters = [];
                spikeRecordCumulative.(chanID).chunkID=[];
                
            else
                spikeRecordCumulative.(chanID).spikes = [spikeRecordCumulative.(chanID).spikes;spikeRecord.spikes];
                spikeRecordCumulative.(chanID).spikeWaveforms = [spikeRecordCumulative.(chanID).spikeWaveforms;spikeRecord.spikeWaveforms];
                spikeRecordCumulative.(chanID).spikeTimestamps = [spikeRecordCumulative.(chanID).spikeTimestamps;spikeRecord.spikeTimestamps];
                spikeRecordCumulative.(chanID).assignedClusters = [spikeRecordCumulative.(chanID).assignedClusters;spikeRecord.assignedClusters];
                spikeRecordCumulative.(chanID).chunkID=[spikeRecordCumulative.(chanID).chunkID;spikeRecord.chunkID];
            end
            
            % rename the model files of klusta here to keep them for the next series
        end
        %% HERE WE ARE DONE WITH THAT CHUNK
        
        %% LETS FIND OUT IF THE SORTING WAS GOOD
        if 0%isFirstChunkOfBoundaryRange(boundaryRange,currentTrialNum, currentChunkInd)
            margin = 10;
            oneRowHeight = 25;
            fieldWidth = 100;
            
            numChans = length(thesePhysChannelInds);
            GUIWidth = 2*margin+3*fieldWidth;
            GUIHeight = 2*margin+oneRowHeight*numChans;
            GUIFig = figure('Visible','off','MenuBar','none','Name','spikeSortingGUI',...
                'NumberTitle','off','Resize','off','Units','pixels','Position',[50 50 100 100],...
                'CloseRequestFcn',@cleanup);    
        end
        
        %% IF LAST CHUNK OF boundaryRange, THEN PLOT SUMMARY FIGURE
        if isLastChunkOfBoundaryRange(boundaryRange,currentTrialNum,currentChunkInd,max(chunksToProcess)) %&& spikeSortingParams.plotSortingForTesting
            plotSummaryFigureForChannels(spikeRecordCumulative, thesePhysChannelInds)
        end
        
        clear (sprintf('chunk%d',chunksToProcess(currentChunkInd)));
        
        doneWithAllChunksForTrial = (currentChunkInd==length(chunksToProcess));
        currentChunkInd = currentChunkInd+1;        
    end
    %% SAVE THE CUMULATIVE RECORD AND OTHER DETAILS
    save(spikeRecordLocation,'spikeRecordCumulative','spikeDetectionParams');
    
    doneWithAllTrials = (currentTrialNum==boundaryRange(3));
    currentTrialNum = currentTrialNum +1;
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function out = isFirstChunkOfBoundaryRange(boundaryRange,currentTrialNum, currentChunkInd)
out = false;
if currentTrialNum == boundaryRange(1) & currentChunkInd == boundaryRange(2)
    out = true;
elseif currentTrialNum>boundaryRange(1) & currentTrialNum<=boundaryRange(3) & currentChunkInd == 1
    out = true;
end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function out = isLastChunkOfBoundaryRange(boundaryRange,currentTrialNum, currentChunkInd, maxChunksInTrial)
out = false;
if currentTrialNum == boundaryRange(3) & (currentChunkInd == boundaryRange(4) | currentChunkInd == maxChunksInTrial)
    out = true;
end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function cleanup(source,eventdata)
% return event here
%         events = guidata(f);
%         events_data
%         save temp events_data;
FlushEvents('mouseUp','mouseDown','keyDown','autoKey','update');
ListenChar(0) %'called listenchar(0) -- why doesn''t keyboard work?'
ShowCursor(0)
closereq;
return;
end % end cleanup function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function figInd = plotSummaryFigureForChannels(spikeRecordCumulative,thesePhysChannelInds)
figInd = figure;
% find the y dimensions
Ymin = Inf; Ymax = -Inf;
fNames = fieldnames(spikeRecordCumulative);
for i = 1:length(fNames)
    if ~isempty(spikeRecordCumulative.(fNames{i}).spikeWaveforms)
        Ymin = min(Ymin,min(spikeRecordCumulative.(fNames{i}).spikeWaveforms(:)));
        Ymax = max(Ymax,max(spikeRecordCumulative.(fNames{i}).spikeWaveforms(:)));
    end
end
doneFindingYLim = ~any(isinf([Ymin Ymax]));
if doneFindingYLim
    Ymin = Ymin-0.1*(Ymax-Ymin);
    Ymax = Ymax+0.4*(Ymax-Ymin);
end

% now the x - dimensions
i = 1; doneFindingXLim = false;
while i<length(fNames) && ~doneFindingXLim
    if ~isempty(spikeRecordCumulative.(fNames{i}).spikeWaveforms)
        X0 = find(spikeRecordCumulative.(fNames{i}).spikeWaveforms(1,:)==min(spikeRecordCumulative.(fNames{i}).spikeWaveforms(1,:)));
        %Xmin = -X0/spikeRecordCumulative.(fName{i}).samplingRate;
        Xmax = (length(spikeRecordCumulative.(fNames{i}).spikeWaveforms(1,:)));%-X0)/spikeRecordCumulative.fName{i}.samplingRate;
        doneFindingXLim = true;
    else
        i = i+1;
    end
end
if ~doneFindingXLim | ~doneFindingYLim
    error('no spikes were identified in the recording. change the threshold.');
end

% plot all the spikeWaveforms for that chunk


for chanNum = thesePhysChannelInds
    Xpos = rem(chanNum,4)+4*double(rem(chanNum,4)==0);
    Ypos = floor(chanNum/4)+1-double(rem(chanNum,4)==0);
    chanPos = [0.08+0.233*(Xpos-1) 0.08+0.233*(4-Ypos) 0.2 0.2];
    axInd = axes('Position',chanPos);
    
    
    % plot all the spikeWaveforms for that chunk
    chanName = sprintf('chan%d',allPhysInds(chanNum));
    
    if ~isempty(spikeRecordCumulative.(chanName).spikeWaveforms)
        plot((spikeRecordCumulative.(chanName).spikeWaveforms'),'color','g'); hold on;
        text(Xmax,Ymin,sprintf('%d spikes found',size(spikeRecordCumulative.(chanName).spikes,1)),'HorizontalAlignment','Right','VerticalAlignment','Bottom');
    else
        text(20,0.05,'no spikes found'); hold on;
    end
    plot([1:Xmax],zeros(size([1:Xmax])),'color',0.8*[1 0.2 0.4]);
    plot([1:Xmax],spikeDetectionParams(chanNum).threshHoldVolts(1)*ones(size([1:Xmax])),'color',0.8*[1 1 1],'LineStyle','--');
    set(axInd,'XLim',[1 Xmax],'YLim',[Ymin Ymax],'XTick',[1 X0 Xmax],'YTick',[Ymin 0 Ymax],...
        'XTickLabel',[-X0*1000/spikeRecordCumulative.(fNames{i}).samplingRate;0;(length(spikeRecordCumulative.(fNames{i}).spikeWaveforms(1,:))-X0)*1000/spikeRecordCumulative.(fNames{i}).samplingRate;],...
        'YTickLabel',[Ymin;0;Ymax]);
    % if not the first column X==1, remove YTickLabels
    if Xpos~=1
        set(axInd,'YTickLabel',{});
    end
    
    % if not the last row Y==4, remove XTickLabels
    if Ypos~=4
        set(axInd,'XTickLabel',{});
    end
end
end



