function [graduate, details] = checkCriterion(c,subject,trainingStep,trialRecords)
% this criterion will graduate if we have found a receptive field given the analysis and stimRecord


%determine what type trialRecord are
recordType='largeData'; %circularBuffer
graduate=0;

% try to load the most recent analysis file and corresponding stimRecord
% c.dataRecordsPath
d=dir(fullfile(c.dataRecordsPath, getID(subject), 'analysis'));
if isempty(d)
    warning('no analysis records found at path - will not be able to graduate');
else
    % first sort the neuralRecords by trial number
    for i=1:length(d)
        [matches tokens] = regexpi(d(i).name, 'analysis_(\d+)-(.*)\.mat', 'match', 'tokens');
        if length(matches) ~= 1
            %         warning('not a neuralRecord file name');
        else
            goodFiles(end+1).trialNum = str2double(tokens{1}{1});
            goodFiles(end).timestamp = tokens{1}{2};
        end
    end
    [sorted order]=sort([goodFiles.trialNum]);
    goodFiles=goodFiles(order);
    
    % load the last analysis and corresponding stimRecord
    analysisFilename = sprintf('analysis_%d-%s.mat', goodFiles(end).trialNum, goodFiles(end).timestamp);
%     stimRecordFilename = sprintf('stimRecords_%d-%s.mat', goodFiles(end).trialNum, goodFiles(end).timestamp);
    load(fullfile(c.dataRecordsPath, getID(subject), 'analysis', analysisFilename));
%     load(fullfile(c.dataRecordsPath, getID(subject), 'stimRecords', stimRecordFilename));
    
    % get the variables we need to check for graduation
    sta = analysisdata.cumulativeSTA;
%     spikeCount = analysisdata.cumulativeSpikeCount;
%     stim = stimulusDetails.big;
%     numFrames = size(stim,3);
    
    if ~isempty(trialRecords)
        % get the contrast from the last trialRecord
        thisStep=[trialRecords.trainingStepNum]==trialRecords(end).trainingStepNum;
        trialsUsed=trialRecords(thisStep);
        lastTrial=trialsUsed(end);
        contrast=lastTrial.stimulusDetails.contrast; % double check this
        alpha = c.alpha;
        
        %get the correct vector
        switch recordType
            case 'largeData'
                % do the calculation now
                % sta, spikeCount, stim, numFrames, contrast, alpha, rf
%                 sta = mean(triggers,3);
                zscore = erf(abs(sta/nullStd));
                significant = zscore > (1 - alpha/2);
                
                % denoise significant to see if we have a good receptive field
                % use a 3x3 box median filter, followed by bwlabel (to count the number of spots left)
                box = ones(3,3);
                cross = zeros(3,3); cross([2,4,5,6,8]) = 1;
                sigBox = ordfilt2(significant,5,box);
                [sigLabel numSpots] = bwlabel(sigBox,8); % use 8-connected (count diagonal connections)
                if numSpots < c.numberSpotsAllowed
                    graduate=1;
                end
                
            case 'circularBuffer'
                error('not written yet');
            otherwise
                error('unknown trialRecords type')
        end
    end
end




%play graduation tone

if graduate
    beep;
    waitsecs(.2);
    beep;
    waitsecs(.2);
    beep;
    waitsecs(1);
    [junk stepNum]=getProtocolAndStep(subject);
    for i=1:stepNum+1
        beep;
        waitsecs(.4);
    end
    if (nargout > 1)
        details.date = now;
        details.criteria = c;
        details.graduatedFrom = stepNum;
        details.allowedGraduationTo = stepNum + 1;
        details.trialsPerMin = trialsPerMin;
    end
end