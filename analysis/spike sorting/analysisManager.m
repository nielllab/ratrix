function quit = analysisManager(subjectID, path, spikeDetectionParams, spikeSortingParams,trialRange,timeRangePerTrialSecs,stimClassToAnalyze,overwriteAll,usePhotoDiodeSpikes)
% this runs the loop to check for neuralData and do analysis as necessary
% inputs include the subjectID and path (where eyeRecords,neuralRecords,and stimRecords are stored)


if ~exist('subjectID','var') || isempty(subjectID)
    subjectID = 'demo1'; %
end

if ~exist('path','var') || isempty(path)
    % path = '\\Reinagel-lab.AD.ucsd.edu\RLAB\Rodent-Data\Fan\datanet' % OLD
    path = '\\132.239.158.179\datanet_storage\';
end

if ~exist('spikeDetectionParams','var') || isempty(spikeDetectionParams)
    spikeDetectionParams.method='oSort';
    spikeDetectionParams.ISIviolationMS;
end

if ~exist('spikeSortingParams','var') || isempty(spikeSortingParams)
    spikeSortingParams.method='oSort';
end

if ~exist('trialRange','var') || isempty(trialRange)
    trialRange = [0 Inf]; %all
end

if all(size(trialRange)==1)
    trialRange=[trialRange trialRange]; % single trial is the start and stop trial
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


quit = false;
result=[];
analysisdata=[];
stimManagerClass=[];
stimulusDetails=[];
physiologyEvents=[];
plotParameters.doPlot=false;
plotParameters.handle=figure;

%SETUP: determine record paths (may need to mkdir) ... could be a function
neuralRecordsPath = fullfile(path, subjectID, 'neuralRecords');
if ~isdir(neuralRecordsPath)
    neuralRecordsPath
    error('unable to find directory to neuralRecords');
end

stimRecordsPath = fullfile(path, subjectID, 'stimRecords');
if ~isdir(stimRecordsPath)
    mkdir(stimRecordsPath);
end

spikeRecordPath = fullfile(path, subjectID, 'spikeRecords');
if ~isdir(spikeRecordPath)
    mkdir(spikeRecordPath);
end

eyeRecordPath = fullfile(path, subjectID, 'eyeRecords');
if ~isdir(eyeRecordPath)
    mkdir(eyeRecordPath);
end

analysisPath = fullfile(path, subjectID, 'analysis');
if ~isdir(analysisPath)
    mkdir(analysisPath);
end

