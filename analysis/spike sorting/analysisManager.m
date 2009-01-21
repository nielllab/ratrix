function quit = analysisManager(subjectID, path, usePhotoDiodeSpikes, spikeDetectionParams,spikeSortingParams)
% this runs the loop to check for neuralData and do analysis as necessary
% inputs include the subjectID and path (where eyeRecords,neuralRecords,and stimRecords are stored)

% path = '\\Reinagel-lab.AD.ucsd.edu\RLAB\Rodent-Data\Fan\datanet'
% subjectID = 'demo1'

quit = false;
result=[];
analysisdata=[];
plotParameters.doPlot=false;
plotParameters.handle=figure;

while ~quit
    % get a list of the available neuralRecords
    neuralRecordsPath = fullfile(path, subjectID, 'neuralRecords');
    if ~isdir(neuralRecordsPath)
        error('unable to find directory to neuralRecords');
    end

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
    
    % neuralRecord_1-20081023T155924.mat
    % for each neuralRecord here, try to load the corresponding stimRecord
    for i=1:length(goodFiles)
        % now try to load the corresponding stimRecord
        try
            % =================================================================================
            % setup filenames and paths
            stimRecordFilename = sprintf('stimRecords_%d-%s.mat', goodFiles(i).trialNum, goodFiles(i).timestamp);
            stimRecordLocation = fullfile(path, subjectID, 'stimRecords', stimRecordFilename);
            neuralRecordLocation = fullfile(neuralRecordsPath, sprintf('neuralRecords_%d-%s.mat',goodFiles(i).trialNum,goodFiles(i).timestamp));
            % try to find spike records (may need to mkdir)
            spikeRecordPath = fullfile(path, subjectID, 'spikeRecords');
            if ~isdir(spikeRecordPath)
                mkdir(spikeRecordPath);
            end
            spikeRecordLocation = fullfile(spikeRecordPath, sprintf('spikeRecords_%d-%s.mat',goodFiles(i).trialNum,goodFiles(i).timestamp));
            analysisPath = fullfile(path, subjectID, 'analysis');
            if ~isdir(analysisPath)
                mkdir(analysisPath);
            end
            analysisLocation = fullfile(analysisPath, sprintf('analysis_%d-%s.mat',goodFiles(i).trialNum,goodFiles(i).timestamp));

            % =================================================================================
            % if there is no spikeRecord corresponding to the current neuralRecord, run spike analysis on it
            if ~exist(spikeRecordLocation,'file')
                disp(sprintf('loading neural record %s', neuralRecordLocation));
                load(neuralRecordLocation);    % has neuralData, neuralDataTimes, samplingRate, parameters
                % get frameIndices and frameTimes (from screen pulses)
                % bounds to decide whether or not to continue with analysis
                warningBound = 0.01;
                errorBound = 0.05;
                spikeDetails=[];
                [frameIndices frameTimes passedQualityTest] = getFrameTimes(neuralData(:,1),neuralDataTimes,samplingRate,warningBound,errorBound); % pass in the pulse channel
                if usePhotoDiodeSpikes
                    [spikes photoDiode]=getSpikesFromPhotodiode(neuralData(:,2),neuralDataTimes, frameIndices);
                    spikeTimestamps = neuralDataTimes(spikes==1);
                    spikeWaveforms=[];
                    assignedClusters=ones(1,length(spikeTimestamps));
