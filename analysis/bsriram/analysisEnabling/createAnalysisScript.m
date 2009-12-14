function out = createAnalysisScript(ratID,dataPath,analysisParamFileName)
try
    if ~exist('ratID','var')||isempty(ratID)
        error('need a rat to run createAnalysisScript');
    end
    
    if ~exist('dataPath','var')||isempty(dataPath)
        dataPath = '\\132.239.158.179\datanet_storage';
    end
    
    if ~exist('analysisParamFileName','var')||isempty(analysisParamFileName)
        analysisParamFileName = 'sampleAnalysisParameters';
    end
    
    stimParameters.gratings = {'spatialFrequencies','driftfrequencies','orientations','phases','contrasts',...
        'location','durations','radii','annuli','numRepeats','doCombos','changeableAnnulusCenter','waveform'};
    stimParameters.whiteNoise = {'strategy','spatialDim','patternType'};
    
    
    
    ratDataFolder = fullfile(dataPath,ratID);
    if ~exist(ratDataFolder,'dir')
        error('no data...');
    end
    
    ratStimContents = dir(fullfile(ratDataFolder,'stimRecords'));
    ratPhysContents = dir(fullfile(ratDataFolder,'neuralRecords'));
    
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
    out = stochasticLoad(fullfile(ratDataFolder,'stimRecords',ratStimContents(index).name),{'stimManagerClass'});
    prevStimManager = out.stimManagerClass;
    out  = stochasticLoad(fullfile(ratDataFolder,'stimRecords',ratStimContents(index).name),{'stimulusDetails'});
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
    
    h = waitbar(1/length(ratStimContents),'Processing trials');
    for currTrialNumber = 2:length(ratStimContents)
        waitbar(currTrialNumber/length(ratStimContents),h);
        index = ~cellfun(@isempty,strfind({ratStimContents.name},['_' num2str(currTrialNumber) '-']));
        if size(index,1)>1
            error('too many stimRecords for a given trial number. recheck trial numbers...');
        elseif isempty(index)
            error('missing trial');
        end
        
        out = stochasticLoad(fullfile(ratDataFolder,'stimRecords',ratStimContents(index).name),{'stimManagerClass'});
        currStimManager = out.stimManagerClass;
        out  = stochasticLoad(fullfile(ratDataFolder,'stimRecords',ratStimContents(index).name),{'stimulusDetails'});
        currStimDetails = out.stimulusDetails;
        
        if strcmp(currStimManager,prevStimManager)
            % if stim manager is same then check the parameters to see if the
            % stimulus has changed
            stopAnalysisStreak = ~compareStimParameters(prevStimDetails,currStimDetails,stimParameters.(currStimManager));
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
            explanationString = prevStimManager;
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
            fprintf(fileID,'%s\n',analysisString);
            stopAnalysisStreak = false;
            prevStimManager = currStimManager;
            prevStimDetails = currStimDetails;
            currStartStreak = currTrialNumber;
            currStopStreak = currStartStreak;
        end
    end
    close(h);
    fprintf(fileID,'%s','analysisManagerByChunk(subjectID, path, cellBoundary, spikeDetectionParams, spikeSortingParams,timeRangePerTrialSecs,stimClassToAnalyze,overwriteAll,usePhotoDiodeSpikes,plottingParams)');
    fclose(fileID);
    out = true;
    edit(fullfile(getRatrixPath,'analysis','analysisScripts',ratID,fileName));
catch
    out = false;
end
end

function paramsIdentical = compareStimParameters (params1,params2,paramsList)
paramsIdentical = true;
for currParamNum = 1:length(paramsList)
    % checking method will depend upon the type of data in params. only
    % call/char and numeric and logical types are supported
    if isnumeric(params1.(paramsList{currParamNum}))
        if length(params1.(paramsList{currParamNum}))==length(params2.(paramsList{currParamNum}))
            paramsIdentical = paramsIdentical && all(sort(params1.(paramsList{currParamNum}))==sort(params2.(paramsList{currParamNum})));
        else
            paramsIdentical = false;
        end
    elseif ischar(params1.(paramsList{currParamNum})) || iscell(params1.(paramsList{currParamNum}))
        paramsIdentical = paramsIdentical && all(strcmp(params1.(paramsList{currParamNum}),params2.(paramsList{currParamNum})));
    elseif islogical(params1.(paramsList{currParamNum}))
        paramsIdentical = paramsIdentical && all(double(params1.(paramsList{currParamNum}))==double(params2.(paramsList{currParamNum})));
    else
        error('unknown type...');
    end
end
end