while ~quit
    % get a list of the available neuralRecords
    waitsecs(0.5);
    d=dir(neuralRecordsPath);
    disp('waited after dir');
    goodFiles = [];
    
    % first sort the neuralRecords by trial number
    for i=1:length(d)
        [matches tokens] = regexpi(d(i).name, 'neuralRecords_(\d+)-(.*)\.mat', 'match', 'tokens');
        if length(matches) ~= 1
            %         warning('not a neuralRecord file name');
        else
            goodFiles(end+1).trialNum = str2double(tokens{1}{1});
            goodFiles(end).timestamp = tokens{1}{2};
        end
    end
    [sorted order]=sort([goodFiles.trialNum]);
    goodFiles=goodFiles(order);
    
    %then remove all files if out of trial range
    goodFiles=goodFiles([goodFiles.trialNum]>=trialRange(1) & [goodFiles.trialNum]<=trialRange(2));
    
    
    % neuralRecord_1-20081023T155924.mat
    % for each neuralRecord here, try to load the corresponding stimRecord
    for i=1:length(goodFiles)
        % now try to load the corresponding stimRecord
        try
            % =================================================================================
            % setup filenames and paths -- could be a function...
            stimRecordLocation = fullfile(stimRecordsPath, sprintf('stimRecords_%d-%s.mat', goodFiles(i).trialNum, goodFiles(i).timestamp));
            neuralRecordLocation = fullfile(neuralRecordsPath, sprintf('neuralRecords_%d-%s.mat',goodFiles(i).trialNum,goodFiles(i).timestamp));
            spikeRecordLocation = fullfile(spikeRecordPath, sprintf('spikeRecords_%d-%s.mat',goodFiles(i).trialNum,goodFiles(i).timestamp));
            %eyeRecordLocation = fullfile(eyeRecordPath,sprintf('eyeRecords_%d-%s.mat',goodFiles(i).trialNum,goodFiles(i).timestamp)); % uses function
            analysisLocation = fullfile(analysisPath, sprintf('physAnalysis_%d-%s.mat',goodFiles(i).trialNum,goodFiles(i).timestamp));
            
            %stimRecordLocation
            lastStimManagerClass=stimManagerClass; % store the previous trial's stim class
            if ~isempty(physiologyEvents)
                lastZposition=physiologyEvents(end).position(3); % store the previous trial's ending z-position
            else
                lastZposition=[];
            end
            load(stimRecordLocation, 'stimManagerClass')                
            analyzeThisClass= all(strcmp('all',stimClassToAnalyze)) ||  any(strcmp(stimManagerClass,stimClassToAnalyze));
            if analyzeThisClass
                
                % =================================================================================
                % if there is no spikeRecord corresponding to the current neuralRecord, run spike analysis on it
                if ~exist(spikeRecordLocation,'file') || overwriteAll
                    disp(sprintf('loading neural record %s', neuralRecordLocation));
                    load(neuralRecordLocation);    % has neuralData, neuralDataTimes, samplingRate, parameters
                    
                    %timeRangePerTrialSamps=timeRangePerTrialSecs*samplingRate; % not needed, but might be faster ;
                    %eben better is if we could load "part" of a matlab variable (specified inds) at a faster speeds.
                    % probably can't b/c matlab compression
                    
                    % avoid making big variables to filter the data if you can...
                    if timeRangePerTrialSecs(1)==0 & timeRangePerTrialSecs(2)> diff(neuralDataTimes([1 end]))% use all
                        % do nothing, b/c using all
                    else %filter
                        timeSinceTrialStart=neuralDataTimes-neuralDataTimes(1);
                        withinTimeRange=timeSinceTrialStart>=timeRangePerTrialSecs(1) & timeSinceTrialStart<=timeRangePerTrialSecs(2);
                        neuralData=neuralData(withinTimeRange,:);
                        neuralDataTimes=neuralDataTimes(withinTimeRange);
                    end
                    
                    % get frameIndices and frameTimes (from screen pulses)
                    % bounds to decide whether or not to continue with analysis
                    warningBound = 0.01;
                    errorBound = 0.05;
                    ifi = 1/100;
                    spikeDetails=[];
                    [frameIndices frameTimes frameLengths correctedFrameIndices correctedFrameTimes correctedFrameLengths passedQualityTest] = ...
                        getFrameTimes(neuralData(:,1),neuralDataTimes,samplingRate,warningBound,errorBound,ifi); % pass in the pulse channel
                    if usePhotoDiodeSpikes
                        [spikes photoDiode]=getSpikesFromPhotodiode(neuralData(:,2),neuralDataTimes, correctedFrameIndices);
                        spikeTimestamps = neuralDataTimes(spikes==1);
                        spikeWaveforms=[];
                        assignedClusters=ones(1,length(spikeTimestamps));
                        %                         frameTimes(:,1); %frame starts
                        %                         frameTimes(:,2); %frame stops
                    else
                        
                        %detection params needs samplingRate
                        spikeDetectionParams.samplingFreq=samplingRate; % always overwrite with current value
                        %                     if ismember('samplingFreq',fields(spikeDetectionParams))
                        %                         spikeDetectionParams.samplingFreq
                        %                         error('when using analysis manager, samplingFreq is not specified by user, but rather loaded direct from the neural data file')
                        %                     else
                        %                         spikeDetectionParams.samplingFreq=samplingRate;
                        %                     end
                        
                        [spikes spikeWaveforms spikeTimestamps assignedClusters rankedClusters photoDiode]=...
                            getSpikesFromNeuralData(neuralData(:,3),neuralDataTimes,spikeDetectionParams,spikeSortingParams);
                        % 11/25/08 - do some post-processing on the spike's assignedClusters ('treatAllNonNoiseAsSpikes', 'largestClusterAsSpikes', etc)
                        
                        if ~isempty(assignedClusters)
                            spikeDetails = postProcessSpikeClusters(assignedClusters,rankedClusters,spikeSortingParams);
                            spikeDetails.rankedClusters=rankedClusters;
                        else
                            passedQualityTest=false;
                        end
                    end
                    % do some plotting
                    %                 plot(neuralDataTimes, neuralData(:,1), '-db');
                    %                 hold on
                    %                 y2 = ones(1, length(neuralDataTimes))*5;
                    %                 y2(frameIndices(:,1)) = 0.1;
                    %                 plot(neuralDataTimes, y2, '.r');
                    %                 hold off
                    
                    
                    %save spike-related data
                    save(spikeRecordLocation,'spikes','spikeWaveforms','spikeTimestamps','assignedClusters','spikeDetails',...
                        'frameIndices','frameTimes','frameLengths','correctedFrameIndices','correctedFrameTimes','correctedFrameLengths',...
                        'photoDiode','passedQualityTest','samplingRate');
                    disp('saved spike data');
                else
                    % already have a spikeRecord for this neuralRecord, just load it
                    load(spikeRecordLocation); % this also populates passedQualityTest (to check if we should do analysis)
                    disp('loaded spikeRecord');
                end
                
                % check that we have spikes
                if isempty(assignedClusters)
                    passedQualityTest=false;
                end
                
                % =================================================================================
                % now run analysis on spikeRecords and stimRecords
                % try to get location of analysis file
                quality.passedQualityTest=passedQualityTest;
                quality.frameIndices=frameIndices;
                quality.frameTimes=frameTimes;
                quality.frameLengths=frameLengths;
                quality.correctedFrameIndices=correctedFrameIndices;
                quality.correctedFrameTimes=correctedFrameTimes;
                quality.correctedFrameLengths=correctedFrameLengths;
                quality.samplingRate=samplingRate; % from neuralRecord
                
                % load stimRecords  
                lastStimulusDetails=stimulusDetails;
                load(stimRecordLocation);
                evalStr = sprintf('sm = %s();',stimManagerClass);
                eval(evalStr);
                % 1/26/09 - skip analysis if not worth sorting spikes
                doAnalysis= (~exist(analysisLocation,'file') || overwriteAll) && worthSpikeSorting(sm,quality);
                % if we need to do analysis (either no analysis file exists or we want to overwrite)
                
                if 1 %doAnalysis
                    % do something with loaded information
                    
                    % get some paramteres from neual data
                    if ~exist('parameters','var')
                        load(neuralRecordLocation,'parameters');    
                    end
                    %Add some more parameters about the trial
                     parameters.trialNumber=goodFiles(i).trialNum;
                    parameters.date=datenumFor30(goodFiles(i).timestamp);
                    parameters.ISIviolationMS=spikeDetectionParams.ISIviolationMS;
                    
                    % spikeData is a struct that contains all spike information that different analyses may want
                    spikeData=[];
                    spikeData.spikes=spikes;
                    spikeData.frameIndices=correctedFrameIndices; % dont give physAnalysis the bad frames
                    spikeData.photoDiode=photoDiode;
                    spikeData.spikeWaveforms=spikeWaveforms;
                    spikeData.spikeTimestamps=spikeTimestamps;
                    spikeData.assignedClusters=assignedClusters;
                    spikeData.spikeDetails=spikeDetails; % could contain anything
                    
                    eyeData=getEyeRecords(eyeRecordPath, goodFiles(i).trialNum,goodFiles(i).timestamp);
                    % the stimManagerClass to be passed in is for class typing only -
                    % the analysis function is called as a static method of the stimManager class
                    % just pass in a default stimManager - no variables are used
                    % stuff to class type the analysis method
                    % stimManagerClass = stimulusDetails.stimManagerClass;
                    % already its own variable in stimRecords
                    [analysisdata] = physAnalysis(sm,spikeData,stimulusDetails,plotParameters,parameters,analysisdata,eyeData);
                    % parameters is from neuralRecord
                    % we pass in the analysisdata because it contains cumulative information that is specific to the analysis method
                    % this is the way of making sure it gets in every trial's analysis file, and that it will get propagated to the next analysis
                    save(analysisLocation, 'analysisdata');
                elseif ~overwriteAll && passedQualityTest % if the analysis file already exists in an acceptable state
                    % also check the following before loading:
                    % trialNum is not out of trialRange - already checked above (weeds out goodFiles)
                    % previous trial is same stim manager class
                    % stim size is the same (see stimulusDetails)
                    % z depth (physiologyEvents) is the same
                    if (isempty(lastStimManagerClass) || strcmp(lastStimManagerClass, stimManagerClass)) ...
                            && (isempty(physiologyEvents) || all([physiologyEvents.position(3)]==lastZposition))%...
                             % && lastStimulusDetails.height==stimulusDetails.height ...
                            % && lastStimulusDetails.width==stimulusDetails.width ...
                            % these checks belong in physAnalysis.  the
                            % cumulative gets reset if they fail, it simply
                            % ignores the previous analysis info
                            % other stim types don't nec. have these fields
                            % defined. -pmm
                        load(analysisLocation, 'analysisdata');
                    else
                        warning('did not load analysis file due to inconsistencies between this trial and last');
                    end
                end
            else
                disp(sprintf('skipping class: %s',stimManagerClass))
            end
            
            if goodFiles(i).trialNum==trialRange(2);  
                % will stop analyzing after last requested trial ...
                % in default will keep looking for new data, because 
                % trialRange(2)< Inf
                quit=1;
            end
            
        catch ex
            ple
            %             break
            % 11/25/08 - restart dir loop if tried to load corrupt file
            rethrow(ex)
            error('failed to load from file');
        end
        
    end
    
    
    
    %     % get a list of the available stimRecords
    %     stimRecordsPath = fullfile(path, subjectID, 'stimRecords');
    %     if ~isdir(stimRecordsPath)
    %         error('unable to find directory to stimRecords');
    %     end
    %
    %     d=dir(stimRecordsPath)
    