%                         frameTimes(:,1); %frame starts
%                         frameTimes(:,2); %frame stops
                else
                        [spikes spikeWaveforms spikeTimestamps assignedClusters rankedClusters photoDiode]=...
                            getSpikesFromNeuralData(neuralData(:,2),neuralDataTimes,spikeDetectionParams,spikeSortingParams);
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
                    'frameIndices','frameTimes','photoDiode','passedQualityTest');
                disp('saved spike data');
            else
                % already have a spikeRecord for this neuralRecord, just load it
                load(spikeRecordLocation);
                disp('loaded spikeRecord');
            end

            % check that we have spikes
            if isempty(assignedClusters)
                passedQualityTest=false;
            end
            
            % =================================================================================
            % now run analysis on spikeRecords and stimRecords
            % try to get location of analysis file
            overwriteAll=false;
            % 10/29/08 - skip analysis if fail quality test set in frameTime calc
            doAnalysis= (~exist(analysisLocation,'file') || overwriteAll) && passedQualityTest;
            % if we need to do analysis (either no analysis file exists or we want to overwrite)
            if doAnalysis
                % load stimRecords and use spike data from above
                stimRecordLocation
                load(stimRecordLocation);      % has stimulusDetails (which has big, stimManagerClass, trialManagerClass)
                stimData = stimulusDetails.big;
                % 11/9/08 - if stimulusDetails.big is a cell, then it was dynamic mode calc - generated movie frames from seeds
                if iscell(stimData) && length(stimData) == 2 && strcmp(stimData{1},'dynamic')
                    seeds=stimData{2};
                    spatialDim = stimulusDetails.spatialDim;
                    std = stimulusDetails.std;
                    meanLuminance = stimulusDetails.meanLuminance;
                    height=stimulusDetails.height;
                    width=stimulusDetails.width;
                    factor = width/spatialDim(1);
                    
%                     stimData=zeros(height,width,length(seeds)); % method 1
                    stimData=zeros(spatialDim(1),spatialDim(2),length(seeds)); % method 2
                    for frameNum=1:length(seeds)
                        randn('state',seeds(frameNum));
                        stixels = randn(spatialDim)*255*std+meanLuminance;
                        
                        % =======================================================
                        % method 1 - resize the movie frame to full pixel size
                        % for each stixel row, expand it to a full pixel row
%                         for stRow=1:size(stixels,1)
%                             pxRow=[];
%                             for stCol=1:size(stixels,2) % for each column stixel, repmat it to width/spatialDim
%                                 pxRow(end+1:end+factor) = repmat(stixels(stRow,stCol), [1 factor]);
%                             end
%                             % now repmat pxRow vertically in stimData
%                             stimData(factor*(stRow-1)+1:factor*stRow,:,frameNum) = repmat(pxRow, [factor 1]);
%                         end
%                         % reset variables
%                         pxRow=[];
                        % =======================================================
                        % method 2 - leave stimData in stixel size
                        stimData(:,:,frameNum) = stixels;
                        
                        
                        % =======================================================
                    end
                end
                    
                % do something with loaded information
                if ~exist('parameters','var')
                    parameters=[];
                end
                % spikeData is a struct that contains all spike information that different analyses may want
                spikeData=[];
                spikeData.spikes=spikes;
                spikeData.frameIndices=frameIndices;
                spikeData.photoDiode=photoDiode;
                spikeData.spikeWaveforms=spikeWaveforms;
                spikeData.spikeTimestamps=spikeTimestamps;
                spikeData.assignedClusters=assignedClusters;
                spikeData.spikeDetails=spikeDetails; % could contain anything
                % the stimManagerClass to be passed in is for class typing only - 
                % the analysis function is called as a static method of the stimManager class
                % just pass in a default stimManager - no variables are used
                % stuff to class type the analysis method
                stimManagerClass = stimulusDetails.stimManagerClass;
                evalStr = sprintf('sm = %s();',stimManagerClass);
                eval(evalStr);
                [analysisdata] = physAnalysis(sm,spikeData,stimData,plotParameters,parameters,analysisdata); 
                % parameters is from neuralRecord
                % we pass in the analysisdata because it contains cumulative information that is specific to the analysis method
                % this is the way of making sure it gets in every trial's analysis file, and that it will get propagated to the next analysis
                save(analysisLocation, 'analysisdata');
            elseif ~overwriteAll && passedQualityTest % if the analysis file already exists in an acceptable state
                load(analysisLocation, 'analysisdata');
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

function [frameIndices frameTimes passedQualityTest] = getFrameTimes(pulseData, pulseDataTimes, sampleRate, warningBound, errorBound)
% calculate pulses and frameTimes based on pulseData
% frameIndices - the exact sample index for each pulse
% frameTimes - the time value retrieved from the index of a corresponding pulse (not unique!)
% each frame = three pulses (between the single pulses, ignore double pulses)
passedQualityTest = true; % changed to false temp - to not do analysis until we get better data (10.29.08)

