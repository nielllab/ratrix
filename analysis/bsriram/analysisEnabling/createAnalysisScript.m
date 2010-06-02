function out = createAnalysisScript(ratID,dataPath,eventLogCommentingON,analysisParamFileName)
% try
    %% INPUT VERIFICATION
    if ~exist('ratID','var')||isempty(ratID)
        error('need a rat to run createAnalysisScript');
    end
    
    if ~exist('dataPath','var')||isempty(dataPath)
        dataPath = '\\132.239.158.179\datanet_storage';
    end
    
    if ~exist('analysisParamFileName','var')||isempty(analysisParamFileName)
        analysisParamFileName = 'sampleAnalysisParameters';
    end
    ratDataFolder = fullfile(dataPath,ratID);
    if ~exist(ratDataFolder,'dir')
        error('no data...');
    end
    
    if ~exist('eventLogCommentingON','var')||isempty(eventLogCommentingON)
        eventLogCommentingON = true;
    end
    
    if eventLogCommentingON
        eventsFolder = '\\Reinagel-lab.AD.ucsd.edu\RLAB\Rodent-Data\physiology';
        ratEventsFolder = fullfile(eventsFolder,ratID);
        ratEventFolderContents = dir(ratEventsFolder);
        ratEventFolderContents = ratEventFolderContents(~ismember({ratEventFolderContents.name},{'.','..'}));
        allEvents = [];
        
        %% load events_data information
        for i = 1:length(ratEventFolderContents)
            dailyEventLog = dir(fullfile(ratEventsFolder,ratEventFolderContents(i).name,'physiologyEvents*.mat'));
            if length(dailyEventLog)>1 || length(dailyEventLog)<1
                error(sprintf('number of eventLogs for date %s is %d',ratEventFolderContents(i).name,length(dailyEventLog)));
            else
                load(fullfile(fullfile(ratEventsFolder,ratEventFolderContents(i).name,dailyEventLog.name)));
                allEvents = [allEvents events_data];
                clear events_data;
            end
        end
    end