end % end loop

end % end main function
% ===============================================================================================



% ===============================================================================================

function [spikes photoDiode]=getSpikesFromPhotodiode(photoDiodeData,photoDiodeDataTimes,frameIndices)
% get spikes from neuralData and neuralDataTimes, and given frameTimes
photoDiode=[];
% now calculate spikes in each frame
spikes = zeros(1, size(photoDiodeData, 1));
% channel = 1; % what channel of the neuralData to look at
% first go through and histogram the values to get a threshold
valuesToCalcThreshold = zeros(1, size(frameIndices,1));
for i=1:size(frameIndices,1)
    % frameValue is the sum of all neuralData of the given channel for the given samples (determined by frame start/stop)
    frameValue = sum(photoDiodeData(frameIndices(i,1):frameIndices(i,2)));
    valuesToCalcThreshold(i) = frameValue*frameValue;
end
% now sort the values, and choose the first 5% to show threshold
valuesToCalcThreshold = sort(valuesToCalcThreshold,'descend');
pivot = ceil(length(valuesToCalcThreshold) / 20);
threshold = (valuesToCalcThreshold(pivot) + valuesToCalcThreshold(pivot+1)) / 2;

% for each frame, see if it passes a threshold
for i=1:size(frameIndices,1)
    % frameValue is the sum of all neuralData of the given channel for the given samples (determined by frame start/stop)
    frameValue = sum(photoDiodeData(frameIndices(i,1):frameIndices(i,2)));
    if frameValue*frameValue > threshold
        % pick a random index in the specified frame
        ind = ceil(rand*(frameIndices(i,2)-frameIndices(i,1)))+frameIndices(i,1);
        spikes(ind) = 1;
    end