% parameters for threshold
r = 1/20000; % time in seconds for pulse to go from peak to valley on one edge
amp = 4; % conservative amplitude of pulse peak
% threshold = max(min(amp / (r*sampleRate), 4), 0.05); % restricted to be 0.05<=threshold<=4 
% 10/30/08 - decided to make the threshold fixed at 1.0 (even at sampling rate of 125kHz, TTL pulses still only take one sample)
% sometimes (randomly) due to aliasing will fall in between two samples
threshold = 1.0;

% need to fix threshold testing - if sampling rate too high, then the spike gets split among samples
% if we check for low enough threshold, each spike gets multiple counted, if too high threshold, misses these split spikes
% need to check low threshold, but throw out consecutive crosses of threshold (only keep last one as end of spike)
diff_vector = diff(pulseData); % first derivative
% find all pulses (places where the diff is > threshold)
pulses = find(diff_vector > threshold); % this is only the left edge of each pulse
% 10/30/08 - need to postprocess pulses (to weed out cases where the pulse is split among multiple samples)
% only take the last sample of the pulse (set threshold to be low then)
runs = diff(pulses);
runs(end+1) = -1; % automatically include the pulse if it happens on last sample
pulses = pulses(find(runs~=1));

% processing to adjust first pulse to be a single pulse (throw away starting pulses if they are part of the two-pulse signal)
gaps = diff(pulses(1:4));
if gaps(2) > gaps(1) && gaps(3) > gaps(1)
    % we started with two-pulse signal - throw away first two pulses
    pulses(1:2) = [];
elseif gaps(1) > gaps(3) && gaps(2) > gaps(3)
    % we started with two-pulse signal, but with one cut off - throw away first pulse
    pulses(1) = [];
else
    % we started with single-pulse signal - do nothing
end
frameTimes=[];
frameTimes(:,1) = pulseDataTimes(pulses(1:3:end-3));
frameTimes(:,2) = pulseDataTimes(pulses(4:3:end)-1);
frameIndices=[];
frameIndices(:,1) = pulses(1:3:end-3);
frameIndices(:,2) = pulses(4:3:end)-1;

% error checking
frameLengths = diff(frameIndices(:,1),1);
% due to aliasing, up to three values are acceptable
if length(unique(frameLengths)) > 3
    
    ifiMS=1000*unique(frameLengths)./sampleRate
    warning('found more than 3 unique frame lengths - miscalculation of frame start/stop indices');
    mn = mean(frameLengths);
    if any(frameLengths < (1-errorBound)*mn)
        warning('check your assumptions about frame start/stop calculation - found frameLength too small; failing quality test');
        passedQualityTest = false;
    elseif any(frameLengths < (1-warningBound)*mn)
        warning('found frame lengths outside the warningBound (too small)');
    elseif any(frameLengths > (1+warningBound)*mn)
        droppedFrames = find(frameLengths > (1+warningBound)*mn);
        totalNumberOfDroppedFrames = length(droppedFrames)
        fractionOfDroppedFrames = totalNumberOfDroppedFrames / length(frameLengths)
        warning('found dropped frames');
        if any(frameLengths > (1+errorBound)*mn)
            passedQualityTest = false;
            warning('found frame lengths outside the errorBound (too long) - failling quality test');
        end
    end
end

% 
% refreshRate = 60; % frames per second
% samplingRate = 10000; % samples per second
% numSamplesPerFrame = ceil((1/refreshRate) * samplingRate); % samples per frame
% frameTimes = zeros(floor(size(neuralDataTimes, 1) / numSamplesPerFrame), 2);
% % for now, we don't know how to handle the time between frames?
% frameTimes(:,1) = neuralDataTimes(1:numSamplesPerFrame:end-numSamplesPerFrame); % start times
% frameTimes(:,2) = neuralDataTimes(numSamplesPerFrame:numSamplesPerFrame:end); % stop times
%%% add something to make sure that the frame start/stop times are in troughs, not peaks
end % end function

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