%% the rest
        
    ratStimContents = dir(fullfile(ratDataFolder,'stimRecords'));
    ratPhysContents = dir(fullfile(ratDataFolder,'neuralRecords'));
    
    %% DATA MASSAGING
    ratStimContents = ratStimContents(~ismember({ratStimContents.name},{'.','..'}));
    ratStimContents = ratStimContents(~cell2mat({ratStimContents.isdir}));
    
    % initialize some counters
    currTrialNumber = 1;
    index = ~cellfun(@isempty,strfind({ratStimContents.name},['_' num2str(currTrialNumber) '-']));
    if size(index,1)>1
        error('too many stimRecords for a given trial number. recheck trial numbers...');
    elseif isempty(index)
        error('missing trial');
    end
    
    % The first trial has no previous trial. It will be loaded by default
    out = stochasticLoad(fullfile(ratDataFolder,'stimRecords',ratStimContents(index).name),{'stimManagerClass'},10);
    prevStimManager = out.stimManagerClass;
    out  = stochasticLoad(fullfile(ratDataFolder,'stimRecords',ratStimContents(index).name),{'stimulusDetails'},10);
    prevStimDetails = out.stimulusDetails;
    stopAnalysisStreak = false;
    currStartStreak = 1;
    currStopStreak = currStartStreak;
    
    % open required file for writing
    if ~exist(fullfile(getRatrixPath,'analysis','analysisScripts',ratID),'dir')
        mkdir(fullfile(getRatrixPath,'analysis','analysisScripts'),ratID);
    end
    fileName = sprintf('%s_%s.m','analysisScript',datestr(now,'mm_dd_yyyy'));
    fileID = fopen(fullfile(getRatrixPath,'analysis','analysisScripts',ratID,fileName),'a+');
    
    analysisParamsString = sprintf('run(''%s'')',fullfile(getRatrixPath,'analysis','analysisScripts',analysisParamFileName));
    fprintf(fileID,'%s\n',analysisParamsString);
    ratIDString = sprintf('subjectID = ''%s'';',ratID);
    fprintf(fileID,'%s\n',ratIDString);
    fprintf(fileID,'%%%% Rat Number %s\n',ratID);
    
    h = waitbar(1/length(ratStimContents),'Processing trial....');
    for currTrialNumber = 2:length(ratStimContents)
        waitbar(currTrialNumber/length(ratStimContents),h,sprintf('Processing trial....%d of %d',currTrialNumber,length(ratStimContents)));
        index = ~cellfun(@isempty,strfind({ratStimContents.name},['_' num2str(currTrialNumber) '-']));
        if size(index,1)>1
            error('too many stimRecords for a given trial number. recheck trial numbers...');
        elseif isempty(index)
            error('missing trial');
        end
        
        [out successForClass] = stochasticLoad(fullfile(ratDataFolder,'stimRecords',ratStimContents(index).name),{'stimManagerClass'},10);
        if ~successForClass
            stimReachable = false;
        else
            stimReachable = true;
            currStimManager = out.stimManagerClass;
        end
        
        [out successForDetails]  = stochasticLoad(fullfile(ratDataFolder,'stimRecords',ratStimContents(index).name),{'stimulusDetails'},10);
        if ~successForDetails
            stimReachable = false;
        else
            stimReachable = true;
            currStimDetails = out.stimulusDetails;
        end
        
        
        if successForClass && successForDetails && strcmp(currStimManager,prevStimManager)
            % if stim manager is same then check the parameters to see if the
            % stimulus has changed
            stimType = eval(prevStimManager);
            stopAnalysisStreak = ~compareStimRecords(stimType,prevStimDetails,currStimDetails);
        else
            % if the stim manager changed, then that streak of stimuli has
            % stopped
            stopAnalysisStreak = true;
        end
        
        
        if ~stopAnalysisStreak
            prevStimManager = currStimManager;
            prevStimDetails = currStimDetails;
            currStopStreak = currTrialNumber;
        else
            explanationStimType = eval(prevStimManager);
            explanationString = commonNameForStim(explanationStimType,prevStimDetails);
            %         switch prevStimManager
            %             case 'gratings'
            %
            %             case 'whitenoise'
            %         end
            if currStartStreak ~= currStopStreak
                analysisString = sprintf('%%cellBoundary={''trialRange'',[%d %d]} %% %s',currStartStreak,currStopStreak,explanationString);
            else
                analysisString = sprintf('%%cellBoundary={''trialRange'',[%d]} %% %s',currStartStreak,explanationString);
            end
            
            if eventLogCommentingON
                % commentExtraction for streak
                commentBoundaryType = 'trialNumber';
                commentBoundary = [currStartStreak currStopStreak];
                commentExtractionOptions = {'includeTrailingComments',true,'errorOnMultipleHitsOfBoundaryType',false};
                commentString = getCommentStringFromEventsData(allEvents,commentBoundaryType,commentBoundary,commentExtractionOptions);
            else
                commentString = '';
            end
            fprintf(fileID,'%s\n',analysisString);
            fprintf(fileID,'%s',commentString);
            if any([~successForClass ~successForDetails])
                fprintf(fileID,'%s %d %s','Unable to access details for trialNumber', currTrialNumber,'.Moving onto next trial');
            end
            fprintf(fileID,'%s\n','%==========================================================================');
            stopAnalysisStreak = false;
            prevStimManager = currStimManager;
            prevStimDetails = currStimDetails;
            currStartStreak = currTrialNumber;
            currStopStreak = currStartStreak;
        end
    end
    close(h);
    analysisManagerByChunkString = sprintf('%s ... \n %s','analysisManagerByChunk(subjectID, path, cellBoundary, spikeDetectionParams,','spikeSortingParams,timeRangePerTrialSecs,stimClassToAnalyze,overwriteAll,usePhotoDiodeSpikes,plottingParams)');
    fprintf(fileID,'%s',analysisManagerByChunkString);
    fclose(fileID);
    out = true;
    edit(fullfile(getRatrixPath,'analysis','analysisScripts',ratID,fileName));
% catch ex
%     rethrow(ex)
%     fclose all
%     close all
%     out = false;
% end
end