end
disp('got spikes from photo diode');

end % end function
% ===============================================================================================


function  eyeData=getEyeRecords(eyeRecordPath, trialNum,timestamp);
% is compatible with older eyeRecords in which multiple .mats got saved per
% trial at different times.

try 
    %this handles current versions
    filename=sprintf('eyeRecords_%d_%s.mat',trialNum,timestamp);
    fullfilepath=fullfile(eyeRecordPath,filename);
    eyeData=load(fullfilepath);
catch ex
    % this handles old record types prior to march 17, 2009

    if strcmp(ex.identifier,'MATLAB:load:couldNotReadFile')
        d=dir(eyeRecordPath);
        goodFiles = [];
        
        % first sort the neuralRecords by trial number
        for i=1:length(d)
            %'eyeRecords_(\d+)-(.*)\.mat'
            %searchString=sprintf('eyeRecords_(%d)-(.*)\\.mat',trialNum)
            [matches tokens] = regexpi(d(i).name, 'eyeRecords_(\d+)_(.*)\.mat', 'match', 'tokens');
            if length(matches) ~= 1
                %d(i).name
                %warning('not a eyeRecord file name');
            else
                if str2double(tokens{1}{1})==trialNum
                    goodFiles(end+1).trialNum = str2double(tokens{1}{1});
                    goodFiles(end).timestamp = tokens{1}{2};
                    goodFiles(end).date = datenumFor30(tokens{1}{2});
                end
            end
        end
        if size(goodFiles,2)>0
        [sorted order]=sort([goodFiles.date]);
        goodFiles=goodFiles(order);
        
        %check that its within the hour of the start trial
        hrAfterStart=(datenumFor30(goodFiles(end).timestamp)-datenumFor30(timestamp))*24;
        if hrAfterStart>0 & hrAfterStart<1
            %LOAD THE MOST RECENT ONE, after checking sanity of time
            filename=sprintf('eyeRecords_%d_%s.mat',trialNum,goodFiles(end).timestamp);
            fullfilepath=fullfile(eyeRecordPath,filename);
            eyeData=load(fullfilepath);
        else
            warning('weird time relation')
            hrAfterStart
            saved=goodFiles(end).timestamp
            started=datenumFor30(timestamp)
            keyboard
        end
        else
            eyeData=[]; % there were no records, eye tracker might have been off
        end
    else
        rethrow(ex);
    end
    
end


end % end function
% ===============================================================================================
